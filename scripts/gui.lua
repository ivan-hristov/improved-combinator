local constants = require("constants")
local node = require("node")
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

-------------- Gui Functions -------
function create_main_gui(unit_number)
    local root = node:new(unit_number)
    root.gui = {
        type = "frame",
        direction = "vertical",
        name = root.id,
        style = constants.style.main_frame,
        caption = "MAIN FRAME "..unit_number
    }

    local tasks_area = root:add_child()
    tasks_area.gui = {
        type = "frame",
        direction = "vertical",
        name = tasks_area.id,
        style = constants.style.tasks_frame
    }

    local scroll_pane = tasks_area:add_child()
    scroll_pane.gui = {
        type = "scroll-pane",
        direction = "vertical",
        name = scroll_pane.id,
        style = constants.style.scroll_pane
    }

    local new_task_button = scroll_pane:add_child()
    new_task_button.gui = {
        type = "button",
        name = new_task_button.id,
        style = constants.style.large_button_frame,
        caption = "+ Add Task"
    }

    local task_dropdown_frame = scroll_pane:add_child()
    task_dropdown_frame.gui = {
        type = "frame",
        direction = "vertical",
        name = task_dropdown_frame.id,
        style = constants.style.dropdown_options_frame,
        visible = false
    }
    new_task_button.events_id.on_click = "on_click_new_task_button"
    new_task_button.events_params = { task_dropdown_frame_id = task_dropdown_frame.id}

    local task_dropdown_list = task_dropdown_frame:add_child()
    task_dropdown_list.gui = {
        type = "list-box",
        name = task_dropdown_list.id,
        style = constants.style.options_list,
        items = {"Repeatable Timer", "Single Use Timer"}    
    }
    task_dropdown_list.events_id.on_selection_state_changed = "on_selection_changed_task_dropdown"

    root:recursive_setup_events()
    return root
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
            global.opened_entity[event.player_index] = event.entity.unit_number
            local root_node = global.entities[event.entity.unit_number].node
            if not root_node.valid then
                node:recursive_create_metatable(root_node)
            end
            player.opened = buildGuiNodes(player.gui.screen, root_node)
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

local function on_gui_click(event)
    logger.print("on_gui_click name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local unit_number = global.opened_entity[event.player_index]

    local node = global.entities[unit_number].node:recursive_find(name)
    if node and node.events.on_click then
        node.events.on_click(event, node)
    end
end

local function on_gui_selection_state_changed(event)
    logger.print("on_gui_selection_state_changed name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    local node = global.entities[unit_number].node:recursive_find(name)
    if node and node.events.on_selection_state_changed then
        node.events.on_selection_state_changed[selected_index](event, node)
    end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)

