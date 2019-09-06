local constants = require("constants")
local logger = require("scripts.logger")

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

local function onBuiltEntity(event)
    local entity = event.created_entity
    logger.print("onBuildEntity "..entity.name)

    if entity.name == constants.entity.name then
        global.entity = entity
        global.entity_input = createSubentity(entity, constants.entity.input.name, -0.9, 0.0)
        global.entity_output = createSubentity(entity, constants.entity.output.name, 1.0, 0.0)

        logger.print("onCreatedSubEntity "..global.entity_input.name)
        logger.print("onCreatedSubEntity "..global.entity_output.name.." number "..global.entity_output.unit_number)
    end
end

local function onEntityDied(event)

    logger.print("onEntityDied "..event.entity.name)

    if global.entity_input then
        global.entity_input.destroy()
        global.entity_input = nil
    end

    if global.entity_output then
        global.entity_output.destroy()
        global.entity_output = nil
    end

    global.entity = nil
end

script.on_event(defines.events.on_built_entity, onBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, onBuiltEntity)

script.on_event(defines.events.on_pre_player_mined_item, onEntityDied)
script.on_event(defines.events.on_robot_pre_mined, onEntityDied)
script.on_event(defines.events.on_entity_died, onEntityDied)
