local node = require("node")
local constants = require("constants")
local logger = require("logger")
local overlay_gui = require("overlay_gui")

local function print_children(element, index)
    local str = ""

    for i=1,index do
        str = str.."    "
    end

    index = index + 1
    logger.print(str.."name: "..element.name.." type: "..element.type)
    for _, child in pairs(element.children) do
        print_children(child, index)
    end
end

function node:setup_timer(repeatable, active, max_value)
    self.update_logic =
    {
        timer = true,
        repeatable = repeatable,
        active = active,
        value = 0,
        max_value = max_value
    }
end

function node:setup_constant_combinator()
    self.update_logic =
    {
        constant_combinator = true,
        signal_slot_1 = nil,
        sign_index = 1,
        signal_slot_2 = nil,
        value_slot_2 = nil,
        signal_result = nil,
        output_value = false
    }
end

function node:setup_arithmetic_combinator()
    self.update_logic =
    {
        arithmetic_combinator = true,
        signal_slot_1 = nil,
        sign_index = 1,
        signal_slot_2 = nil,
        value_slot_2 = nil,
        signal_result = nil
    }
end

function node:safely_add_gui_child(parent, style)
    for _, child in pairs(parent.children) do
        if child == name then
            return child
        end
    end
    return parent.add(style)
end

function node:build_gui_nodes(parent, node_param)
    local new_gui = node:safely_add_gui_child(parent, node_param.gui)
    node_param.gui_element = new_gui

    if node_param.gui.elem_value then
        new_gui.elem_value = node_param.gui.elem_value
    end
    if node_param.gui.locked then
        new_gui.locked = true
    end

    for _, child in pairs(node_param.children) do
        node:build_gui_nodes(new_gui, child)
    end

    if node_param.gui.type == "tabbed-pane" then
        local tab = nil
        for _, child in pairs(node_param.children) do
            if not tab then
                tab = child
            else
                node_param.gui_element.add_tab(tab.gui_element, child.gui_element)
                tab = nil
            end
        end

        node_param.gui_element.selected_tab_index = node_param.events_params.selected_tab_index
    end

    return new_gui
end

function node:create_main_gui(unit_number)
    local root = node:new(unit_number, {
        type = "frame",
        direction = "vertical",
        style = constants.style.main_frame,
        caption = "MAIN FRAME "..unit_number
    })

    local inner_mane_frame = root:add_child({
        type = "frame",
        style = "inside_deep_frame"
    })

    local tabbed_pane = inner_mane_frame:add_child({
        type = "tabbed-pane",
        direction = "horizontal",
        style = constants.style.main_tabbed_pane
    })
    -- TEMP -- Open Second tab by default
    tabbed_pane.events_params = {selected_tab_index = 2}
    

    local combinators_tab = tabbed_pane:add_child({
        type = "tab",
        direction = "vertical",
        caption = "Combinators"
    })

    local combinators_tasks_area = tabbed_pane:add_child({
        type = "frame",
        direction = "vertical",
        style = constants.style.tasks_frame
    })

    local combinators_scroll_pane = combinators_tasks_area:add_child({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.scroll_pane
    })


    local timer_tab = tabbed_pane:add_child({
        type = "tab",
        direction = "vertical",
        caption = "Timers"
    })

    local timers_tasks_area = tabbed_pane:add_child({
        type = "frame",
        direction = "vertical",
        style = constants.style.tasks_frame
    })

    local timers_scroll_pane = timers_tasks_area:add_child({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.scroll_pane
    })

    local new_task_dropdown_node = timers_scroll_pane:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.task_dropdown_frame,
        items = { "Continuously Repeatable Timer", "Callable Timer", "Callable Timer"}
    })
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_task_dropdown"

    local overlay_node = new_task_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = "+ Add Timer"
    })

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
        elseif node_param.events_id.on_click == "on_click_radiobutton_constant_combinator_one" then
                node_param.events.on_click = node.on_click_radiobutton_constant_combinator_one
        elseif node_param.events_id.on_click == "on_click_radiobutton_constant_combinator_all" then
                node_param.events.on_click = node.on_click_radiobutton_constant_combinator_all
        elseif node_param.events_id.on_click == "on_click_open_signal" then
            node_param.events.on_click = node.on_click_open_signal
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
            node_param.events.on_selection_state_changed[3] = node.on_selection_single_timer
        elseif node_param.events_id.on_selection_state_changed == "on_selection_changed_subtask_dropdown" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_constant_combinator
            node_param.events.on_selection_state_changed[2] = node.on_selection_arithmetic_combinator
        elseif node_param.events_id.on_selection_state_changed == "on_selection_combinator_changed" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[2] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[3] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[4] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[5] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[6] = node.on_selection_combinator_changed
        elseif node_param.events_id.on_selection_state_changed == "on_selection_arithmetic_changed" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[2] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[3] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[4] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[5] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[6] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[7] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[8] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[9] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[10] = node.on_selection_combinator_changed
            node_param.events.on_selection_state_changed[11] = node.on_selection_combinator_changed
        end
    end
