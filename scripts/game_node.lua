local node = require("node")
local constants = require("constants")
local logger = require("logger")

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

function node:has_opened_signals_node()
    return global.screen_node and global.top_node
end

function node:safely_destory_top_nodes(unit_number)
    if global.screen_node and global.screen_node.entity_id == unit_number then
        if global.screen_node.gui_element then
            global.screen_node.gui_element.destroy()
            global.screen_node.gui_element = nil
        end
        global.screen_node:remove()
        global.screen_node = nil
    end
    if global.top_node and global.top_node.entity_id == unit_number then
        if global.top_node.gui_element then
            global.top_node.gui_element.destroy()
            global.top_node.gui_element = nil
        end
        global.top_node:remove()
        global.top_node = nil
    end
end

function node:destory_top_nodes_and_unselect(player_index, entity_id)
    if global.screen_node then
        if global.screen_node.gui_element then
            global.screen_node.gui_element.destroy()
            global.screen_node.gui_element = nil
        end
        global.screen_node:remove()
        global.screen_node = nil
    end
    if global.top_node then
        if global.top_node.gui_element then
            global.top_node.gui_element.destroy()
            global.top_node.gui_element = nil
        end
        global.top_node:remove()
        global.top_node = nil
    end

    local entity = global.entities[entity_id]
    if entity then
        game.players[player_index].opened = entity.node.gui_element
    end
end

function node.on_click(event, unit_number)

    local name = event.element.name
    local clicked_on_signal = false

    if global.screen_node then
        local node = global.screen_node:recursive_find(name)
        if node and node.events.on_click then
            node.events.on_click(event, node)
            clicked_on_signal = true
        end
    end

    if global.top_node then
        local node = global.top_node:recursive_find(name)
        if node and node.events.on_click then
            node.events.on_click(event, node)
            clicked_on_signal = true
        end
    end

    if clicked_on_signal == false and global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_click then
            node.events.on_click(event, node)
        end
    end
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
    return new_gui
end

function node:create_main_gui(unit_number)
    local root = node:new(unit_number, {
        type = "frame",
        direction = "vertical",
        style = constants.style.main_frame,
        caption = "MAIN FRAME "..unit_number
    })

    local tasks_area = root:add_child({
        type = "frame",
        direction = "vertical",
        style = constants.style.tasks_frame
    })

    local scroll_pane = tasks_area:add_child({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.scroll_pane
    })

    local new_task_dropdown_node = scroll_pane:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.task_dropdown_frame,
        items = { "Repeatable Timer", "Single Use Timer" }
    })
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_task_dropdown"

    local overlay_node = new_task_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = "+ Add Task"
    })

    root:recursive_setup_events()
    return root
end

function node:create_signal_fill_gui(unit_number)
    local root = node:new(unit_number, {
        type = "button",
        direction = "vertical",
        style = constants.style.screen_strech_frame,
    })
    root.events_id.on_click = "on_click_signal_frame_holder"

    root:recursive_setup_events()
    return root
end

