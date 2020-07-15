local constants = require("constants")
local cached_signals = require("cached_signals")
local logger = require("logger")

local overlay_name = "ac_overlay_button"
local group_name = "ac_overlay_group"
local signal_name = "ac_overlay_signal"
local overlay_gui = {}
local loaded = false
local ownder = nil

function overlay_gui.on_load()
    if not loaded then
        if global.screen_node then
            global.screen_node.destroy()
            global.screen_node = nil
        end
        if global.top_node then
            global.top_node.destroy()
            global.top_node = nil
        end
        loaded = true
    end
end

function overlay_gui.has_opened_signals_node()
    return global.screen_node and global.top_node
end

function overlay_gui.on_click(event, entity_id)
    local name = event.element.name

    if name == overlay_name then
        overlay_gui.destory_top_nodes_and_unselect(event.player_index, entity_id)
    elseif string.match(name, "^"..group_name) then
        overlay_gui.on_click_change_subgroup(event, entity_id)
    elseif string.match(name, "^"..signal_name) then
        overlay_gui.on_click_select_signal(event, entity_id)
    end
end

function overlay_gui.safely_destory_top_nodes(unit_number)
    if ownder and ownder.unit_number == unit_number then
        if global.screen_node then
            global.screen_node.destroy()
            global.screen_node = nil
        end
        if global.top_node then
            global.top_node.destroy()
            global.top_node = nil
        end
    end
end

function overlay_gui.destory_top_nodes_and_unselect(player_index, entity_id)
    if global.screen_node then
        global.screen_node.destroy()
        global.screen_node = nil
    end
    if global.top_node then
        global.top_node.destroy()
        global.top_node = nil
    end

    ownder = nil

    local entity = global.entities[entity_id]
    if entity then
        game.players[player_index].opened = entity.node.gui_element
    end
end

function overlay_gui.on_click_change_subgroup(event, entity_id)

    if event.element.enabled == false then
        return
    end

    for _, child in pairs(event.element.parent.children) do
        if child.name ~= event.element.name then
            child.enabled = true
        end
    end

    event.element.enabled = false

    local group = event.element.name:gsub(group_name.."_", "")
    local table_elements = event.element.parent.parent.children[2]

    for _, table_group in pairs(table_elements.children) do
        if table_group.name == group then
            table_group.visible = true
        else
            table_group.visible = false
        end
    end
end

function overlay_gui.on_click_select_signal(event, entity_id)
    if event.button == defines.mouse_button_type.left and event.element.elem_type and event.element.elem_value then
        if global.entities[entity_id] and ownder then
            local node = global.entities[entity_id].node:recursive_find(ownder.node_id)
            if node and node.gui.type == "choose-elem-button" then
                node.gui.elem_value = event.element.elem_value
                node.gui_element.elem_value = event.element.elem_value
                overlay_gui.destory_top_nodes_and_unselect(event.player_index, entity_id)

                if node.events_id.on_gui_elem_changed then
                    local new_event = 
                    node:on_remote_signal_change({element = node.gui_element})
                end
            end
        end
    end
end

function overlay_gui.create_signal_fill_gui(player_index)
    local player = game.players[player_index]
    local root = player.gui.screen.add({
        type = "button",
        name = overlay_name,
        direction = "vertical",
        style = constants.style.screen_strech_frame,
    })

    return root
end

function overlay_gui.create_signal_gui(player_index, node_param)
    ownder = {unit_number = node_param.entity_id, node_id = node_param.id}
    local player = game.players[player_index]
    local root = player.gui.screen.add({
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_frame,
        caption = "Select a signal"
    })

    local tasks_area = root.add({
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_inner_frame
    })

    local scroll_pane = tasks_area.add({
        type = "table",
        direction = "horizontal",
        column_count = 6,
        vertical_centering = true,
        style = constants.style.signal_group_frame
    })

    local signals_scroll_pane = tasks_area.add({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.signal_subgroup_scroll_frame,
        vertical_scroll_policy = "always",
        horizontal_scroll_policy = "never"
    })

    -------------------------------------------------------------------------------
    for _, group in pairs(cached_signals.groups) do

        local group_button = scroll_pane.add({
            type = "sprite-button",
            name = group_name.."_"..group.name,
            direction = "vertical",
            style = constants.style.signal_group_button_frame,
            group_name = group.name,
            enabled = (group.name ~= "logistics") or false,
            sprite = group.sprite,
            hovered_sprite = group.sprite,
            clicked_sprite = group.sprite
        })

        local signals_table = signals_scroll_pane.add({
            type = "table",
            name = group.name,
            direction = "vertical",
            column_count = 10,
            vertical_centering = true,
            style = constants.style.signal_subgroup_frame,
            visible = (group.name == "logistics") and true or false
        })

        for _, subgroup in pairs(group.subgroups) do
            for _, signal in pairs(subgroup.signals) do
                local button_node = signals_table.add({
                    type = "choose-elem-button",
                    name = signal_name.."_"..signal.name,
                    direction = "vertical",
                    style = constants.style.signal_subgroup_button_frame,
                    elem_type = "signal"
                })
                button_node.elem_value = {type = subgroup.type, name = signal.name}
                button_node.locked = true
                --button_node.events_id.on_click = "on_click_select_signal"
            end

            for i = 1, subgroup.empty_cells do
                local empty_node = signals_table.add({
                    type = "empty-widget",
                    direction = "vertical"
                })
            end
        end
    end
    -------------------------------------------------------------------------------

    return root
end

function overlay_gui.create_gui(player_index, node_param)
    global.screen_node = overlay_gui.create_signal_fill_gui(player_index)
    global.top_node = overlay_gui.create_signal_gui(player_index, node_param)
    global.top_node.focus()

    return global.top_node
end

return overlay_gui