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

function game_node:build_gui_nodes(parent, node_param)
    local new_gui = game_node:safely_add_gui_child(parent, node_param.gui)
    node_param.gui_element = new_gui

    -- Update Gui from persistent data
    if node_param.logic then
        if node_param.logic.enabled ~= nil then
            node_param.gui_element.enabled = node_param.logic.enabled
        end

        if node_param.gui_element.type == "textfield" and node_param.logic.max_value ~= nil then
            node_param.gui_element.text = tostring(node_param.logic.max_value / 60)
        end
    end

    for _, child in pairs(node_param.children) do
        game_node:build_gui_nodes(new_gui, child)
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

    local new_task_dropdown_node = scroll_pane:add_child()
    new_task_dropdown_node.gui = {
        type = "drop-down",
        direction = "horizontal",
        name = new_task_dropdown_node.id,
        style = constants.style.task_dropdown_frame,
        items = { "Repeatable Timer", "Single Use Timer" }
    }
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_task_dropdown"

    local overlay_node = new_task_dropdown_node:add_child()
    overlay_node.gui = {
        type = "label",
        direction = "vertical",
        name = overlay_node.id,
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = "+ Add Task"
    } 

    root:recursive_setup_events()
    return root
end

function node:setup_events(node_param)
    if not node_param.events_id then
        return
    elseif node_param.events_id.on_click then
        if node_param.events_id.on_click == "on_click_play_button" then
            node_param.events.on_click = node.on_click_play_button
        elseif node_param.events_id.on_click == "on_click_close_button" then
            node_param.events.on_click = node.on_click_close_button
        elseif node_param.events_id.on_click == "on_click_close_sub_button" then
            node_param.events.on_click = node.on_click_close_sub_button
        elseif node_param.events_id.on_click == "on_click_radiobutton_constant_combinator" then
            node_param.events.on_click = node.on_click_radiobutton_constant_combinator
        end
    elseif node_param.events_id.on_gui_text_changed then
        if node_param.events_id.on_gui_text_changed == "on_text_change_time" then
            node_param.events.on_gui_text_changed = node.on_text_change_time
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

    local function set_sprites(element, sprite)
        element.sprite = sprite
        element.hovered_sprite = sprite
        element.clicked_sprite = sprite
    end

    local progressbar_node = node_param.parent.parent
    local progressbar_gui = event.element.parent.parent
    local timebox_node = node_param.parent:recursive_find(node_param.events_params.time_selection_node_id)
    local timebox_gui = event.element.parent[node_param.events_params.time_selection_node_id]
    
    progressbar_node.logic.value = 0
    progressbar_gui.value = 0

    if progressbar_node.logic.active then
        progressbar_node.logic.active = false
        timebox_gui.ignored_by_interaction = false
        timebox_node.logic.enabled = true
        set_sprites(event.element, "utility/play")
        set_sprites(node_param.gui, "utility/play")
    else
        progressbar_node.logic.active = true
        timebox_gui.ignored_by_interaction = true
        timebox_node.logic.enabled = false
        set_sprites(event.element, "utility/stop")
        set_sprites(node_param.gui, "utility/stop")
    end

end

function node.on_text_change_time(event, node_param)
    local number = tonumber(event.element.text) 

    if not number then
        node_param.logic.max_value = 0
        node_param.parent.parent.logic.max_value = 0
    else
        node_param.logic.max_value = number * 60
        node_param.parent.parent.logic.max_value = node_param.logic.max_value
    end
end

