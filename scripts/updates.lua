local constants = require("constants")
local game_node = require("game_node")
local list = require("list")
local logger = require("logger")

local input_signals = {}
local output_signals = {}
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

    for entity_id, entity in pairs(global.entities) do
        local input_entity = entity.entity_input
        if input_entity and input_entity.valid then
            input_signals[entity_id] = {}
            local signals = input_signals[entity_id]

            local red_network = input_entity.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
            local green_network = input_entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)

            read_signals(red_network, signals)
            read_signals(green_network, signals)
        end
    end

end

local function update_timer_and_progress_bar(gui_element, update_logic)
    local timer_finished = false

    if update_logic and update_logic.active then
        if update_logic.max_value >= update_logic.value then
            update_logic.value = update_logic.value + 1
        else
            update_logic.value = 0
            timer_finished = true
        end

        if gui_element and gui_element.valid and update_logic.max_value ~= 0 then
            -- Convert the game ticks to a range of 0..1
            gui_element.value = update_logic.value / update_logic.max_value
        end
    end

    return timer_finished
end

local function update_constant_combinator(input_signal, entity_id, update_logic)

    logger.print("line 64")
    if update_logic.signal_result == nil or
       (update_logic.signal_slot_1 == nil and update_logic.value_slot_1 == nil) or
       (update_logic.signal_slot_2 == nil and update_logic.value_slot_2 == nil) then
        return
    end

    logger.print("line 71")
    local function get_value(signal, value)
        local result = 0
        if value then
            result = value
        elseif signal and input_signal[signal.name] then
            result = input_signal[signal.name].count
        end
        return result
    end

    logger.print("line 82")
    local left_count = get_value(update_logic.signal_slot_1, update_logic.value_slot_1)
    local right_count = get_value(update_logic.signal_slot_2, update_logic.value_slot_2)

    logger.print("left_count: "..left_count)
    logger.print("right_count: "..right_count)

    local combinator_result = nil

    if update_logic.sign_index == 1 then
        --- ">" ---
        if left_count > right_count then
            combinator_result = left_count
        end
    elseif update_logic.sign_index == 2 then
        --- "<" ---
        if left_count < right_count then
            combinator_result = left_count
        end
    elseif update_logic.sign_index == 3 then
        --- "=" ---
        if left_count == right_count then
            combinator_result = left_count
        end
    elseif update_logic.sign_index == 4 then
        --- "≥" ---
        if left_count >= right_count then
            combinator_result = left_count
        end
    elseif update_logic.sign_index == 5 then
        --- "≤" ---
        if left_count <= right_count then
            combinator_result = left_count
        end
    elseif update_logic.sign_index == 6 then
        --- "≠" ---
        if left_count ~= right_count then
            combinator_result = left_count
        end
    end

    if combinator_result ~= nil then
        if not update_logic.output_value then
            combinator_result =  1
        end
        
        if output_signals[entity_id] == nil then
            output_signals[entity_id] = {}
        end

        if output_signals[entity_id][update_logic.signal_result.name] ~= nil then
            combinator_result = output_signals[entity_id][update_logic.signal_result.name].count + combinator_result
        end
        
        output_signals[entity_id][update_logic.signal_result.name] = { signal = update_logic.signal_result, count = combinator_result }
    end

end

local function process_events()
    for entity_id, entity in pairs(global.entities) do

        local input_signal = input_signals[entity_id]

        if input_signal then
            for iter in entity.update_list:iterator() do
                local timer_finished = update_timer_and_progress_bar(
                    iter.data.node_element.gui_element,
                    iter.data.node_element.update_logic)

                if timer_finished then
                    for child_iter in iter.data.children:iterator() do
                        local update_logic = child_iter.data.node_element.update_logic
                        if update_logic.constant_combinator then
                            update_constant_combinator(input_signal, entity_id, update_logic)
                        end
                    end
                end
            end
        end
    end
end

local function write_output_signals()
    for entity_id, entity in pairs(global.entities) do
        local entity_output = entity.entity_output

        if entity_output and entity_output.valid then
            local parameters = {}
            local index = 0
            local signals = output_signals[entity_id]

            if signals then
                for _, signal in pairs(signals) do
                    if signal and signal.signal and signal.count then
                        index = index + 1
                        parameters[index] = { index = index, signal = signal.signal, count = math.min(math.floor(signal.count), 2100000000) }
                    end
                end
                entity_output.get_control_behavior().parameters = {parameters = parameters}
            else
                entity_output.get_control_behavior().parameters = {parameters = nil}
            end
        end
    end
end

local function onTick(event)
    -- We must recreate all metatables once after a game is loaded
    game_node.recreate_metatables()
    list.recreate_metatables()

    input_signals = {}
    output_signals = {}

    read_input_signals()
    process_events()
    write_output_signals()
end



script.on_event(defines.events.on_tick, onTick)