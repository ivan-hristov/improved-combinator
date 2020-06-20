local constants = require("constants")
local game_node = require("game_node")
local list = require("list")
local logger = require("logger")

local function createSubentity(mainEntity, subEntityType, xOffset, yOffset)
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
    logger.print("function.onInit")
    global.opened_entity = global.opened_entity or {}
    global.entities = global.entities or {}
end

local function on_built_entity(event)
    local entity = event.created_entity
    if entity.name == constants.entity.name then
        main_entity = {}
        main_entity.entity_input = createSubentity(entity, constants.entity.input.name, -0.9, 0.0)
        main_entity.entity_output = createSubentity(entity, constants.entity.output.name, 1.0, 0.0)
        main_entity.node = game_node:create_main_gui(entity.unit_number)
        main_entity.update_list = list:new()
        global.entities[entity.unit_number] = main_entity

        logger.print("function.on_built_entity Entity Added "..entity.unit_number.." ("..table_size(global.entities)..")")
    end
end

local function on_entity_died(event)   
    local entity = event.entity
    if entity.name == constants.entity.name then
        main_entity = global.entities[entity.unit_number]

        if main_entity.entity_input then
            main_entity.entity_input.destroy()
            main_entity.entity_input = nil
        end
        if main_entity.entity_output then
            main_entity.entity_output.destroy()
            main_entity.entity_output = nil
        end

        main_entity.node:remove()
        main_entity.node = nil

        for element in main_entity.update_list:iterator() do
            element.data.children:clear()
        end
        main_entity.update_list:clear()
        main_entity.update_list = nil
        
        global.entities[entity.unit_number] = nil

        logger.print("function.on_entity_died Entity Destroyed "..entity.unit_number.." ("..table_size(global.entities)..")")
    end
end

script.on_init(on_init)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)

script.on_event(defines.events.on_pre_player_mined_item, on_entity_died)
script.on_event(defines.events.on_robot_pre_mined, on_entity_died)
script.on_event(defines.events.on_entity_died, on_entity_died)