function node.on_selection_repeatable_timer(event, node_param)
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local scroll_pane_node = node_param.parent
    local scroll_pane_gui = event.element.parent

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
        value = 0
    }
    repeatable_time_node.logic = {
        timer = true,
        repeatable = true,
        active = false,
        max_value = 600,
        value = 0
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

    local label_node = repeatable_time_flow_node:add_child()
    label_node.gui = {
        type = "label",
        direction = "vertical",
        name = label_node.id,
        style = constants.style.repeatable_begining_label_frame,
        caption = "Repeat every"
    }

    local time_selection_node = repeatable_time_flow_node:add_child()
    time_selection_node.gui = {
        type = "textfield",
        direction = "vertical",
        name = time_selection_node.id,
        style = constants.style.time_selection_frame,
        numeric = true,
        allow_decimal = true,
        allow_negative = false,
        lose_focus_on_confirm = true,
        text = "10"
    }
    time_selection_node.events_id.on_gui_text_changed = "on_text_change_time"
    time_selection_node.logic = { enabled = true, max_value = 600 }
    play_button_node.events_id.on_click = "on_click_play_button"
    play_button_node.events_params = { time_selection_node_id = time_selection_node.id }

    local padding_node = repeatable_time_flow_node:add_child()
    padding_node.gui = {
        type = "label",
        direction = "vertical",
        name = padding_node.id,
        style = constants.style.repeatable_end_label_frame,
        caption = "seconds"
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
    local new_task_dropdown_node = vertical_flow_node:add_child()
    new_task_dropdown_node.gui = {
        type = "drop-down",
        direction = "horizontal",
        name = new_task_dropdown_node.id,
        style = constants.style.subtask_dropdown_frame,
        items = {"Constant Combinator", "Arithmetic Combinator"}
    }
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_subtask_dropdown"
    new_task_dropdown_node.events_params = { repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id }

    local overlay_node = new_task_dropdown_node:add_child()
    overlay_node.gui = {
        type = "label",
        direction = "vertical",
        name = overlay_node.id,
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = "+ Add Subtask"
    }
    ------------------------------------------------------------------------------

    -- Setup Node Events --
    scroll_pane_node:recursive_setup_events()

    -- Setup Factorio GUI --
    game_node:build_gui_nodes(scroll_pane_gui, vertical_flow_node)
end

function node.on_selection_single_timer(event, node_param)
    event.element.selected_index = 0
end

function node.on_selection_constant_combinator(event, node_param)
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local vertical_flow_node = node_param.parent
    local vertical_flow_gui = event.element.parent

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

    local signal_button_1_node = repeatable_time_node:add_child()
    signal_button_1_node.gui = {
        type = "choose-elem-button",
        elem_type = "signal",
        direction = "vertical",
        name = signal_button_1_node.id,
        style = constants.style.dark_button_frame,
    }

    local constant_menu_node = repeatable_time_node:add_child()
    constant_menu_node.gui = {
        type = "drop-down",
        direction = "vertical",
        name = constant_menu_node.id,
        style = constants.style.condition_comparator_dropdown_frame,
        selected_index = 1,
        items = { ">", "<", "=", "≥", "≤", "≠" }
    }
    -- "*" "/" "+" "-" "%" "^" "<<" ">>" "AND" "OR" "XOR"

    local signal_button_2_node = repeatable_time_node:add_child()
    signal_button_2_node.gui = {
        type = "choose-elem-button",
        elem_type = "signal",
        direction = "vertical",
        name = signal_button_2_node.id,
        style = constants.style.dark_button_frame,
    }

    local equals_sprite_node = repeatable_time_node:add_child()
    equals_sprite_node.gui = {
        type = "sprite-button",
        direction = "vertical",
        name = equals_sprite_node.id,
        sprite = "advanced-combinator-sprites-equals-white",
        hovered_sprite = "advanced-combinator-sprites-equals-white",
        clicked_sprite = "advanced-combinator-sprites-equals-white",
        style = constants.style.invisible_frame,
        ignored_by_interaction = true
    }

    local signal_result_node = repeatable_time_node:add_child()
    signal_result_node.gui = {
        type = "choose-elem-button",
        elem_type = "signal",
        direction = "vertical",
        name = signal_result_node.id,
        style = constants.style.dark_button_frame,
    }

    --------------------------------------------------------
    local radio_group_node = repeatable_time_node:add_child()
    radio_group_node.gui = {
        type = "flow",
        direction = "vertical",
        name = radio_group_node.id,
        style = constants.style.radio_vertical_flow_frame
    }

    local radio_button_1 = radio_group_node:add_child()
    radio_button_1.gui = {
        type = "radiobutton",
        name = radio_button_1.id,
        style = constants.style.radiobutton_frame,
        caption = "1",
        state = true
    }
    radio_button_1.events_id.on_click = "on_click_radiobutton_constant_combinator"

    local radio_button_2 = radio_group_node:add_child()
    radio_button_2.gui = {
        type = "radiobutton",
        name = radio_button_2.id,
        style = constants.style.radiobutton_frame,
        caption = "Input count",
        state = false
    }
    radio_button_2.events_id.on_click = "on_click_radiobutton_constant_combinator"

    radio_button_1.events_params = { other_radio_button = radio_button_2.id }
    radio_button_2.events_params = { other_radio_button = radio_button_1.id }
    --------------------------------------------------------
    local close_button_node = repeatable_time_node:add_child()
    close_button_node.gui = {
        type = "sprite-button",
        direction = "vertical",
        name = close_button_node.id,
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
    }
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    
    -- Setup Node Events --
    repeatable_time_node:recursive_setup_events()

    -- Setup Factorio GUI --
    game_node:build_gui_nodes(sub_tasks_flow.gui_element, repeatable_time_node)
end

function node.on_selection_arithmetic_combinator(event, node_param)
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

    local test_node = repeatable_time_node:add_child()
    test_node.gui = {
        type = "drop-down",
        direction = "vertical",
        name = test_node.id,
        style = constants.style.task_dropdown_frame,
        items = { "Combinator 1", "Combinator 2" }
    }

    local overlay = test_node:add_child()
    overlay.gui = {
        type = "label",
        direction = "vertical",
        name = overlay.id,
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = "+ Button"
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
    game_node:build_gui_nodes(sub_tasks_flow.gui_element, repeatable_time_node)
end

function node.on_click_radiobutton_constant_combinator(event, node_param)

    local radio_parent = event.element.parent

    if event.element.state then
        radio_parent[node_param.events_params.other_radio_button].state = false
    else
        radio_parent[node_param.events_params.other_radio_button].state = true
    end
end

return game_node