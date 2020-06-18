local constants = require("constants")
local game_node = require("game_node")
local logger = require("scripts.logger")


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

local function on_gui_text_changed(event)
    logger.print("on_gui_text_changed name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local unit_number = global.opened_entity[event.player_index]

    local node = global.entities[unit_number].node:recursive_find(name)
    if node and node.events.on_gui_text_changed then
        node.events.on_gui_text_changed(event, node)
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
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)

