local constants = require("constants")

local function add_styles(styles)
    local default_styles = data.raw["gui-style"].default
    for name, style in pairs(styles) do
        default_styles[name] = style
    end
end

local default_shadow =
{
    position = {200, 128},
    corner_size = 8,
    tint = {0, 0, 0, 90},
    scale = 0.5,
    draw_type = "outer"
}   

local default_dirt =
{
    position = {200, 128},
    corner_size = 8,
    tint = {15, 7, 3, 100},
    scale = 0.5,
    draw_type = "outer"
}

local default_glow =
{
    position = {200, 128},
    corner_size = 8,
    tint = {225, 177, 106, 255},
    scale = 0.5,
    draw_type = "outer"
}

local default_inner_shadow =
{
    position = {183, 128},
    corner_size = 8,
    tint = {0, 0, 0, 1},
    scale = 0.5,
    draw_type = "inner"
}

add_styles({
    [constants.style.main_frame] =
    {
        type = "frame_style",
        parent = "dialog_frame",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",

        top_padding  = 5,
        right_padding = 5,
        bottom_padding = 5,
        left_padding = 5,

        width = 700,
        height = 650
    },
    [constants.style.tasks_frame] =
    {
        type = "frame_style",
        parent = "inside_deep_frame_for_tabs",
        vertical_align = "top",
        horizontal_align = "left",

        top_padding  = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,

        width = 400,
        height = 600
    },
    [constants.style.dropdown_options_frame] =
    {
        type = "frame_style",
        parent = "inner_frame_in_outer_frame",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",

        top_padding  = 7,
        right_padding = 7,
        bottom_padding = 7,
        left_padding = 7
    },
    [constants.style.dropdown_subtask_options_frame] =
    {
        type = "frame_style",
        parent = "inner_frame_in_outer_frame",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",

        left_margin = 84,
        
        top_padding  = 7,
        right_padding = 7,
        bottom_padding = 7,
        left_padding = 7
    },
    [constants.style.options_list] =
    {
        type = "list_box_style",
        vertical_align = "top",
        horizontal_align = "left",

        top_padding  = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0

    },
    [constants.style.large_button_frame] =
    {
        type = "button_style",
        parent = "button_with_shadow",
        horizontal_align = "left",
        horizontally_stretchable = "on",

        height = 36
    },
    [constants.style.large_options_button_frame] =
    {
        type = "button_style",
        parent = "button_with_shadow",
        horizontal_align = "left",
        horizontally_stretchable = "on",

        left_margin = 84,
        height = 36
    },
    [constants.style.conditional_frame] =
    {
        type = "frame_style",
        parent = "dark_frame",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",

        top_padding  = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,

        height = 36
    },
    [constants.style.sub_conditional_frame] =
    {
        type = "frame_style",
        parent = constants.style.conditional_frame,
        left_margin = 84
    },
    [constants.style.group_vertical_flow_frame] =
    {
        type = "vertical_flow_style",
        vertical_align = "center",
        horizontal_align = "left",
        vertical_spacing = 4
    },
    [constants.style.sub_group_vertical_flow_frame] =
    {
        type = "vertical_flow_style",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        vertical_spacing = 4,
        height = 0
    },
    [constants.style.conditional_flow_frame] =
    {
        type = "horizontal_flow_style",
        horizontally_stretchable = "off",
        vertically_stretchable = "on",
        vertical_align = "center",
        horizontal_align = "left",
        horizontal_spacing = 4,
        padding = 4,
        height = 36
    },
    [constants.style.conditional_progress_frame] =
    {
        type = "progressbar_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        color = {20, 255, 90, 210},
        other_colors = {},
        padding  = 0,
        bar_width = 36,
        height = 36,
        embed_text_in_bar = false,

        bar =
        {
            base = {position = {68, 0}, corner_size = 8, tint = {100, 255, 100, 0}},
            shadow = default_shadow
        },
        bar_background =
        {
            base = {position = {68, 0}, corner_size = 8},
            shadow = default_shadow
        },
    },
    [constants.style.play_button_frame] =
    {
        type = "button_style",
        vertical_align = "center",
        horizontal_align = "left",
        padding = 0,

        size = {28, 28},
        left_margin = 0,
        top_margin = 0,

        default_graphical_set =
        {
            base = {position = {0, 17}, corner_size = 8},
            glow = default_shadow           
        },
        hovered_graphical_set =
        {
            base = {position = {34, 17}, corner_size = 8},
            glow = default_shadow
        },
        clicked_graphical_set =
        {
            base = {position = {51, 17}, corner_size = 8},
            glow = default_shadow
        },
        left_click_sound = {{ filename = "__core__/sound/gui-menu-small.ogg", volume = 1 }},

    },
    [constants.style.time_selection_frame] =
    {
      type = "textbox_style",
      horizontal_align = "center",
      font = "default-semibold",
      size = {84, 28},
      left_click_sound = {{ filename = "__core__/sound/gui-menu-small.ogg", volume = 1 }},
    },
    [constants.style.repeatable_begining_label_frame] =
    {
      type = "label_style",
      vertical_align = "center",
      horizontal_align = "right",
      horizontally_squashable = "on",
      font = "default-semibold",
      width = 110,
      font_color = {220, 220, 220},
      hovered_font_color = {249, 168, 56}
    },
    [constants.style.repeatable_end_label_frame] =
    {
        type = "label_style",
        vertical_align = "center",
        horizontal_align = "left",
        font = "default-semibold",
        width = 116,
        font_color = {220, 220, 220},
        hovered_font_color = {249, 168, 56}
    },
    [constants.style.close_button_frame] =
    {
        type = "button_style",
        vertical_align = "center",
        horizontal_align = "left",
        padding = 0,
        size = {16, 28},
        left_margin = 0,
        top_margin = 0,

        default_graphical_set =
        {
            base =
            {
                position = {68, 0},
                corner_size = 8,
            }
        },
        left_click_sound = {{ filename = "__core__/sound/gui-tool-button.ogg", volume = 1 }},
    },
    [constants.style.scroll_pane] =
    {
        type = "scroll_pane_style",
        parent = "scroll_pane_with_dark_background_under_subheader",
        top_padding  = 5,
        right_padding = 5,
        bottom_padding = 5,
        left_padding = 5,
        width = 400,
        height = 600,        
        background_graphical_set =
        {
            position = {282, 17},
            corner_size = 8,
            overall_tiling_horizontal_spacing = 8,
            overall_tiling_horizontal_padding = 4,
            overall_tiling_vertical_spacing = 12,
            overall_tiling_vertical_size = 28,
            overall_tiling_vertical_padding = 4
        },
        vertical_flow_style =
        {
            type = "vertical_flow_style",
            horizontally_stretchable = "off",
            width = 378,
            
        },
    },
    [constants.style.task_dropdown_frame] =
    {
        type = "dropdown_style",
        horizontally_stretchable = "on",
        height = 36,

        button_style =
        {
            type = "button_style",
            parent = "button_with_shadow",
            horizontal_align = "left",
            vertical_align = "center",
        },
        icon =
        {
            filename = nil,
            priority = nil,
            size = 32,
            tint = {0, 0, 0, 0}
        },
        list_box_style =
        {
            type = "list_box_style",
            vertical_align = "top",
            horizontal_align = "left",
            horizontally_stretchable = "off",
            maximal_height = 400,

            item_style =
            {
                type = "button_style",
                parent = "list_box_item",
                left_padding = 4,
                right_padding = 4
            },
            scroll_pane_style =
            {
                type = "scroll_pane_style",
                extra_padding_when_activated = 0,
                graphical_set =
                {
                    base =
                    {
                        position = {17, 0},
                        corner_size = 8,
                        scale = 0.75,
                        top_outer_border_shift = 4,
                        bottom_outer_border_shift = -4,
                        left_outer_border_shift = 4,
                        right_outer_border_shift = -4,
                    },
                    shadow = 
                    {
                        position = {200, 128},
                        corner_size = 8,
                        tint = {0, 0, 0, 90},
                        scale = 0.75,
                        draw_type = "inner"
                    },
                }
            }
        }
    },
    [constants.style.subtask_dropdown_frame] =
    {
        type = "dropdown_style",
        parent = constants.style.task_dropdown_frame,
        left_margin = 84
    },
    [constants.style.condition_comparator_dropdown_frame] =
    {
        type = "dropdown_style",
        minimal_width = 0,
        left_padding = 4,
        right_padding = 0,
        width = 56,
        height = 28,

        -- semi-hack redefining the graphical set to put shadow in to glow layer to be on top of the neighbour inset
        button_style =
        {
            type = "button_style",
            parent = "dropdown_button",

            default_graphical_set =
            {
                base = {position = {0, 17}, corner_size = 8},
                glow = default_dirt
            },
            hovered_graphical_set =
            {
                base = {position = {34, 17}, corner_size = 8},
                glow = default_glow
            },
            clicked_graphical_set =
            {
                base = {position = {51, 17}, corner_size = 8},
                glow = default_dirt
            },
            disabled_graphical_set =
            {
                base = {position = {17, 17}, corner_size = 8},
                glow = default_dirt
            },
            selected_graphical_set =
            {
                base = {position = {225, 17}, corner_size = 8},
                glow = default_dirt
            },
            selected_hovered_graphical_set =
            {
                base = {position = {369, 17}, corner_size = 8},
                glow = default_dirt
            },
            selected_clicked_graphical_set =
            {
                base = {position = {352, 17}, corner_size = 8},
                glow = default_dirt
            }
        },
        list_box_style =
        {
            type = "list_box_style",
            
            maximal_height = 400,
            item_style =
            {
                type = "button_style",
                parent = "list_box_item",
                left_padding = 4,
                right_padding = 4
            },
            scroll_pane_style =
            {
                type = "scroll_pane_style",
                padding = 0,
                extra_padding_when_activated = 0,
                graphical_set = {shadow = default_shadow}
            }
        }
    },
    [constants.style.dropdown_overlay_label_frame] =
    {
        type = "label_style",
        font = "default-semibold",
        top_padding = 5,
        font_color = {0, 0, 0},
        hovered_font_color = {249, 168, 56}
    },
    [constants.style.dark_button_frame] =
    {
        type = "button_style",
        parent = "train_schedule_item_select_button",
        width = 28,
        height = 28
    },
    [constants.style.invisible_frame] =
    {
        type = "button_style",
        padding = 0,
        margin = 0,
        width = 28,
        height = 28,
        default_graphical_set = {},

        horizontal_flow_style =
        {
          type = "horizontal_flow_style",
          horizontal_spacing = 0
        },
        vertical_flow_style =
        {
          type = "vertical_flow_style",
          vertical_spacing = 0
        }
    },
    [constants.style.radio_vertical_flow_frame] =
    {
        type = "vertical_flow_style",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        vertical_spacing = -4,
        top_margin = -5,
        padding = 0,
        height = 0
    },
    [constants.style.radiobutton_frame] =
    {
        type = "radiobutton_style",
        parent = "radiobutton",
        padding = 0,
        text_padding = 0
    }
})