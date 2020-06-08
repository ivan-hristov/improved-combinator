local constants = require("constants")
local logger = require("scripts.logger")

local events = {}

function events.on_click_new_task_button(event, node)
    if event.element.parent[node.events_params.task_dropdown_frame_id].visible then
        event.element.parent[node.events_params.task_dropdown_frame_id].visible = false
    else
        event.element.parent[node.events_params.task_dropdown_frame_id].visible = true
    end
end

function events.on_click_close_button(event, node)
    logger.print("on_click_close_button event_name: "..event.element.parent.name..", node_id: "..node.parent.id)
    node.parent:remove()
    event.element.parent.destroy()
end

function events.on_selection_repeatable_timer(event, node)
    event.element.parent.visible = false
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local scroll_pane_node = node.parent.parent
    local scroll_pane_gui = event.element.parent.parent

    logger.print("on_selection_repeatable_timer element_name: "..scroll_pane_node.id..", node_id: "..scroll_pane_gui.name)

    local repeatable_time_node = scroll_pane_node:add_child()
    repeatable_time_node.gui = {
        type = "frame",
        direction = "vertical",
        name = repeatable_time_node.id,
        style = constants.style.conditional_frame
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
    close_button_node.events_id.on_click = "on_click_close_button"

    -- DEBUG
    for _, v in pairs(scroll_pane_gui.children_names) do
        if v == close_button_node.id then
            logger.print("MATCH FOUND element_name: "..v..", node_id: "..close_button_node.id)
            local root = close_button_node
            while root.parent do
                root = root.parent
            end
            root:debug_print(0)

            repeatable_time_node:remove()
            return
        end
    end

    -- Setup Node Events --
    close_button_node:recursive_setup_events()

    -- Setup Factorio GUI --
    local repeatable_time_gui = scroll_pane_gui.add(repeatable_time_node.gui)
    repeatable_time_gui.add(close_button_node.gui)
end

function events.on_selection_single_timer(event, node)
    event.element.parent.visible = false
    event.element.selected_index = 0
end


return events