end

function node.on_click_close_button(event, node_param)
    local entity_id_copy = node_param.entity_id
    node_param.parent.parent.parent:remove()
    event.element.parent.parent.parent.destroy()
end

function node.on_click_close_sub_button(event, node_param)
    if table_size(event.element.parent.parent.children) == 1 then
        node_param.parent.parent.gui.visible = false
        event.element.parent.parent.visible = false
    end

    local progressbar_node = node_param.parent.parent.parent:recursive_find(node_param.events_params.progressbar_node_id)
    node_param.parent:update_list_child_remove(progressbar_node)
    node_param.parent:remove()
    event.element.parent.destroy()
end

function node.on_click_play_button(event, node_param)

    local function set_sprites(element, sprite)
        element.sprite = sprite
        element.hovered_sprite = sprite
        element.clicked_sprite = sprite
    end

    local function set_ignore_by_interaction(node, value)
        node.gui.ignored_by_interaction = value
        node.gui_element.ignored_by_interaction = value
    end

    local main_vertical_flow = node_param.parent.parent.parent
    local progressbar_node = node_param.parent.parent
    local timebox_node = node_param.parent:recursive_find(node_param.events_params.time_selection_node_id)

    local repeatable_sub_tasks_node = main_vertical_flow.parent:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)
    local new_task_dropdown_node = main_vertical_flow.parent:recursive_find(node_param.events_params.new_task_dropdown_node_id)

    progressbar_node.update_logic.value = 0
    progressbar_node.gui_element.value = 0

    if progressbar_node.update_logic.active then
        progressbar_node.update_logic.active = false
        set_ignore_by_interaction(timebox_node, false)
        set_ignore_by_interaction(repeatable_sub_tasks_node, false)
        set_ignore_by_interaction(new_task_dropdown_node, false)
        set_sprites(event.element, "utility/play")
        set_sprites(node_param.gui, "utility/play")
    else
        progressbar_node.update_logic.active = true
        set_ignore_by_interaction(timebox_node, true)
        set_ignore_by_interaction(repeatable_sub_tasks_node, true)
        set_ignore_by_interaction(new_task_dropdown_node, true)
        set_sprites(event.element, "utility/stop")
        set_sprites(node_param.gui, "utility/stop")
    end

end

function node.on_text_change_time(event, node_param)
    local number = tonumber(event.element.text) 

    if not number then
        node_param.gui.text = nil
        node_param.parent.parent.update_logic.max_value = 0
    else
        node_param.gui.text = event.element.text
        node_param.parent.parent.update_logic.max_value = number * 60
    end
end

function node.on_text_changed_constant_slot_1(event, node_param)
    local number = tonumber(event.element.caption)

    if not number then
        node_param.gui.caption = nil
        node_param.parent.parent.update_logic.value_slot_1 = nil
    else
        node_param.gui.caption = event.element.caption
        node_param.parent.parent.update_logic.value_slot_1 = number
    end    
end

function node.on_text_changed_constant_slot_2(event, node_param)
    local number = tonumber(event.element.caption)

    if not number then
        node_param.gui.caption = nil
        node_param.parent.parent.update_logic.value_slot_2 = nil
    else
        node_param.gui.caption = event.element.caption
        node_param.parent.parent.update_logic.value_slot_2 = number
    end    
end

function node.on_signal_changed_1(event, node_param)
    node_param.gui.elem_value = event.element.elem_value
    node_param.parent.parent.update_logic.signal_slot_1 = event.element.elem_value
end

