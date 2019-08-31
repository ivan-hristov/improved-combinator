local constants = {
    graphics = {
        activity_leds = {}
    },
    style = {},
    container = {}
}

constants.base_path = "__AdvancedCombinator__"
constants.name = "advanced-combinator"

constants.graphics.icon = constants.base_path.."/graphics/icons/advanced-combinator.png"
constants.graphics.image = constants.base_path.."/graphics/entity/advanced-combinator.png"
constants.graphics.hr_image = constants.base_path.."/graphics/entity/hr-advanced-combinator.png"
constants.graphics.image_shadow = constants.base_path.."/graphics/entity/advanced-combinator-shadow.png"
constants.graphics.hr_image_shadow = constants.base_path.."/graphics/entity/hr-advanced-combinator-shadow.png"
constants.graphics.activity_leds.east = constants.base_path.."/graphics/entity/activity-leds/advanced-combinator-LED-E.png"
constants.graphics.activity_leds.north = constants.base_path.."/graphics/entity/activity-leds/advanced-combinator-LED-N.png"
constants.graphics.activity_leds.south = constants.base_path.."/graphics/entity/activity-leds/advanced-combinator-LED-S.png"
constants.graphics.activity_leds.west = constants.base_path.."/graphics/entity/activity-leds/advanced-combinator-LED-W.png"
constants.graphics.activity_leds.hr_east = constants.base_path.."/graphics/entity/activity-leds/hr-advanced-combinator-LED-E.png"
constants.graphics.activity_leds.hr_north = constants.base_path.."/graphics/entity/activity-leds/hr-advanced-combinator-LED-N.png"
constants.graphics.activity_leds.hr_south = constants.base_path.."/graphics/entity/activity-leds/hr-advanced-combinator-LED-S.png"
constants.graphics.activity_leds.hr_west = constants.base_path.."/graphics/entity/activity-leds/hr-advanced-combinator-LED-W.png"

constants.style.default_frame = "ac_frame_default"
constants.style.default_frame_fill = "ac_frame_default_fill"

constants.container.main_panel = "ac_main"
constants.container.main_menu = "ac_menu"

return constants