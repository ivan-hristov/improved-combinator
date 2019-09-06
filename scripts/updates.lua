local constants = require("constants")
local logger = require("scripts.logger")

local input_signals = {}
local current_index = 0

local function readInputSignals()
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
                    table.insert(input_signals, {index = index, signal = nework_signal.signal, count = nework_signal.count})
                    --logger.print("Reading red signals "..nework_signal.signal.name.." count "..nework_signal.count)
                end
            end
        end

        if green_network and green_network.signals then            
            for _, nework_signal in pairs(green_network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    index = index + 1
                    table.insert(input_signals, {index = index, signal = nework_signal.signal, count = nework_signal.count})
                    --logger.print("Reading green signals "..nework_signal.signal.name.." count "..nework_signal.count)
                end
            end
        end

        current_index = index
    end
end

local function processSignals()

end

local function writeOutputSignals()
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
    readInputSignals()
    processSignals()
    writeOutputSignals()
end



script.on_event(defines.events.on_tick, onTick)