function node.on_signal_changed_2(event, node_param)
    node_param.gui.elem_value = event.element.elem_value
    node_param.parent.parent.update_logic.signal_slot_2 = event.element.elem_value
end

function node.on_signal_changed_result(event, node_param)
    node_param.gui.elem_value = event.element.elem_value
    node_param.parent.update_logic.signal_result = event.element.elem_value
end

function node:on_signal_confirm_change(event)
    if self.events_params.signal_type == "left_signal" then
        node.on_signal_changed_1(event, self)
    elseif self.events_params.signal_type == "left_constant" then
        node.on_text_changed_constant_slot_1(event, self)
    elseif self.events_params.signal_type == "right_signal" then
        node.on_signal_changed_2(event, self)
    elseif self.events_params.signal_type == "right_constant" then
        node.on_text_changed_constant_slot_2(event, self)
    elseif self.events_params.signal_type == "result_signal" then 
        node.on_signal_changed_result(event, self)
    end
end

function node.on_selection_combinator_changed(event, node_param)
    node_param.gui.selected_index = event.element.selected_index
    node_param.parent.update_logic.sign_index = event.element.selected_index
end

function node.on_click_radiobutton_constant_combinator_one(event, node_param)

    local radio_parent = event.element.parent
    local other_radio_node = node_param.parent:recursive_find(node_param.events_params.other_radio_button)

    radio_parent[node_param.events_params.other_radio_button].state = false
    other_radio_node.gui.state = false
    node_param.gui.state = true

    node_param.parent.parent.update_logic.output_value = false
end

function node.on_click_radiobutton_constant_combinator_all(event, node_param)

    local radio_parent = event.element.parent
    local other_radio_node = node_param.parent:recursive_find(node_param.events_params.other_radio_button)

    radio_parent[node_param.events_params.other_radio_button].state = false
    other_radio_node.gui.state = false
    node_param.gui.state = true

    node_param.parent.parent.update_logic.output_value = true
end

function node.on_selection_repeatable_timer(event, node_param)
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local scroll_pane_node = node_param.parent
    local scroll_pane_gui = event.element.parent

    local vertical_flow_node = scroll_pane_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.group_vertical_flow_frame,
    })

    ------------------------------ Frame Area 1 ---------------------------------
    local repeatable_time_node = vertical_flow_node:add_child({
        type = "progressbar",
        direction = "vertical",
        style = constants.style.conditional_progress_frame,
        value = 0
    })
    repeatable_time_node:setup_timer(true, false, 600)
    repeatable_time_node:update_list_push()

    local repeatable_time_flow_node = repeatable_time_node:add_child({
        type = "flow",
        direction = "horizontal",
        style = constants.style.conditional_flow_frame,
    })

    local play_button_node = repeatable_time_flow_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.play_button_frame,
        sprite = "utility/play",
        hovered_sprite = "utility/play",
        clicked_sprite = "utility/stop"
    })

    local label_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.repeatable_begining_label_frame,
        caption = "Repeat every"
    })

    local time_selection_node = repeatable_time_flow_node:add_child({
        type = "textfield",
        direction = "vertical",
        style = constants.style.time_selection_frame,
        numeric = true,
        allow_decimal = true,
        allow_negative = false,
        lose_focus_on_confirm = true,
        text = "10"
    })
    time_selection_node.events_id.on_gui_text_changed = "on_text_change_time"
    play_button_node.events_id.on_click = "on_click_play_button"

    local padding_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.repeatable_end_label_frame,
        caption = "seconds"
    })

    local close_button_node = repeatable_time_flow_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black"
    })
    close_button_node.events_id.on_click = "on_click_close_button"
    ------------------------------ Frame Area 2 ---------------------------------
    local repeatable_sub_tasks_flow = vertical_flow_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.sub_group_vertical_flow_frame,
        visible = false
    })
    ------------------------------ Frame Area 3 ---------------------------------
    local new_task_dropdown_node = vertical_flow_node:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.subtask_dropdown_frame,
        items =
        {
            "Constant Combinator",
            "Arithmetic Combinator",
        }
    })
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_subtask_dropdown"
    new_task_dropdown_node.events_params =
    {
        repeatable_time_node_id = repeatable_time_node.id,
        repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id
    }

    local overlay_node = new_task_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = "+ Add Combinator"
    })
    play_button_node.events_params =
    {
        time_selection_node_id = time_selection_node.id,
        repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id,
        new_task_dropdown_node_id = new_task_dropdown_node.id
    }
    ------------------------------------------------------------------------------
    
    -- Setup Node Events --
    scroll_pane_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(scroll_pane_gui, vertical_flow_node)
