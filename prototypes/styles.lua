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
    tint = {0, 0, 0, 0.35},
    scale = 0.5,
    draw_type = "outer"
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
    [constants.style.conditional_flow_frame] =
    {
        type = "horizontal_flow_style",
        horizontally_stretchable = "off",
        vertically_stretchable = "on",
        vertical_align = "center",
        horizontal_align = "left",
        vertical_spacing = 4,
        horizontal_spacing = 4,
        padding = 4,
        height = 36
    },
    [constants.style.conditional_progress_frame] =
    {
        type = "progressbar_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        color = {0, 198, 89, 200},
        other_colors = {},
        padding  = 0,
        bar_width = 36,
        height = 36,
        embed_text_in_bar = false,

        bar =
        {
            base = {position = {68, 0}, corner_size = 8},
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
    [constants.style.time_selection_node] =
    {
      type = "button_style",
      size = {84, 28},
      left_click_sound = {{ filename = "__core__/sound/gui-menu-small.ogg", volume = 1 }},
    },
    [constants.style.close_button_frame] =
    {
        type = "button_style",
        vertical_align = "center",
        horizontal_align = "left",
        padding = 0,
        size = {16, 28},
        left_margin = 96,
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
            width = 378,
            horizontally_stretchable = "off"
        },
    },
    [constants.style.label_frame] =
    {
      type = "label_style",
      vertical_align = "center",
      horizontally_squashable = "on",
      font = "default-semibold",
      width = 110,
      font_color = {220, 220, 220},
      hovered_font_color = {249, 168, 56}
    },
})