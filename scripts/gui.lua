local constants = require("constants")
local game_node = require("game_node")
local logger = require("logger")
local overlay_gui = require("overlay_gui")

local opened_signal_frame = nil

local function on_gui_opened(event)
    logger.print("on_gui_opened")

    if not event.entity then
        return
    end

    local player = game.players[event.player_index]
    if player.selected then        
        if player.selected.name == constants.entity.name then
            global.opened_entity[event.player_index] = event.entity.unit_number
            player.opened = game_node:build_gui_nodes(player.gui.screen, global.entities[event.entity.unit_number].node)
            player.opened.force_auto_center()
        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            player.opened = nil
        end
    end
end

local function on_gui_closed(event)
    if event.element then
        logger.print("on_gui_closed: "..event.element.name.." type: "..event.element.type)
    else
        logger.print("on_gui_closed")
    end

    -- TODO add option to minimise dropdown options instead of closing the main GUI
    if event.element and global.opened_entity then
        if overlay_gui.has_opened_signals_node() then
            overlay_gui.destory_top_nodes_and_unselect(event.player_index, global.opened_entity[event.player_index])
        else
            event.element.destroy()
            event.element = nil
            game.players[event.player_index].opened = nil
            global.opened_entity[event.player_index] = nil
        end
    end
end

local function on_gui_click(event)
    logger.print("on_gui_click name: "..event.element.name)

    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]

    -- Process overlay on-click events
    overlay_gui.on_click(event, unit_number)

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_click then
            node.events.on_click(event, node)
        end
    end
end

local function on_gui_elem_changed(event)
    if event.element.name and event.element.elem_value and event.element.elem_value.name and event.element.elem_value.type then
        logger.print("on_gui_elem_changed name: "..event.element.name..", type: "..event.element.elem_value.type.." name: "..event.element.elem_value.name)
    end

    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_gui_elem_changed then
            node.events.on_gui_elem_changed(event, node)
        end
    end
end

local function on_gui_text_changed(event)
    logger.print("on_gui_text_changed name: "..event.element.name)

    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]

    -- Process overlay on-text-changed events
    overlay_gui.on_gui_text_changed(event, unit_number)

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_gui_text_changed then
            node.events.on_gui_text_changed(event, node)
        end
    end
end

local function on_gui_selection_state_changed(event)
    logger.print("on_gui_selection_state_changed name: "..event.element.name)

    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_selection_state_changed then
            node.events.on_selection_state_changed[selected_index](event, node)
        end
    end
end

local function on_gui_location_changed(event)
    if event.element.location then
        overlay_gui.on_gui_location_changed(event)
    end
end

local function on_gui_value_changed(event)
    overlay_gui.on_gui_value_changed(event)
end


local function on_gui_selected_tab_changed(event)
    logger.print("on_gui_selected_tab_changed name: "..event.element.name.." index: "..event.element.selected_tab_index)

    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_gui_selected_tab_changed then
            node.events.on_gui_selected_tab_changed(event, node)
        end
    end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
script.on_event(defines.events.on_gui_location_changed, on_gui_location_changed)
script.on_event(defines.events.on_gui_value_changed, on_gui_value_changed)
