local constants = {
    entity = {
        graphics = {
            activity_leds = {}
        },
    },
    style = {},
    actions = {},
    container = {}
}

constants.base_path = "__AdvancedCombinator__"

constants.entity.name = "advanced-combinator"
constants.entity.graphics.icon                   = constants.base_path.."/graphics/icons/advanced-combinator.png"
constants.entity.graphics.image                  = constants.base_path.."/graphics/entity/advanced-combinator.png"
constants.entity.graphics.hr_image               = constants.base_path.."/graphics/entity/hr-advanced-combinator.png"
constants.entity.graphics.image_shadow           = constants.base_path.."/graphics/entity/advanced-combinator-shadow.png"
constants.entity.graphics.hr_image_shadow        = constants.base_path.."/graphics/entity/hr-advanced-combinator-shadow.png"

constants.style.prefix_uuid = "ac_"
constants.style.default_frame       = constants.style.prefix_uuid.."frame_default"
constants.style.default_frame_fill  = constants.style.prefix_uuid.."frame_default_fill"
constants.style.options_frame       = constants.style.prefix_uuid.."options_frame"
constants.style.button_with_shadow  = constants.style.prefix_uuid.."button_with_shadow"
constants.style.condition_button    = constants.style.prefix_uuid.."condition_button"

constants.actions.prefix_uuid = "ac_"
constants.actions.press_button = constants.actions.prefix_uuid.."push"

constants.container.prefix_uuid = "ac_"
constants.container.main_panel      = constants.container.prefix_uuid.."main"
constants.container.main_menu       = constants.container.prefix_uuid.."menu"
constants.container.options_panel   = constants.container.prefix_uuid.."options"

return constants