end

function node.on_selection_single_timer(event, node_param)
    event.element.selected_index = 0
end

function node.on_selection_constant_combinator(event, node_param)

    -- Setup Persistent Nodes --
    local progressbar_node = node_param.parent.children[node_param.events_params.repeatable_time_node_id]
    local vertical_flow_node = node_param.parent
    local vertical_flow_gui = event.element.parent

    local sub_tasks_flow = vertical_flow_node:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)

    if not sub_tasks_flow.gui_element.visible then
        sub_tasks_flow.gui.visible = true
        sub_tasks_flow.gui_element.visible = true
    end

    --------------------------------------------------------
    local repeatable_time_node = sub_tasks_flow:add_child({
        type = "frame",
        direction = "horizontal",
        style = constants.style.sub_conditional_frame
    })
    repeatable_time_node:setup_constant_combinator()
    repeatable_time_node:update_list_child_push(progressbar_node)
    --------------------------------------------------------

    local left_signal_flow_node = node.create_signal_constant(
        repeatable_time_node,
        true,
        {
            signal_type = "left_signal",
            constant_type = "left_constant"
        }
    )

    --------------------------------------------------------

    local constant_menu_node = repeatable_time_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.condition_comparator_dropdown_frame,
        selected_index = 1,
        items = { ">", "<", "=", "≥", "≤", "≠" }
    })
    constant_menu_node.events_id.on_selection_state_changed = "on_selection_combinator_changed"

    --------------------------------------------------------

    local right_signal_flow_node = node.create_signal_constant(
        repeatable_time_node,
        true,
        {
            signal_type = "right_signal",
            constant_type = "right_constant"
        }
    )

    --------------------------------------------------------

    local equals_sprite_node = repeatable_time_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        sprite = "advanced-combinator-sprites-equals-white",
        hovered_sprite = "advanced-combinator-sprites-equals-white",
        clicked_sprite = "advanced-combinator-sprites-equals-white",
        style = constants.style.invisible_frame,
        ignored_by_interaction = true
    })


    local result_signal_flow_node = node.create_signal_constant(
        repeatable_time_node,
        false,
        {
            signal_type = "result_signal",
        }
    )

    --------------------------------------------------------
    local radio_group_node = repeatable_time_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.radio_vertical_flow_frame
    })

    local radio_button_1 = radio_group_node:add_child({
        type = "radiobutton",
        style = constants.style.radiobutton_frame,
        caption = "1",
        state = true
    })
    radio_button_1.events_id.on_click = "on_click_radiobutton_constant_combinator_one"

    local radio_button_2 = radio_group_node:add_child({
        type = "radiobutton",
        style = constants.style.radiobutton_frame,
        caption = "Input count",
        state = false
    })
    radio_button_2.events_id.on_click = "on_click_radiobutton_constant_combinator_all"

    radio_button_1.events_params = { other_radio_button = radio_button_2.id }
    radio_button_2.events_params = { other_radio_button = radio_button_1.id }
    --------------------------------------------------------
    local close_button_node = repeatable_time_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
    })
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    close_button_node.events_params = { progressbar_node_id = progressbar_node.id }
    --------------------------------------------------------

    -- Reset dropdown selection index --
    event.element.selected_index = 0
    
    -- Setup Node Events --
    repeatable_time_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(sub_tasks_flow.gui_element, repeatable_time_node)
end

