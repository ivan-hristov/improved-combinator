local loaded = false
local signals = {}

local function filtered_signal_prototypes(subgroup_name)
    --- Check if the group contains items --
    local signals_group = game.get_filtered_item_prototypes({{filter = "subgroup", subgroup = subgroup_name}})
    if #signals_group ~= 0 then
        return "item", signals_group
    end
 
    --- Check if the group contains fluids --
    if #signals_group == 0 then
        signals_group = game.get_filtered_fluid_prototypes({{filter = "subgroup", subgroup = subgroup_name}})
        if #signals_group ~= 0 then
            return "fluid", signals_group
        end
    end

    --- Check if the group contains signals --
    signals_group = {}
    for _, virtual_signal in pairs(game.virtual_signal_prototypes) do
        if virtual_signal.subgroup.name == subgroup_name then
            table.insert(signals_group, virtual_signal)
        end
    end

    return "virtual", signals_group
end

function signals.on_game_load()
    if not loaded then
        for _, item_group in pairs(game.item_group_prototypes) do
            local subgroup_signals = {}
            
            for _, sub_group in pairs(item_group.subgroups) do
                local type, signals_group = filtered_signal_prototypes(sub_group.name)
                if type == "virtual" or type == "fluid" and signals_group.hidden == false then
                    subgroup_signals[sub_group.name] = { type = type, signals_group = signals_group}
                end
            end

            for _, signal in pairs(subgroup_signals) do
                game.print("subgroup_signals")
            end

            --signals_group.has_flag("hidden") == false

            if #subgroup_signals ~= 0 then
                signals[item_group.name] = subgroup_signals
            end
        end
        loaded = true
    end
end

return signals