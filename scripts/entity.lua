local constants = require("constants")
local game_node = require("game_node")
local overlay_gui = require("overlay_gui")
local list = require("list")
local logger = require("logger")

local function create_subentity(mainEntity, subEntityType, xOffset, yOffset)
    position = {x = mainEntity.position.x + xOffset,y = mainEntity.position.y + yOffset}
    local area = {
        {position.x - 1.5, position.y - 1.5}, 
        {position.x + 1.5, position.y + 1.5}
    }
    local ghost = false
    local ghosts = mainEntity.surface.find_entities_filtered { area = area, name = "entity-ghost", force = mainEntity.force }
    for _, each_ghost in pairs(ghosts) do
        if each_ghost.valid and each_ghost.ghost_name == subEntityType then
            if ghost then
                each_ghost.destroy()
            else
                each_ghost.revive()
                if not each_ghost.valid then 
                    ghost = true
                else 
                    each_ghost.destroy()
                end
            end
        end
    end

    if ghost then
        local entity = mainEntity.surface.find_entities_filtered{area = area, name = subEntityType, force = mainEntity.force, limit = 1 }[1]
        if entity then
            entity.direction = defines.direction.south
            entity.teleport(position)
            entity.destructible = false
            entity.operable = false
            return entity
        end
    else
        return mainEntity.surface.create_entity{name = subEntityType, position = position, force = mainEntity.force, fast_replace = false, destructible = false, operable = false}
    end
end

local function on_init()
    global.opened_entity = global.opened_entity or {}
    global.entities = global.entities or {}
end

local function on_built_entity(event)
    local entity = event.created_entity

    local function setup_entity(main_entity)
        global.entities[main_entity.unit_number] = {}
        global.entities[main_entity.unit_number].entity_input = create_subentity(main_entity, constants.entity.input.name, -0.9, 0.0)
        global.entities[main_entity.unit_number].entity_output = create_subentity(main_entity, constants.entity.output.name, 1.0, 0.0)
        global.entities[main_entity.unit_number].update_list = list:new()
        global.entities[main_entity.unit_number].node = game_node:create_main_gui(main_entity.unit_number)
    end

    if entity.name == constants.entity.name then
        setup_entity(entity)
    elseif entity.name == "entity-ghost" and entity.ghost_name == constants.entity.name then
        local _, revived_entity = entity.revive()
        setup_entity(revived_entity)
    end
end

local function on_entity_died(event)   
    local entity = event.entity
    if entity.name == constants.entity.name then
        -- Delete overlay signals if the entity was destroyed
        overlay_gui.safely_destory_top_nodes(entity.unit_number)
        
        local main_entity = global.entities[entity.unit_number]

        if main_entity.entity_input then
            main_entity.entity_input.destroy()
            main_entity.entity_input = nil
        end
        if main_entity.entity_output then
            main_entity.entity_output.destroy()
            main_entity.entity_output = nil
        end

        if main_entity.node.gui_element then
            main_entity.node.gui_element.destroy()
        end
        main_entity.node:remove()
        main_entity.node = nil

        for element in main_entity.update_list:iterator() do
            element.data.children:clear()
        end
        main_entity.update_list:clear()
        main_entity.update_list = nil
        
        global.entities[entity.unit_number] = nil
    end
end

local function on_entity_settings_pasted(event)
    local src_entity = global.entities[event.source.unit_number]
    local dest_entity = global.entities[event.destination.unit_number]

    if not src_entity or not dest_entity then
        return
    end

    -- Clear existing entity settings --
    if dest_entity.node.gui_element then
        dest_entity.node.gui_element.destroy()
    end

    dest_entity.node:remove()
    dest_entity.node = nil

    for element in dest_entity.update_list:iterator() do
        element.data.children:clear()
    end
    dest_entity.update_list:clear()
    dest_entity.update_list = nil

    -- Copy new settings --
    dest_entity.node = game_node.deep_copy(event.destination.unit_number, nil, src_entity.node)
    dest_entity.update_list = list.deep_copy(dest_entity.node, src_entity.update_list)

    global.entities[event.destination.unit_number] = dest_entity

end

script.on_init(on_init)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)

script.on_event(defines.events.on_pre_player_mined_item, on_entity_died)
script.on_event(defines.events.on_robot_mined_entity, on_entity_died)
script.on_event(defines.events.on_entity_died, on_entity_died)

script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)
