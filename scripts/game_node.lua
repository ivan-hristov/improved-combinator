local node = require("node")
local constants = require("constants")
local logger = require("logger")

local game_node = {}

function game_node:new(entity_id)
    local new_node = node:new(entity_id)
    return new_node
end

function game_node:create_metatable(node_param)
    setmetatable(node_param, node)
    node_param.__index = node_param
end

function game_node:recursive_create_metatable(node_param)
    node:recursive_create_metatable(node_param)
end

function game_node:safely_add_gui_child(parent, style)
    for _, child in pairs(parent.children) do
        if child == name then
            return child
        end
    end
    return parent.add(style)
end

function game_node:buildGuiNodes(parent, node_param)
    local new_gui = game_node:safely_add_gui_child(parent, node_param.gui)
    node_param.gui_element = new_gui

    for _, child in pairs(node_param.children) do
        game_node:buildGuiNodes(new_gui, child)
    end
    return new_gui
end

function game_node:create_main_gui(unit_number)
    local root = game_node:new(unit_number)
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

function node:setup_events(node_param)
    if not node_param.events_id then
        return
    elseif node_param.events_id.on_click then
        if node_param.events_id.on_click == "on_click_new_task_button" then
            node_param.events.on_click = node.on_click_new_task_button
        elseif node_param.events_id.on_click == "on_click_play_button" then
            node_param.events.on_click = node.on_click_play_button
        elseif node_param.events_id.on_click == "on_click_close_button" then
            node_param.events.on_click = node.on_click_close_button
        elseif node_param.events_id.on_click == "on_click_close_sub_button" then
            node_param.events.on_click = node.on_click_close_sub_button
        end
    elseif node_param.events_id.on_selection_state_changed then
        if node_param.events_id.on_selection_state_changed == "on_selection_changed_task_dropdown" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_repeatable_timer
            node_param.events.on_selection_state_changed[2] = node.on_selection_single_timer
        elseif node_param.events_id.on_selection_state_changed == "on_selection_changed_subtask_dropdown" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_constant_combinator
            node_param.events.on_selection_state_changed[2] = node.on_selection_arithmetic_combinator
        end
    end
end

function node.on_click_new_task_button(event, node_param)
    if event.element.parent[node_param.events_params.task_dropdown_frame_id].visible then
        event.element.parent[node_param.events_params.task_dropdown_frame_id].visible = false
    else
        event.element.parent[node_param.events_params.task_dropdown_frame_id].visible = true
    end
end

function node.on_click_close_button(event, node_param)
    node_param.parent.parent.parent:remove()
    event.element.parent.parent.parent.destroy()
end

function node.on_click_close_sub_button(event, node_param)
    if table_size(event.element.parent.parent.children) == 1 then
        node_param.parent.parent.gui.visible = false
        event.element.parent.parent.visible = false
    end
    node_param.parent:remove()
    event.element.parent.destroy()
end

function node.on_click_play_button(event, node_param)
    if event.element.sprite == "utility/play" then
        event.element.sprite = "utility/stop"
        event.element.hovered_sprite = "utility/stop"
        event.element.clicked_sprite = "utility/stop"
        node_param.gui.sprite = "utility/stop"
        node_param.gui.hovered_sprite = "utility/stop"
        node_param.gui.clicked_sprite = "utility/stop"
    else
        event.element.sprite = "utility/play"
        event.element.hovered_sprite = "utility/play"
        event.element.clicked_sprite = "utility/play"
        node_param.gui.sprite = "utility/play"
        node_param.gui.hovered_sprite = "utility/play"
        node_param.gui.clicked_sprite = "utility/play"
    end
end