function node:create_signal_gui(unit_number)
    local root = node:new(unit_number, {
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_frame,
        caption = "Select a signal"
    })

    local tasks_area = root:add_child({
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_inner_frame
    })

    local scroll_pane = tasks_area:add_child({
        type = "table",
        direction = "horizontal",
        column_count = 6,
        vertical_centering = true,
        style = constants.style.signal_group_frame
    })

    local signals_scroll_pane = tasks_area:add_child({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.signal_subgroup_scroll_frame,
        vertical_scroll_policy = "always",
        horizontal_scroll_policy = "never"
    })
    scroll_pane.events_params = { signals_scroll_pane_id = signals_scroll_pane.id }


    -------------------------------------------------------------------------------
    local function filtered_signal_prototypes(subgroup_name)
        --- Check if the group contains items --
        local signals_group = game.get_filtered_item_prototypes({{filter = "subgroup", subgroup = subgroup_name}})
        if #signals_group ~= 0 then
            return "item", signals_group
        end
     
        --- Check if the group contains fluids --
        if #signals_group == 0 then
            signals_group = game.get_filtered_fluid_prototypes({{filter = "subgroup", subgroup = subgroup_name}})
            if #signals_group ~= 0 then
                return "fluid", signals_group
            end
        end

        --- Check if the group contains signals --
        signals_group = {}
        for _, virtual_signal in pairs(game.virtual_signal_prototypes) do
            if virtual_signal.subgroup.name == subgroup_name then
                table.insert(signals_group, virtual_signal)
            end
        end

        return "virtual", signals_group
    end

    for _, item_group in pairs(game.item_group_prototypes) do
        local signals_table = signals_scroll_pane:add_child({
            type = "table",
            direction = "vertical",
            column_count = 10,
            vertical_centering = true,
            style = constants.style.signal_subgroup_frame,
            subgroup_name = item_group.name,
            visible = (item_group.name == "logistics") and true or false
        })

        for _, sub_group in pairs(item_group.subgroups) do
            local type, signals = filtered_signal_prototypes(sub_group.name)
            local row_items = 1
            for _, signal in pairs(signals) do
                if type == "virtual" or type == "fluid" and signal.hidden == false or signal.has_flag("hidden") == false  then
                    local button_node = signals_table:add_child({
                        type = "choose-elem-button",
                        direction = "vertical",
                        style = constants.style.signal_subgroup_button_frame,
                        elem_type = "signal",
                        elem_value = {type = type, name = signal.name},
                        locked = true
                    })
                    button_node.events_id.on_click = "on_click_select_signal"
                    row_items = row_items + 1
                end
            end

            if row_items ~= 1 then
                local maximum_row_items = row_items + 10 - (row_items % 10)
                for i = row_items, maximum_row_items do
                    local empty_node = signals_table:add_child({
                        type = "empty-widget",
                        direction = "vertical"
                    })
                end
            end
        end

        if table_size(signals_table.children) > 0 then
            local sprite = "advanced-combinator-item-group-"..item_group.name
            local group_button = scroll_pane:add_child({
                type = "sprite-button",
                direction = "vertical",
                style = constants.style.signal_group_button_frame,
                group_name = item_group.name,
                enabled = (item_group.name ~= "logistics") or false,
                sprite = sprite,
                hovered_sprite = sprite,
                clicked_sprite = sprite
            })
            group_button.events_id.on_click = "on_click_change_subgroup"
        else
            signals_table:remove()
        end
    end
    -------------------------------------------------------------------------------

    root:recursive_setup_events()
    return root
end

function node.on_click_change_subgroup(event, node_param)
    logger.print("on_click_change_subgroup")
    if event.element.enabled == false then
        return
    end

    local root_node = node_param.parent.parent
    local parent_gui = event.element.parent
    local parent_node = node_param.parent

    for _, child in pairs(parent_gui.children) do
        if child.name ~= event.element.name then
            child.enabled = true
            parent_node.children[child.name].gui.enabled = true
        end
    end

    event.element.enabled = false
    node_param.gui.enabled = false
    local subgroup_node = root_node:recursive_find(parent_node.events_params.signals_scroll_pane_id)
 
    for _, subgroup in pairs(subgroup_node.children) do
        subgroup.gui.visible = (subgroup.gui.subgroup_name == node_param.gui.group_name) and true or false
        subgroup.gui_element.visible = subgroup.gui.visible
    end
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
        elseif node_param.events_id.on_click == "on_click_signal_frame_holder" then
            node_param.events.on_click = node.on_click_signal_frame_holder
        elseif node_param.events_id.on_click == "on_click_select_signal" then
            node_param.events.on_click = node.on_click_select_signal
        elseif node_param.events_id.on_click == "on_click_change_subgroup" then
            node_param.events.on_click = node.on_click_change_subgroup
        end
    elseif node_param.events_id.on_gui_text_changed then
        if node_param.events_id.on_gui_text_changed == "on_text_change_time" then
            node_param.events.on_gui_text_changed = node.on_text_change_time
        elseif node_param.events_id.on_gui_text_changed == "on_text_changed_constant_slot_1" then
            node_param.events.on_gui_text_changed = node.on_text_changed_constant_slot_1
        elseif node_param.events_id.on_gui_text_changed == "on_text_changed_constant_slot_2" then
            node_param.events.on_gui_text_changed = node.on_text_changed_constant_slot_2
        end
    elseif node_param.events_id.on_gui_elem_changed then
        if node_param.events_id.on_gui_elem_changed == "on_signal_changed_1" then
            node_param.events.on_gui_elem_changed = node.on_signal_changed_1
        elseif node_param.events_id.on_gui_elem_changed == "on_signal_changed_2" then
            node_param.events.on_gui_elem_changed = node.on_signal_changed_2
        elseif node_param.events_id.on_gui_elem_changed == "on_signal_changed_result" then
            node_param.events.on_gui_elem_changed = node.on_signal_changed_result
        end
    elseif node_param.events_id.on_selection_state_changed then
        if node_param.events_id.on_selection_state_changed == "on_selection_changed_task_dropdown" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_repeatable_timer
            node_param.events.on_selection_state_changed[2] = node.on_selection_single_timer
        elseif node_param.events_id.on_selection_state_changed == "on_selection_changed_subtask_dropdown" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = node.on_selection_constant_combinator
            node_param.events.on_selection_state_changed[2] = node.on_selection_constant_combinator
            node_param.events.on_selection_state_changed[3] = node.on_selection_constant_combinator
            node_param.events.on_selection_state_changed[4] = node.on_selection_arithmetic_combinator
            node_param.events.on_selection_state_changed[5] = node.on_selection_arithmetic_combinator
            node_param.events.on_selection_state_changed[6] = node.on_selection_arithmetic_combinator
            node_param.events.on_selection_state_changed[7] = node.on_selection_testing
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
    local number = tonumber(event.element.text)

    if not number then
        node_param.gui.text = nil
        node_param.parent.update_logic.value_slot_1 = nil
    else
        node_param.gui.text = event.element.text
        node_param.parent.update_logic.value_slot_1 = number
    end    
