local constants = {
    entity = {
        graphics = {
            activity_leds = {}
        },        
        input = {},
        output = {}
    },
    style = {},
    actions = {},
    container = {}
}

constants.base_path = "__AdvancedCombinator__"
constants.blank_image = constants.base_path.."/graphics/blank.png"
constants.blank_image_4x4 = constants.base_path.."/graphics/blank_4x4.png"

constants.entity.name = "advanced-combinator"
constants.entity.graphics.icon                   = constants.base_path.."/graphics/icons/advanced-combinator.png"
constants.entity.graphics.image                  = constants.base_path.."/graphics/entity/advanced-combinator.png"
constants.entity.graphics.hr_image               = constants.base_path.."/graphics/entity/hr-advanced-combinator.png"
constants.entity.graphics.image_shadow           = constants.base_path.."/graphics/entity/advanced-combinator-shadow.png"
constants.entity.graphics.hr_image_shadow        = constants.base_path.."/graphics/entity/hr-advanced-combinator-shadow.png"

constants.entity.input.name = "advanced-combinator-input"
constants.entity.input.icon = constants.base_path.."/graphics/blank.png"
constants.entity.input.image = constants.base_path.."/graphics/blank.png"
constants.entity.input.circuit_wire_max_distance = 15

constants.entity.output.name = "advanced-combinator-output"
constants.entity.output.icon = constants.base_path.."/graphics/blank.png"
constants.entity.output.image = constants.base_path.."/graphics/blank.png"
constants.entity.output.circuit_wire_max_distance = 15

-- Style Names --
constants.style.prefix_uuid            = "ac_"
constants.style.hidden_frame           = constants.style.prefix_uuid.."hidden_frame"
constants.style.default_frame          = constants.style.prefix_uuid.."frame_default"
constants.style.main_frame             = constants.style.prefix_uuid.."main_frame"
constants.style.tasks_frame            = constants.style.prefix_uuid.."tasks_frame"
constants.style.large_button_frame     = constants.style.prefix_uuid.."large_button_frame"
constants.style.dropdown_options_frame = constants.style.prefix_uuid.."drowdown_options_frame"
constants.style.conditional_frame      = constants.style.prefix_uuid.."conditional_frame"
constants.style.options_list           = constants.style.prefix_uuid.."options_list"

-- Window Names  --
constants.container.prefix_uuid        = "ac_"
constants.container.hidden_panel       = constants.container.prefix_uuid.."hidden_panel"
constants.container.main_panel         = constants.container.prefix_uuid.."main"
constants.container.main_menu          = constants.container.prefix_uuid.."menu"
constants.container.tasks_panel        = constants.container.prefix_uuid.."tasks"
constants.container.selection_pannel   = constants.container.prefix_uuid.."selection"

constants.actions.prefix_uuid          = "ac_"
constants.actions.press_button         = constants.actions.prefix_uuid.."push"

return constants