function node.on_selection_arithmetic_combinator(event, node_param)

    -- Setup Persistent Nodes --
    local progressbar_node = node_param.parent.children[node_param.events_params.repeatable_time_node_id]
    local vertical_flow_node = node_param.parent
    local vertical_flow_gui = event.element.parent

    local sub_tasks_flow = vertical_flow_node:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)

    if not sub_tasks_flow.gui_element.visible then
        sub_tasks_flow.gui.visible = true
        sub_tasks_flow.gui_element.visible = true
    end

    --------------------------------------------------------
    local repeatable_time_node = sub_tasks_flow:add_child({
        type = "frame",
        direction = "horizontal",
        style = constants.style.sub_conditional_frame
    })
    repeatable_time_node:setup_arithmetic_combinator()
    repeatable_time_node:update_list_child_push(progressbar_node)
    --------------------------------------------------------

    local left_signal_flow_node = node.create_signal_constant(
        repeatable_time_node,
        true,
        {
            signal_type = "left_signal",
            constant_type = "left_constant"
        }
    )

    --------------------------------------------------------

    local arithmetic_menu_node = repeatable_time_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.condition_comparator_dropdown_frame,
        selected_index = 1,
        items = { "*", "/", "+", "-", "%", "^", "<<", ">>", "AND", "OR", "XOR" }
    })
    arithmetic_menu_node.events_id.on_selection_state_changed = "on_selection_arithmetic_changed"

    --------------------------------------------------------

    local right_signal_flow_node = node.create_signal_constant(
        repeatable_time_node,
        true,
        {
            signal_type = "right_signal",
            constant_type = "right_constant"
        }
    )

    --------------------------------------------------------

    local equals_sprite_node = repeatable_time_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        sprite = "advanced-combinator-sprites-equals-white",
        hovered_sprite = "advanced-combinator-sprites-equals-white",
        clicked_sprite = "advanced-combinator-sprites-equals-white",
        style = constants.style.invisible_frame,
        ignored_by_interaction = true
    })

    local result_signal_flow_node = node.create_signal_constant(
        repeatable_time_node,
        false,
        {
            signal_type = "result_signal",
        }
    )

    --------------------------------------------------------
    local close_padding_node = repeatable_time_node:add_child({
        type = "empty-widget",
        direction = "vertical",
        style = constants.style.combinator_horizontal_padding_frame
    })

    local close_button_node = repeatable_time_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
    })
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    close_button_node.events_params = { progressbar_node_id = progressbar_node.id }
    --------------------------------------------------------

    -- Reset dropdown selection index --
    event.element.selected_index = 0
    
    -- Setup Node Events --
    repeatable_time_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(sub_tasks_flow.gui_element, repeatable_time_node)
end  

function node.create_signal_constant(parent_node, create_constant, types)

    if not create_constant then
        local signal_node = parent_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",        
            style = constants.style.dark_button_frame,
            elem_type = "signal",
            locked = true,
        })
        signal_node.events_id.on_click = "on_click_open_signal"
        signal_node.events_params =
        {
            constant_pane = false,
            signal_type = types.signal_type
        }

        return signal_node
    else
        local flow_node = parent_node:add_child({
            type = "flow",
            direction = "horizontal",
        })

        local signal_node = flow_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",        
            style = constants.style.dark_button_frame,
            elem_type = "signal",
            locked = true,
        })
        signal_node.events_id.on_click = "on_click_open_signal"

        local constant_node = flow_node:add_child({
            type = "button",
            direction = "vertical",        
            style = constants.style.dark_button_frame,
            tooltip = "Constant number",
            ignored_by_interaction = true,
            visible = false
        })
        constant_node.events_id.on_click = "on_click_open_signal"
        constant_node.events_params =
        {
            other_node_id = signal_node.id,
            constant_pane = true,
            signal_type = types.constant_type
        }
        signal_node.events_params =
        {
            other_node_id = constant_node.id,
            constant_pane = true,
            signal_type = types.signal_type
        }
        return flow_node
    end
end

function node.on_click_open_signal(event, node_param)
    if event.button == defines.mouse_button_type.left then
        if not overlay_gui.has_opened_signals_node() then

            overlay_gui.create_gui(
                event.player_index,
                node_param,
                (event.element.type == "choose-elem-button") and event.element.elem_value or nil,
                {
                    {type="virtual", name="signal-everything"},
                    {type="virtual", name="signal-anything"},
                    {type="virtual", name="signal-each"}
                }
            )

            local root_node = global.entities[node_param.entity_id].node
            if root_node.gui_element.location then
                overlay_gui.configure_location(root_node.gui_element.location)
            end
        end
    elseif event.button == defines.mouse_button_type.right then
        if event.element.type == "choose-elem-button" then     
            node_param.gui.elem_value = nil
            event.element.elem_value = nil
        else
            node_param.gui.caption = ""
            event.element.caption = ""
        end
    end
end

return node