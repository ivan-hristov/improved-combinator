local constants = require("constants")
local logger = require("scripts.logger")

local input_signals = {}

local function readInputSignals()
    local entity = global.entity
    if entity then
        input_signals = {}
        local index = 0
        local red_network = entity.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
        local green_network = entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)
    
        if red_network and red_network.signals then            
            for _, nework_signal in pairs(red_network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    index = index + 1
                    input_signals[index] = {index = index, signal = nework_signal.signal, count=nework_signal.count}
                end
            end
        end

        if green_network and green_network.signals then            
            for _, nework_signal in pairs(green_network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    index = index + 1
                    input_signals[index] = {index = index, signal = nework_signal.signal, count=nework_signal.count}
                end
            end
        end
    end
end

local function processSignals()

end

local function writeOutputSignals()

    entity = global.entity
    if entity then
        -- WRITE
    end
end

local function onTick(event)
    --readInputSignals()
    --processSignals()
    --writeOutputSignals()
end



script.on_event(defines.events.on_tick, onTick)