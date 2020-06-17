local constants = require("constants")
local logger = require("scripts.logger")

local input_signals = {}
local current_index = 0

local function read_input_signals()
    local entity = global.entity_input
    if entity and entity.valid then
        input_signals = {}
        local index = 0
        local red_network = entity.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
        local green_network = entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)

        red_signals_new = red_network
    
        if red_network and red_network.signals then            
            for _, nework_signal in pairs(red_network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    index = index + 1
                    input_signals[index] = {index = index, signal = nework_signal.signal, count = nework_signal.count}
                end
            end
        end

        if green_network and green_network.signals then            
            for _, nework_signal in pairs(green_network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    index = index + 1
                    input_signals[index] = {index = index, signal = nework_signal.signal, count = nework_signal.count}
                end
            end
        end

        current_index = index
    end
end


local function process_events()
    for _, entity in pairs(global.entities) do
        for _, node in pairs(entity.update_list) do

            if node.logic.max_value >= node.logic.value then
                node.logic.value = node.logic.value + 1
            else
                node.logic.value = 0
            end

            if node.gui_element and node.gui_element.valid and node.logic.max_value ~= 0 then
                --logger.print("Type: "..node.gui.type)
                -- Convert the game ticks to a range of 0..1
                node.gui_element.value = node.logic.value / node.logic.max_value
            end
            
        end
    end
end

local function write_output_signals()
    entity = global.entity_output
    if entity and entity.valid and input_signals and current_index > 0 then

        --for _, signal in pairs(input_signals) do
        --    logger.print("Entity "..entity.name.." type "..entity.type)
        --    logger.print("Signals index "..signal.index.." name "..signal.signal.name.." count "..signal.count.." current count "..entity.get_control_behavior().signals_count)    
        --    entity.get_control_behavior().set_signal(signal.index, {signal = signal.signal, count = signal.count})
        --end

        entity.get_control_behavior().parameters = {parameters = input_signals}
    end
end

local function onTick(event)
    read_input_signals()
    process_events()
    write_output_signals()
end



script.on_event(defines.events.on_tick, onTick)