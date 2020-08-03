local constants = require("constants")
local game_node = require("game_node")
local list = require("list")
local logger = require("logger")
local bitwise_math = require("bitwise_math")
local cached_signals = require("cached_signals")
local overlay_gui = require("overlay_gui")

local game_loaded = false
local input_signals = {}
local output_signals = {}

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

    if update_logic.activation_queued_on and update_logic.activation_queued_on ~= game.tick then
        update_logic.activation_queued_on = nil
        update_logic.active = true
    end

    if update_logic and update_logic.active then
        if update_logic.max_value > update_logic.value then
            update_logic.value = update_logic.value + 1
        else
            update_logic.value = 0
            timer_finished = true

            if not update_logic.repeatable then
                update_logic.active = false
            end
        end

        if gui_element and gui_element.valid and update_logic.max_value ~= 0 then
            -- Convert the game ticks to a range of 0..1
            gui_element.value = update_logic.value / update_logic.max_value
        end

        if update_logic.every_tick then
            return true
        end
    end

    return timer_finished
end

local function is_invalid(update_logic)
    return (update_logic.signal_result == nil and update_logic.callable_node_id == nil) or
    (update_logic.signal_slot_1 == nil and update_logic.value_slot_1 == nil) or
    (update_logic.signal_slot_2 == nil and update_logic.value_slot_2 == nil)
end

local function get_value(input_signal, signal, value)
    local result = 0
    if value then
        result = value
    elseif signal and input_signal[signal.name] then
        result = input_signal[signal.name].count
    end
    return result
end

local function set_output_signal(signal, entity_id, result)
    if output_signals[entity_id] == nil then
        output_signals[entity_id] = {}
    end

    if output_signals[entity_id][signal.name] ~= nil then
        result = output_signals[entity_id][signal.name].count + result
    end
    
    output_signals[entity_id][signal.name] = { signal = signal, count = result }
end

local function schedule_callable_timer(entity_id, node_id)
    local node = global.entities[entity_id].node:recursive_find(node_id)
    if node and not node.update_logic.active and not node.update_logic.activation_queued_on then
        node.update_logic.activation_queued_on = game.tick
    end
end

local function update_constant_combinator(input_signal, entity_id, update_logic)
    if is_invalid(update_logic) then
        return
    end

    local left_count = get_value(input_signal, update_logic.signal_slot_1, update_logic.value_slot_1)
    local right_count = get_value(input_signal, update_logic.signal_slot_2, update_logic.value_slot_2)

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

    --local callable = update_logic.callable_combinator and tostring(update_logic.callable_combinator) or "nil"
    --logger.print("Combinator at: "..update_logic.sign_index.." left: "..tostring(left_count).." right: "..tostring(right_count).." callable: "..callable)

    if combinator_result ~= nil then
        if update_logic.callable_combinator then
            schedule_callable_timer(entity_id, update_logic.callable_node_id)
        else
            if not update_logic.output_value then
                combinator_result =  1
            end
            set_output_signal(update_logic.signal_result, entity_id, combinator_result)
        end
     end
end

local function update_arithmetic_combinator(input_signal, entity_id, update_logic)
    if is_invalid(update_logic) then
        return
    end

    local left_count = get_value(input_signal, update_logic.signal_slot_1, update_logic.value_slot_1)
    local right_count = get_value(input_signal, update_logic.signal_slot_2, update_logic.value_slot_2)

    local arithmetic_result = nil

    if update_logic.sign_index == 1 then
        --- * ---
        arithmetic_result = left_count * right_count

    elseif update_logic.sign_index == 2 then
        --- / ---
        if right_count ~= 0 then
            arithmetic_result = left_count / right_count
        end

    elseif update_logic.sign_index == 3 then
        --- + ---
        arithmetic_result = left_count + right_count

    elseif update_logic.sign_index == 4 then
        --- - ---
        arithmetic_result = left_count - right_count

    elseif update_logic.sign_index == 5 then
        --- % ---
        arithmetic_result = left_count % right_count

    elseif update_logic.sign_index == 6 then
        --- ^ ---
        arithmetic_result = left_count ^ right_count

    elseif update_logic.sign_index == 7 then
        --- << ---
        arithmetic_result = bitwise_math.left_shift(left_count, right_count)
        
    elseif update_logic.sign_index == 8 then
        --- >> ---
        arithmetic_result = bitwise_math.right_shift(left_count, right_count)

    elseif update_logic.sign_index == 9 then
        --- AND ---
        arithmetic_result = bitwise_math.bitwise_and(left_count, right_count)

    elseif update_logic.sign_index == 10 then
        --- OR ---
        arithmetic_result = bitwise_math.bitwise_or(left_count, right_count)

    elseif update_logic.sign_index == 11 then
        --- XOR ---
        arithmetic_result = bitwise_math.bitwise_xor(left_count, right_count)
    end

    if arithmetic_result ~= nil then
        set_output_signal(update_logic.signal_result, entity_id, arithmetic_result)
    end

end

local function process_events()
    for entity_id, entity in pairs(global.entities) do
        local input_signal = input_signals[entity_id]
        if input_signal then
            for iter in entity.update_list:iterator() do
                local check_combinators = update_timer_and_progress_bar(
                    iter.data.node_element.gui_element,
                    iter.data.node_element.update_logic)

                if check_combinators then
                    for child_iter in iter.data.children:iterator() do
                        local update_logic = child_iter.data.node_element.update_logic
                        if update_logic.constant_combinator or update_logic.callable_combinator then
                            update_constant_combinator(input_signal, entity_id, update_logic)
                        elseif update_logic.arithmetic_combinator then
                            update_arithmetic_combinator(input_signal, entity_id, update_logic)
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
                -- TODO -- Consider removal of signals comming from other mods
                entity_output.get_control_behavior().parameters = {parameters = parameters}
            else
                entity_output.get_control_behavior().parameters = {parameters = nil}
            end
        end
    end
end

local function validate_sigals()

    local function recursive_signal_search(node)
        if node.gui.type == "choose-elem-button" and node.gui.elem_value then
            if cached_signals.functions.on_contains_element(node.gui.elem_value) == false then
                node.gui.elem_value = nil
            end
        end

        for _, child in pairs(node.children) do
            recursive_signal_search(child)
        end
    end


    for entity_id, entity in pairs(global.entities) do

        recursive_signal_search(entity.node)

        for iter in entity.update_list:iterator() do
            for child_iter in iter.data.children:iterator() do
                local update_logic = child_iter.data.node_element.update_logic

                if update_logic.signal_slot_1 then
                    if cached_signals.functions.on_contains_element(update_logic.signal_slot_1) == false then
                        update_logic.signal_slot_1 = nil
                    end
                end

                if update_logic.signal_slot_2 then
                    if cached_signals.functions.on_contains_element(update_logic.signal_slot_2) == false then
                        update_logic.signal_slot_2 = nil
                    end
                end

                if update_logic.signal_result then
                    if cached_signals.functions.on_contains_element(update_logic.signal_result) == false then
                        update_logic.signal_result = nil
                    end
                end
            end
        end
    end
end

local function on_tick()
    -- Recreate all metatables once after a game is loaded
    if not game_loaded then
        overlay_gui.on_load()
        cached_signals.functions.on_game_load()
        game_node.recreate_metatables()
        list.recreate_metatables()
        validate_sigals()
        game_loaded = true
    end

    input_signals = {}
    output_signals = {}

    read_input_signals()
    process_events()
    write_output_signals()
end


script.on_event(defines.events.on_tick, on_tick)