end

function node.on_text_changed_constant_slot_2(event, node_param)
    local number = tonumber(event.element.text)

    if not number then
        node_param.gui.text = nil
        node_param.parent.update_logic.value_slot_2 = nil
    else
        node_param.gui.text = event.element.text
        node_param.parent.update_logic.value_slot_2 = number
    end    
end

function node.on_signal_changed_1(event, node_param)
    node_param.gui.elem_value = event.element.elem_value
    node_param.parent.update_logic.signal_slot_1 = event.element.elem_value
end

function node.on_signal_changed_2(event, node_param)
    node_param.gui.elem_value = event.element.elem_value
    node_param.parent.update_logic.signal_slot_2 = event.element.elem_value
end

function node.on_signal_changed_result(event, node_param)
    node_param.gui.elem_value = event.element.elem_value
    node_param.parent.update_logic.signal_result = event.element.elem_value
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
            "Constant Combinator - Signal <=> Signal",
            "Constant Combinator - Signal <=> Constant",
            "Constant Combinator - Constant <=> Signal",
            "Arithmetic Combinator - Signal <=> Signal",
            "Arithmetic Combinator - Signal <=> Constant",
            "Arithmetic Combinator - Constant <=> Signal",
            "Testing"
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
        caption = "+ Add Subtask"
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

    if event.element.selected_index == 3 then
        local left_button_node = repeatable_time_node:add_child({
            type = "textfield",
            direction = "vertical",
            style = constants.style.dark_textfield_frame,
            numeric = true,
            allow_decimal = false,
            allow_negative = false,
            lose_focus_on_confirm = true
        })
        left_button_node.events_id.on_gui_text_changed = "on_text_changed_constant_slot_1"
    else
        local left_button_node = repeatable_time_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",        
            style = (event.element.selected_index == 1 and constants.style.dark_button_constant_frame or constants.style.dark_button_frame),
            elem_type = "signal",
        })
        left_button_node.events_id.on_gui_elem_changed = "on_signal_changed_1"
    end
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
    if event.element.selected_index == 2 then
        local right_button_node = repeatable_time_node:add_child({
            type = "textfield",
            direction = "vertical",
            style = constants.style.dark_textfield_frame,
            numeric = true,
            allow_decimal = false,
            allow_negative = false,
            lose_focus_on_confirm = true
        })
        right_button_node.events_id.on_gui_text_changed = "on_text_changed_constant_slot_2"
    else
        local right_button_node = repeatable_time_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",
            style = (event.element.selected_index == 1 and constants.style.dark_button_constant_frame or constants.style.dark_button_frame),
            elem_type = "signal",
        })
        right_button_node.events_id.on_gui_elem_changed = "on_signal_changed_2"
    end

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

    local signal_result_node = repeatable_time_node:add_child({
        type = "choose-elem-button",
        direction = "vertical",
        style = constants.style.dark_button_frame,
        elem_type = "signal",
    })
    signal_result_node.events_id.on_gui_elem_changed = "on_signal_changed_result"

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

    if event.element.selected_index == 6 then
        local left_button_node = repeatable_time_node:add_child({
            type = "textfield",
            direction = "vertical",
            style = constants.style.dark_arithmetic_textfield_frame,
            numeric = true,
            allow_decimal = false,
            allow_negative = false,
            lose_focus_on_confirm = true
        })
        left_button_node.events_id.on_gui_text_changed = "on_text_changed_constant_slot_1"
    else
        local left_button_node = repeatable_time_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",        
            style = (event.element.selected_index == 4 and constants.style.dark_button_arithmetic_frame or constants.style.dark_button_frame),
            elem_type = "signal"
        })
        left_button_node.events_id.on_gui_elem_changed = "on_signal_changed_1"
    end

    --------------------------------------------------------

    local arithmetic_menu_node = repeatable_time_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.condition_arithmetic_comparator_dropdown_frame,
        selected_index = 1,
        items = { "*", "/", "+", "-", "%", "^", "<<", ">>", "AND", "OR", "XOR" }
    })
    arithmetic_menu_node.events_id.on_selection_state_changed = "on_selection_arithmetic_changed"

    --------------------------------------------------------

    
    if event.element.selected_index == 5 then
        local right_button_node = repeatable_time_node:add_child({
            type = "textfield",
            direction = "vertical",
            style = constants.style.dark_arithmetic_textfield_frame,
            numeric = true,
            allow_decimal = false,
            allow_negative = false,
            lose_focus_on_confirm = true
        })
        right_button_node.events_id.on_gui_text_changed = "on_text_changed_constant_slot_2"
    else
        local right_button_node = repeatable_time_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",
            style = (event.element.selected_index == 4 and constants.style.dark_button_arithmetic_frame or constants.style.dark_button_frame),
            elem_type = "signal",
        })
        right_button_node.events_id.on_gui_elem_changed = "on_signal_changed_2"
    end

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

    local signal_result_node = repeatable_time_node:add_child({
        type = "choose-elem-button",
        direction = "vertical",
        style = constants.style.dark_button_frame,
        elem_type = "signal",
    })
    signal_result_node.events_id.on_gui_elem_changed = "on_signal_changed_result"

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

