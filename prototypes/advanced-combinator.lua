local constants = require("constants")

local function item()
    item =
    {
        type = "item",
        name = constants.entity.name,
        icon = constants.entity.graphics.icon,
        icon_size = 32,
        subgroup = "circuit-network",
        place_result = constants.entity.name,
        order = "c[combinators]-z["..constants.entity.name.."]",
        stack_size = 50
    }
    return item
end

local function entity()
    container =
    {
        type = "container",
        name = constants.entity.name,
        icon = constants.entity.graphics.icon,
        icon_size = 32,
        scale_info_icons = true,
        scale_entity_info_icon = true,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {hardness = 0.2, mining_time = 1, result = constants.entity.name},
        max_health = 250,
        corpse = "1x2-remnants",
        dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		resistances = {{type = "fire", percent = 90}},
        collision_box = {{-0.8, -0.35}, {0.8, 0.35}},
        selection_box = {{-1.0, -0.5}, {1.0, 0.5}},
    	inventory_size = 0,
		circuit_wire_max_distance = 0,
		circuit_wire_connection_point = nil,
        picture =
        {
            layers =
            {
                {
                    filename = constants.entity.graphics.image,
                    priority = "extra-high",
                    width = 102,
                    height = 51,
                    shift = util.by_pixel(0, 0),
                    hr_version =
                    {
                        filename = constants.entity.graphics.hr_image,
                        priority = "extra-high",
                        width = 204,
                        height = 102,
                        shift = util.by_pixel(0, 0),
                        scale = 0.5
                    }
                },
                {
                    filename = constants.entity.graphics.image_shadow,
                    priority = "extra-high",
                    width = 100,
                    height = 33,
                    shift = util.by_pixel(8.9, 4.5),
                    draw_as_shadow = true,
                    hr_version =
                    {
                        filename = constants.entity.graphics.hr_image_shadow,
                        priority = "extra-high",
                        width = 200,
                        height = 66,
                        shift = util.by_pixel(8.7, 4.35),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        },
    }
    return container
end

local function recipe()
    recipe = {
        type = "recipe",
        name = constants.entity.name,
        icon = constants.entity.graphics.icon,
        icon_size = 32,
        enabled = true,
        ingredients = {{"constant-combinator", 2}, {"electronic-circuit", 5}},
        result = constants.entity.name
    }
    return recipe
end

data:extend({item(), entity(), recipe()})