local constants = require("constants")

local function add_styles(styles)
    local default_styles = data.raw["gui-style"].default
    for name, style in pairs(styles) do
        default_styles[name] = style
    end
end


add_styles({
    [constants.style.default_frame] =
    {
        type = "frame_style",
        font = "default-semibold",
        font_color = {r=1, g=1, b=1},

        top_padding  = 0,
        right_padding = 2,
        bottom_padding = 0,
        left_padding = 2,

        title_top_padding = 0,
        title_left_padding = 0,
        title_bottom_padding = 4,
        title_right_padding = 0,

        graphical_set =
        {
            type = "composition",
            filename = "__core__/graphics/gui.png",
            priority = "extra-high-no-scale",
            load_in_minimal_mode = true,
            corner_size = {3, 3},
            position = {8, 0}
        },
        flow_style =
        {
            type = "flow_style",
            horizontal_spacing = 0,
            vertical_spacing = 0
        },
        horizontal_flow_style =
        {
            type = "horizontal_flow_style",
            horizontal_spacing = 0,
        },
        vertical_flow_style =
        {
            type = "vertical_flow_style",
            vertical_spacing = 0
        }
    },
    [constants.style.default_frame_fill] =
    {
        type = "frame_style",
        parent = constants.style.default_frame,
        horizontally_stretchable = "on",
        vertically_stretchable = "on",

        minimal_width = 700,
        maximal_width = 700,
        minimal_height = 650,
        maximal_height = 650,
        width = 700,
        height = 650
    }
})