local constants = require("constants")
local game_node = require("game_node")
local list = require("list")
local logger = require("scripts.logger")

local input_signals = {}
local current_index = 0

local function read_input_signals()

    local function read_signals(network, signals)
        if network and network.signals then            
            for _, nework_signal in pairs(network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    if signals[nework_signal.signal.name] then
                        signals[nework_signal.signal.name].count = signals[nework_signal.signal.name].count + nework_signal.count
                    else
                        signals[nework_signal.signal.name] = { signal = nework_signal.signal, count = nework_signal.count }
                    end
                end
            end
        end
    end

    for key, entity in pairs(global.entities) do
        local input_entity = entity.entity_input
        if input_entity and input_entity.valid then
            input_signals[key] = {}
            local signals = input_signals[key]

            local red_network = input_entity.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
            local green_network = input_entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)

            read_signals(red_network, signals)
            read_signals(green_network, signals)
        end
    end

end

local function process_events()
    for _, entity in pairs(global.entities) do
        for iter in entity.update_list:iterator() do
            local node_gui_element = iter.data.node_element.gui_element
            local node_update_logic = iter.data.node_element.update_logic

            if node_update_logic and node_update_logic.active then
                if node_update_logic.max_value >= node_update_logic.value then
                    node_update_logic.value = node_update_logic.value + 1
                else
                    node_update_logic.value = 0
                end

                if node_gui_element and node_gui_element.valid and node_update_logic.max_value ~= 0 then
                    -- Convert the game ticks to a range of 0..1
                    node_gui_element.value = node_update_logic.value / node_update_logic.max_value
                end
            end
        end
    end
end

local function write_output_signals()
    for key, entity in pairs(global.entities) do
        local entity_output = entity.entity_output

        if entity_output and entity_output.valid then
            local parameters = {}
            local index = 0
            local signals = input_signals[key]
            for _, signal in pairs(signals) do
                if signal and signal.signal and signal.count then
                    index = index + 1
                    parameters[index] = { index = index, signal = signal.signal, count = math.floor(signal.count)}
                end
            end
            entity_output.get_control_behavior().parameters = {parameters = parameters}
        end
    end
end

local function onTick(event)
    -- We must recreate all metatables once after a game is loaded
    game_node.recreate_metatables()
    list.recreate_metatables()

    read_input_signals()
    process_events()
    write_output_signals()
end



script.on_event(defines.events.on_tick, onTick)