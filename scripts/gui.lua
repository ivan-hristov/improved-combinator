local constants = require("constants")
local node = require("scripts.node")
local logger = require("scripts.logger")

------------- String Utils -------------
local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function contains_string(array, name)
    for _, k in pairs(array) do
        if k == name then
            return true
        end
    end
    return false
end

-------------- Event Functions -------
function on_click_show_task_dropdown_frame(event, node)
    if event.element.parent[task_dropdown_frame.id].visible then
        event.element.parent[task_dropdown_frame.id].visible = false
    else
        event.element.parent[task_dropdown_frame.id].visible = true
    end
end
-------------- Gui Functions -------
function create_main_gui(unit_number)
    local root = node.new(unit_number)
    root.gui = {
        type = "frame",
        direction = "vertical",
        name = root.id,
        style = constants.style.main_frame,
        caption = "MAIN FRAME "..unit_number
    }

    local tasks_area = node.add_child(root)
    tasks_area.gui = {
        type = "frame",
        direction = "vertical",
        name = tasks_area.id,
        style = constants.style.tasks_frame
    }

    local scroll_pane = node.add_child(tasks_area)
    scroll_pane.gui = {
        type = "scroll-pane",
        direction = "vertical",
        name = scroll_pane.id,
        style = constants.style.scroll_pane
    }

    local new_task_button = node.add_child(scroll_pane)
    new_task_button.gui = {
        type = "button",
        name = new_task_button.id,
        style = constants.style.large_button_frame,
        caption = "+ Add Task"
    }

    local task_dropdown_frame = node.add_child(scroll_pane)
    task_dropdown_frame.gui = {
        type = "frame",
        direction = "vertical",
        name = task_dropdown_frame.id,
        style = constants.style.dropdown_options_frame,
        visible = false
    }

    global.entities[unit_number].events[new_task_button.id] = {}
    global.entities[unit_number].events[new_task_button.id].on_click = function(event, node)
        if event.element.parent[task_dropdown_frame.id].visible then
            event.element.parent[task_dropdown_frame.id].visible = false
        else
            event.element.parent[task_dropdown_frame.id].visible = true
        end
    end
    local task_dropdown_list = node.add_child(task_dropdown_frame)
    task_dropdown_list.gui = {
        type = "list-box",
        name = task_dropdown_list.id,
        style = constants.style.options_list,
        items = {"Repeatable Timer", "Single User Timer"}    
    }

    global.entities[unit_number].events[task_dropdown_list.id] = {}
    global.entities[unit_number].events[task_dropdown_list.id].on_selection_state_changed = {}
    global.entities[unit_number].events[task_dropdown_list.id].on_selection_state_changed[1] = function(event, node)
        event.element.parent.visible = false
        event.element.selected_index = 0

        local scroll_pane_node = node.parent.parent
        local scroll_pane_gui = event.element.parent.parent

        -- Setup Persistent Nodes --
        local repeatable_time_node = node.add_child(scroll_pane_node)
        repeatable_time_node.gui = {
            type = "frame",
            direction = "vertical",
            name = repeatable_time_node.id,
            style = constants.style.conditional_frame
        }

        local close_button_node = node.add_child(repeatable_time_node)
        close_button_node.gui = {
            type = "sprite-button",
            direction = "vertical",
            name = close_button_node.id,
            style = constants.style.close_button_frame,
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black"
        }
        global.entities[unit_number].events[close_button_node.id] = {}
        global.entities[unit_number].events[close_button_node.id].on_click = function(event, node_param)
            node.remove(node_param.parent)
            event.element.parent.destroy()
        end

        -- Setup Factorio GUI --
        local repeatable_time_gui = scroll_pane_gui.add(repeatable_time_node.gui)
        repeatable_time_gui.add(close_button_node.gui)

    end
    global.entities[unit_number].events[task_dropdown_list.id].on_selection_state_changed[2] = function(event, node)
        event.element.parent.visible = false
        event.element.selected_index = 0
    end

    return root, events
end

function create_main_gui_2(unit_number)
    local root = node.new(unit_number)
    root.gui = {
        type = "frame",
        direction = "vertical",
        name = root.id,
        style = constants.style.main_frame,
        caption = "MAIN FRAME "..unit_number
    }

    local tasks_area = node.add_child(root)
    tasks_area.gui = {
        type = "frame",
        direction = "vertical",
        name = tasks_area.id,
        style = constants.style.tasks_frame
    }

    local scroll_pane = node.add_child(tasks_area)
    scroll_pane.gui = {
        type = "scroll-pane",
        direction = "vertical",
        name = scroll_pane.id,
        style = constants.style.scroll_pane
    }

    local new_task_button = node.add_child(scroll_pane)
    new_task_button.gui = {
        type = "button",
        name = new_task_button.id,
        style = constants.style.large_button_frame,
        caption = "+ Add Task"
    }
    new_task_button.event_ids.on_click = "on_click_show_task_dropdown_frame"
    
    local task_dropdown_frame = node.add_child(scroll_pane)
    task_dropdown_frame.gui = {
        type = "frame",
        direction = "vertical",
        name = task_dropdown_frame.id,
        style = constants.style.dropdown_options_frame,
        visible = false
    }

    return root
end


local first_time = true
local function setup_events(node_param)
    if not node_param then
        return
    end

    for _, child in pairs(node_param.children) do
        setup_events(child)
    end

    for key, id in pairs(node_param.event_ids) do
        if id == "on_click_show_task_dropdown_frame" then
            if not node_param.events[key] then
                node_param.events[key] = {}
            end
            node_param.events[key].on_click = on_click_show_task_dropdown_frame
        end
    end    
end

local function buildGuiNodes(parent, node)
    local new_gui = parent.add(node.gui)
    for _, child in pairs(node.children) do
        buildGuiNodes(new_gui, child)
    end
    return new_gui
end
----------------------------------------


local function on_gui_opened(event)
    logger.print("on_gui_opened")

    if not event.entity then
        return
    end

    local player = game.players[event.player_index]
    if player.selected then        
        if player.selected.name == constants.entity.name then

            if first_time then
                for _, entity in pairs(global.entities) do
                    setup_events(entity.node)
                end
                first_time = false
            end

            global.opened_entity[event.player_index] = event.entity.unit_number
            player.opened = buildGuiNodes(player.gui.screen, global.entities[event.entity.unit_number].node)
            player.opened.force_auto_center()
        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            player.opened = nil
        end
    end
end

local function on_gui_closed(event)
    logger.print("on_gui_closed")

    if event.element then
        local player = game.players[event.player_index]
        if player.opened then        
            player.opened = nil
        end
    
        if global.opened_entity then
            global.opened_entity[event.player_index] = nil
        end

        event.element.destroy()
        event.element = nil
    end
end

local function debug_print(node)
    logger.print("id: "..node.id.." gui: "..node.gui.style)
    for _, child in pairs(node.children) do
        debug_print(child)
    end
end

local function on_gui_click(event)
    logger.print("on_gui_click name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local unit_number = global.opened_entity[event.player_index]

    local current_node = node.recursive_find(global.entities[unit_number].node, name)
    if current_node and current_node.events and current_node.events.on_click then
        current_node.events.on_click(event, current_node)
    end
end

local function on_gui_selection_state_changed(event)
    logger.print("on_gui_selection_state_changed name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    local current_node = node.recursive_find(global.entities[unit_number].node, name)
    if current_node and current_node.on_selection_state_changed then
        current_node.on_selection_state_changed[selected_index](event, current_node)
    end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)