function node.on_selection_repeatable_timer(event, node_param)
    event.element.parent.visible = false
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local scroll_pane_node = node_param.parent.parent
    local scroll_pane_gui = event.element.parent.parent

    local vertical_flow_node = scroll_pane_node:add_child()
    vertical_flow_node.gui = {
        type = "flow",
        direction = "vertical",
        name = vertical_flow_node.id,
        style = constants.style.group_vertical_flow_frame,
    }

    ------------------------------ Frame Area 1 ---------------------------------
    local repeatable_time_node = vertical_flow_node:add_child()
    repeatable_time_node.gui = {
        type = "progressbar",
        direction = "vertical",
        name = repeatable_time_node.id,
        style = constants.style.conditional_progress_frame,
        value = 1
    }

    local repeatable_time_flow_node = repeatable_time_node:add_child()
    repeatable_time_flow_node.gui = {
        type = "flow",
        direction = "horizontal",
        name = repeatable_time_flow_node.id,
        style = constants.style.conditional_flow_frame,
    }

    local play_button_node = repeatable_time_flow_node:add_child()
    play_button_node.gui = {
        type = "sprite-button",
        direction = "vertical",
        name = play_button_node.id,
        style = constants.style.play_button_frame,
        sprite = "utility/play",
        hovered_sprite = "utility/play",
        clicked_sprite = "utility/stop"
    }
    play_button_node.events_id.on_click = "on_click_play_button"

    local label_node = repeatable_time_flow_node:add_child()
    label_node.gui = {
        type = "label",
        direction = "vertical",
        name = label_node.id,
        style = constants.style.label_frame,
        caption = "Repeatable Timer"
    }

    local time_selection_node = repeatable_time_flow_node:add_child()
    time_selection_node.gui = {
        type = "button",
        direction = "vertical",
        name = time_selection_node.id,
        style = constants.style.time_selection_node_frame,
        caption = "600 s"
    }

    local close_button_node = repeatable_time_flow_node:add_child()
    close_button_node.gui = {
        type = "sprite-button",
        direction = "vertical",
        name = close_button_node.id,
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black"
    }
    close_button_node.events_id.on_click = "on_click_close_button"
    ------------------------------ Frame Area 2 ---------------------------------
    local repeatable_sub_tasks_flow = vertical_flow_node:add_child()
    repeatable_sub_tasks_flow.gui = {
        type = "flow",
        direction = "vertical",
        name = repeatable_sub_tasks_flow.id,
        style = constants.style.sub_group_vertical_flow_frame,
        visible = false
    }

    ------------------------------ Frame Area 3 ---------------------------------
    local new_sub_task_button = vertical_flow_node:add_child()
    new_sub_task_button.gui = {
        type = "button",
        name = new_sub_task_button.id,
        style = constants.style.large_options_button_frame,
        caption = "+ Add Sub-Task"
    }

    ------------------------------ Frame Area 4 ---------------------------------
    local task_dropdown_frame = vertical_flow_node:add_child()
    task_dropdown_frame.gui = {
        type = "frame",
        direction = "vertical",
        name = task_dropdown_frame.id,
        style = constants.style.dropdown_subtask_options_frame,
        visible = false
    }
    new_sub_task_button.events_id.on_click = "on_click_new_task_button"
    new_sub_task_button.events_params = { task_dropdown_frame_id = task_dropdown_frame.id}

    local task_dropdown_list = task_dropdown_frame:add_child()
    task_dropdown_list.gui = {
        type = "list-box",
        name = task_dropdown_list.id,
        style = constants.style.options_list,
        items = {"Constant Combinator", "Arithmetic Combinator"}    
    }
    task_dropdown_list.events_id.on_selection_state_changed = "on_selection_changed_subtask_dropdown"
    task_dropdown_list.events_params = { repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id }
    ------------------------------------------------------------------------------

    -- Setup Node Events --
    scroll_pane_node:recursive_setup_events()

    -- Setup Factorio GUI --
    game_node:buildGuiNodes(scroll_pane_gui, vertical_flow_node)
end

function node.on_selection_single_timer(event, node_param)
    event.element.parent.visible = false
    event.element.selected_index = 0
end

function node.on_selection_constant_combinator(event, node_param)
    event.element.parent.visible = false
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local vertical_flow_node = node_param.parent.parent.parent
    local vertical_flow_gui = event.element.parent.parent.parent

    local sub_tasks_flow = vertical_flow_node:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)

    if not sub_tasks_flow.gui_element.visible then
        sub_tasks_flow.gui.visible = true
        sub_tasks_flow.gui_element.visible = true
    end

    local repeatable_time_node = sub_tasks_flow:add_child()
    repeatable_time_node.gui = {
        type = "frame",
        direction = "horizontal",
        name = repeatable_time_node.id,
        style = constants.style.sub_conditional_frame
    }

    local close_button_node = repeatable_time_node:add_child()
    close_button_node.gui = {
        type = "sprite-button",
        direction = "vertical",
        name = close_button_node.id,
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black"
    }
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    
    -- Setup Node Events --
    repeatable_time_node:recursive_setup_events()

    -- Setup Factorio GUI --
    game_node:buildGuiNodes(sub_tasks_flow.gui_element, repeatable_time_node)
end

function node.on_selection_arithmetic_combinator(event, node_param)
    event.element.parent.visible = false
    event.element.selected_index = 0
end


return game_node