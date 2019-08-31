local constants = require("constants")

local function item()
    item =
    {
        type = "item",
        name = constants.name,
        icon = constants.graphics.icon,
        icon_size = 32,
        subgroup = "circuit-network",
        place_result = constants.name,
        order = "c[combinators]-z["..constants.name.."]",
        stack_size = 50
    }
    return item
end

local function entity()
    entity = table.deepcopy(data.raw["arithmetic-combinator"]["arithmetic-combinator"])
    entity.name = constants.name
    entity.item_slot_count = 27
    entity.minable.result = constants.name
    entity.fast_replaceable_group = "arithmetic-combinator"
    entity.sprites = make_4way_animation_from_spritesheet({
        layers =
        {
            {
            filename = constants.graphics.image,
            width = 74,
            height = 64,
            frame_count = 1,
            shift = util.by_pixel(1, 8),
            hr_version =
            {
                scale = 0.5,
                filename = constants.graphics.hr_image,
                width = 144,
                height = 124,
                frame_count = 1,
                shift = util.by_pixel(0.5, 7.5)
            }
            },
            {
            filename = constants.graphics.image_shadow,
            width = 76,
            height = 78,
            frame_count = 1,
            shift = util.by_pixel(14, 24),
            draw_as_shadow = true,
            hr_version =
            {
                scale = 0.5,
                filename = constants.graphics.hr_image_shadow,
                width = 148,
                height = 156,
                frame_count = 1,
                shift = util.by_pixel(13.5, 24.5),
                draw_as_shadow = true
            }
            }
        }
    })
    entity.activity_led_sprites =
    {
        north =
        {
            filename = constants.graphics.activity_leds.north,
            width = 8,
            height = 8,
            frame_count = 1,
            shift = util.by_pixel(8, -12),
            hr_version =
            {
                scale = 0.5,
                filename = constants.graphics.activity_leds.hr_north,
                width = 16,
                height = 14,
                frame_count = 1,
                shift = util.by_pixel(8.5, -12.5)
            }
        },
        east =
        {
            filename = constants.graphics.activity_leds.east,
            width = 8,
            height = 8,
            frame_count = 1,
            shift = util.by_pixel(17, -1),
            hr_version =
            {
                scale = 0.5,
                filename = constants.graphics.activity_leds.hr_east,
                width = 14,
                height = 14,
                frame_count = 1,
                shift = util.by_pixel(16.5, -1)
            }
        },
        south =
        {
            filename = constants.graphics.activity_leds.south,
            width = 8,
            height = 8,
            frame_count = 1,
            shift = util.by_pixel(-8, 7),
            hr_version =
            {
                scale = 0.5,
                filename = constants.graphics.activity_leds.hr_south,
                width = 16,
                height = 16,
                frame_count = 1,
                shift = util.by_pixel(-8, 7.5)
            }
        },
        west =
        {
            filename = constants.graphics.activity_leds.west,
            width = 8,
            height = 8,
            frame_count = 1,
            shift = util.by_pixel(-16, -12),
            hr_version =
            {
                scale = 0.5,
                filename = constants.graphics.activity_leds.hr_west,
                width = 14,
                height = 14,
                frame_count = 1,
                shift = util.by_pixel(-16, -12.5)
            }
        }
    }
    return entity
end

local function recipe()
    recipe = {
        type = "recipe",
        name = constants.name,
        icon = constants.graphics.icon,
        icon_size = 32,
        enabled = true,
        ingredients = {{"constant-combinator", 1}, {"electronic-circuit", 1}},
        result = constants.name
    }
    return recipe
end

data:extend({item(), entity(), recipe()})