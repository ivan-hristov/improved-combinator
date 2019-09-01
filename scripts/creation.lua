local constants = require("constants")
local logger = require("scripts.logger")

local function onBuiltEntity(event)
    local entity = event.created_entity
    if entity.name == constants.entity.name then
        logger.print("onBuildEntity "..entity.name)
        global.entity = entity
    end
end

script.on_event(defines.events.on_built_entity, onBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, onBuiltEntity)