function node.on_click_signal_frame_holder(event, node_param)
    node:destory_top_nodes_and_unselect(event.player_index, node_param.entity_id)
end

function node.on_click_open_signal(event, node_param)
    if event.button == defines.mouse_button_type.left then
        if not node:has_opened_signals_node() then
            global.screen_node = node:create_signal_fill_gui(node_param.entity_id)
            global.top_node = node:create_signal_gui(node_param.entity_id)
            global.top_node.events_params = { parent_node_id = node_param.id }

            local player = game.players[event.player_index]
            local screen_gui = node:build_gui_nodes(player.gui.screen, global.screen_node)
            local signal_gui = node:build_gui_nodes(player.gui.screen, global.top_node)
            signal_gui.focus()

            local root_node = global.entities[node_param.entity_id].node
            if root_node.gui_element.location then
                signal_gui.location =
                {
                    x = root_node.gui_element.location.x + 410,
                    y = root_node.gui_element.location.y
                }
            end
        end
    elseif event.button == defines.mouse_button_type.right then
        node_param.gui.elem_value = nil
        event.element.elem_value = nil
    end
end

function node.on_click_select_signal(event, node_param)
    if event.button == defines.mouse_button_type.left and event.element.elem_type and event.element.elem_value then
        local root_node = node_param:root_parent()
        if root_node and global.entities[root_node.entity_id] then
            local node = global.entities[root_node.entity_id].node:recursive_find(root_node.events_params.parent_node_id)
            if node and node.gui.type == "choose-elem-button" then
                node.gui.elem_value = event.element.elem_value
                node.gui_element.elem_value = event.element.elem_value

                node.destory_top_nodes_and_unselect(event.player_index, root_node.entity_id)

                if node.events_id.on_gui_elem_changed then
                    local new_event = { element = node.gui_element }
                    if node.events_id.on_gui_elem_changed == "on_signal_changed_1" then
                        node.on_signal_changed_1(new_event, node)
                    elseif node.events_id.on_gui_elem_changed == "on_signal_changed_2" then
                        node.on_signal_changed_2(new_event, node)
                    elseif node.events_id.on_gui_elem_changed == "on_signal_changed_result" then
                        node.on_signal_changed_result(new_event, node)
                    end
                end
            end
        end
    end
end
    
function node.on_selection_testing(event, node_param)

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
    local repeatable_time_node = sub_tasks_flow:add_child()
    repeatable_time_node.gui = {
        type = "frame",
        direction = "horizontal",
        name = repeatable_time_node.id,
        style = constants.style.sub_conditional_frame
    }
    --------------------------------------------------------

    local button_node = repeatable_time_node:add_child()
    button_node.gui = {
        type = "choose-elem-button",
        --type = "sprite-button",
        direction = "vertical",
        name = button_node.id,
        style = constants.style.dark_button_frame,
        elem_type = "signal",
        locked = true
        --caption = "2G"
    }
    button_node.events_id.on_click = "on_click_open_signal"

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
    close_button_node.events_params = { progressbar_node_id = progressbar_node.id }
    --------------------------------------------------------
    -- Reset dropdown selection index --
    event.element.selected_index = 0

    -- Setup Node Events --
    repeatable_time_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(sub_tasks_flow.gui_element, repeatable_time_node)
end
    
return node