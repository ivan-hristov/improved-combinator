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
constants.gui_image = constants.base_path.."/graphics/gui.png"

constants.entity.name = "advanced-combinator"
constants.entity.remnants = "advanced-combinbator-remnants"
constants.entity.graphics.icon = constants.base_path.."/graphics/icons/advanced-combinator.png"
constants.entity.graphics.image = constants.base_path.."/graphics/entity/advanced-combinator.png"
constants.entity.graphics.hr_image = constants.base_path.."/graphics/entity/hr-advanced-combinator.png"
constants.entity.graphics.image_shadow = constants.base_path.."/graphics/entity/advanced-combinator-shadow.png"
constants.entity.graphics.hr_image_shadow = constants.base_path.."/graphics/entity/hr-advanced-combinator-shadow.png"
constants.entity.graphics.remnants = constants.base_path.."/graphics/entity/remnants/constant-combinator-remnants.png"
constants.entity.graphics.hr_remnants = constants.base_path.."/graphics/entity/remnants/hr-constant-combinator-remnants.png"


constants.entity.input.name = "advanced-combinator-input"
constants.entity.input.icon = constants.base_path.."/graphics/blank.png"
constants.entity.input.image = constants.base_path.."/graphics/blank.png"
constants.entity.input.circuit_wire_max_distance = 15

constants.entity.output.name = "advanced-combinator-output"
constants.entity.output.icon = constants.base_path.."/graphics/blank.png"
constants.entity.output.image = constants.base_path.."/graphics/blank.png"
constants.entity.output.circuit_wire_max_distance = 15

-- Style Names --
constants.style.prefix_uuid = "ac_"
constants.style.dialogue_frame = constants.style.prefix_uuid.."dialogue_frame"
constants.style.main_frame = constants.style.prefix_uuid.."main_frame"
constants.style.signal_frame = constants.style.prefix_uuid.."signal_frame"
constants.style.signal_inner_frame = constants.style.prefix_uuid.."signal_inner_frame"
constants.style.signal_group_frame = constants.style.prefix_uuid.."signal_group_frame"
constants.style.signal_subgroup_frame = constants.style.prefix_uuid.."signal_subgroup_frame"
constants.style.signal_group_button_frame = constants.style.prefix_uuid.."signal_group_button_frame"
constants.style.signal_subgroup_scroll_frame = constants.style.prefix_uuid.."signal_subgroup_scroll_frame"
constants.style.signal_subgroup_button_frame = constants.style.prefix_uuid.."signal_subgroup_button_frame"
constants.style.signal_subgroup_background_frame = constants.style.prefix_uuid.."signal_subgroup_background_frame"
constants.style.tasks_frame = constants.style.prefix_uuid.."tasks_frame"
constants.style.large_button_frame = constants.style.prefix_uuid.."large_button_frame"
constants.style.large_options_button_frame = constants.style.prefix_uuid.."large_options_button_frame"
constants.style.edit_button_frame = constants.style.prefix_uuid.."edit_button_frame"
constants.style.dropdown_subtask_options_frame = constants.style.prefix_uuid.."dropdown_subtask_options_frame"
constants.style.dropdown_options_frame = constants.style.prefix_uuid.."drowdown_options_frame"
constants.style.conditional_frame = constants.style.prefix_uuid.."conditional_frame"
constants.style.sub_conditional_frame  = constants.style.prefix_uuid.."sub_conditional_frame"
constants.style.conditional_flow_frame = constants.style.prefix_uuid.."conditional_flow_frame"
constants.style.group_vertical_flow_frame = constants.style.prefix_uuid.."group_vertical_flow_frame"
constants.style.sub_group_vertical_flow_frame = constants.style.prefix_uuid.."sub_group_vertical_flow_frame"
constants.style.conditional_progress_frame = constants.style.prefix_uuid.."conditional_progress_frame" 
constants.style.options_list = constants.style.prefix_uuid.."options_list"
constants.style.scroll_pane_with_dark_background = constants.style.prefix_uuid.."scroll_pane_with_dark_background"
constants.style.scroll_pane = constants.style.prefix_uuid.."scroll_pane"
constants.style.repeatable_begining_label_frame = constants.style.prefix_uuid.."repeatable_begining_label_frame"
constants.style.play_button_frame = constants.style.prefix_uuid.."play_button_frame"
constants.style.time_selection_frame = constants.style.prefix_uuid.."time_selection_frame"
constants.style.close_button_frame = constants.style.prefix_uuid.."close_button_frame"
constants.style.repeatable_end_label_frame = constants.style.prefix_uuid.."repeatable_end_label_frame"
constants.style.task_dropdown_frame = constants.style.prefix_uuid.."task_dropdown_frame"
constants.style.subtask_dropdown_frame = constants.style.prefix_uuid.."subtask_dropdown_frame"
constants.style.condition_comparator_dropdown_frame = constants.style.prefix_uuid.."condition_comparator_dropdown_frame"
constants.style.condition_arithmetic_comparator_dropdown_frame = constants.style.prefix_uuid.."condition_arithmetic_comparator_dropdown_frame"
constants.style.dropdown_overlay_label_frame = constants.style.prefix_uuid.."dropdown_overlay_label_frame"
constants.style.dark_button_frame = constants.style.prefix_uuid.."dark_button_frame"
constants.style.dark_button_arithmetic_frame = constants.style.prefix_uuid.."dark_button_arithmetic_frame"
constants.style.dark_button_constant_frame = constants.style.prefix_uuid.."dark_button_constant_frame"
constants.style.dark_arithmetic_textfield_frame = constants.style.prefix_uuid.."dark_arithmetic_textfield_frame"
constants.style.invisible_frame = constants.style.prefix_uuid.."invisible_frame"
constants.style.radiobutton_frame = constants.style.prefix_uuid.."radiobutton_frame"
constants.style.radio_vertical_flow_frame = constants.style.prefix_uuid.."radio_vertical_flow_frame"
constants.style.dark_textfield_frame = constants.style.prefix_uuid.."dark_textfield_frame"
constants.style.combinator_horizontal_padding_frame = constants.style.prefix_uuid.."combinator_horizontal_padding_frame"

return constants