local constants = require("constants")
local game_node = require("game_node")
local overlay_gui = require("overlay_gui")
local update_array = require("update_array")
local logger = require("logger")

local function create_subentity(main_entity, sub_entity_type, x_offset, y_offset)
    position = {x = main_entity.position.x + x_offset,y = main_entity.position.y + y_offset}
    local area = {
        {position.x - 1.5, position.y - 1.5}, 
        {position.x + 1.5, position.y + 1.5}
    }

    local ghosts = main_entity.surface.find_entities_filtered { area = area, name = "entity-ghost", force = main_entity.force }
    for _, ghost in pairs(ghosts) do
        if ghost.valid and ghost.ghost_name == sub_entity_type then
            ghost.revive()
        end
    end

    local existing_entity = main_entity.surface.find_entities_filtered{area = area, name = sub_entity_type, force = main_entity.force, limit = 1 }[1]
    if existing_entity then
        existing_entity.direction = defines.direction.east
        existing_entity.teleport(position)
        existing_entity.destructible = false
        existing_entity.operable = false
        existing_entity.minable = false
        return existing_entity
    else
        local new_entity = main_entity.surface.create_entity{name = sub_entity_type, position = position, force = main_entity.force, fast_replace = false, destructible = false, operable = false}
        new_entity.direction = defines.direction.east
        new_entity.teleport(position)
        new_entity.destructible = false
        new_entity.operable = false
        new_entity.minable = false
        return new_entity
    end
end

local function on_init()
    global.opened_entity = global.opened_entity or {}
    global.entities = global.entities or {}
end

local function build_entity(entity, tags)
    if entity.name == constants.entity.name and tags and tags["improved-combinator-nodes"] and tags["improved-combinator-updates"] then
        global.entities[entity.unit_number] = {}
        global.entities[entity.unit_number].entity_input = create_subentity(entity, constants.entity.input.name, -0.9, 0.0)
        global.entities[entity.unit_number].entity_output = create_subentity(entity, constants.entity.output.name, 1.0, 0.0)
        local node = game_node.node_from_json(tags["improved-combinator-nodes"], entity.unit_number)

        -- Something has gone wrong. Create a default node
        if not node then
            node = game_node:create_main_gui(entity.unit_number)
        end

        global.entities[entity.unit_number].node = node
        global.entities[entity.unit_number].update_list = update_array.json_to_table(node, tags["improved-combinator-updates"])

    elseif entity.name == constants.entity.name then
        global.entities[entity.unit_number] = {}
        global.entities[entity.unit_number].entity_input = create_subentity(entity, constants.entity.input.name, -0.9, 0.0)
        global.entities[entity.unit_number].entity_output = create_subentity(entity, constants.entity.output.name, 1.0, 0.0)
        global.entities[entity.unit_number].update_list = {}
        global.entities[entity.unit_number].node = game_node:create_main_gui(entity.unit_number)
    end
end

local function on_built_entity(event)
    build_entity(event.created_entity, event.tags)
end

local function on_script_raised_built(event)
    build_entity(event.entity, event.tags)
end

local function on_entity_died(event)
    local entity = event.entity
    if entity.name == constants.entity.name then
        -- Delete overlay signals if the entity was destroyed
        overlay_gui.safely_destory_top_nodes(entity.unit_number)
        
        local main_entity = global.entities[entity.unit_number]

        if main_entity then
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

            main_entity.update_list = {}
            main_entity.update_list = nil
            
            global.entities[entity.unit_number] = nil
        end
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

    dest_entity.update_list = {}
    dest_entity.update_list = nil

    -- Copy new settings --
    dest_entity.node = game_node.deep_copy(event.destination.unit_number, nil, src_entity.node)
    dest_entity.update_list = update_array.deep_copy(src_entity.update_list, dest_entity.node)

    global.entities[event.destination.unit_number] = dest_entity

end

local function on_player_setup_blueprint(event)

    local player = game.get_player(event.player_index)
    local blueprint = player.blueprint_to_setup
    local blueprint_entities = blueprint.get_blueprint_entities()
    local mapping = event.mapping.get()

    for _, blueprint_entity in pairs(blueprint_entities) do
        local unit_number = mapping[blueprint_entity.entity_number].unit_number
        if global.entities[unit_number] then
            blueprint_entity.tags = blueprint_entity.tags or {}
            blueprint_entity.tags["improved-combinator-nodes"] = game_node.node_to_json(global.entities[unit_number].node)
            blueprint_entity.tags["improved-combinator-updates"] = update_array.table_to_json(global.entities[unit_number].update_list)
        end
    end

    blueprint.set_blueprint_entities(blueprint_entities)
end

script.on_init(on_init)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)

script.on_event(defines.events.on_pre_player_mined_item, on_entity_died)
script.on_event(defines.events.on_robot_pre_mined, on_entity_died)
script.on_event(defines.events.on_entity_died, on_entity_died)

script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

script.on_event(defines.events.script_raised_built, on_script_raised_built)
script.on_event(defines.events.script_raised_revive, on_script_raised_built)
script.on_event(defines.events.script_raised_destroy, on_entity_died)

script.on_event(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)

