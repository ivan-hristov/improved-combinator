
local sprites = {}

local function load_sprites(data)
    for _, item in pairs(data) do
        if item.name ~= nil and item.icon ~= nil and item.icon_size ~= nil then
            table.insert(sprites,
                {
                    type = "sprite",
                    name = "advanced-combinator-"..item.type.."-"..item.name,
                    filename = item.icon,
                    priority = "extra-high-no-scale",
                    width = item.icon_size,
                    height = item.icon_size,
                    mipmap_count = 1,
                    flags = {"gui-icon"}
                }
            )
        end
    end
end


local function print_item_groups()
    for _, item_group in pairs(game.item_group_prototypes) do
        if item_group.name == "logistics" then
            game.print(item_group.name, {10, 255, 150})
            for _, sub_group in pairs(item_group.subgroups) do
                game.print("   ├"..sub_group.name..", type "..sub_group.type, {10, 255, 150})
                local item_prototypes = game.get_filtered_item_prototypes({{filter = "subgroup", subgroup = sub_group.name }})

                local str = "      {"
                for _, items in pairs(item_prototypes) do
                    str = str..items.name..", type: "..items.type.."; "
                end
                str = str.."}"

                game.print(str, {10, 255, 150})
            end
        end
    end
end


local function print_item_groups2()
    for _, item_group in pairs(game.item_group_prototypes) do
        if item_group.type == "item-group" then
            game.print(item_group.name, {10, 255, 150})
        end
    end
end

local function print_item_groups()
    for _, item_group in pairs(game.item_subgroup_prototypes) do
        game.print(item_group.name, {10, 255, 150})
    end
end


load_sprites(data.raw["item-group"])
data:extend(sprites)