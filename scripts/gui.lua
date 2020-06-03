local constants = require("constants")
local logger = require("scripts.logger")

------------- String Utils -------------
local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function contains_string(array, name)
    for _, k in pairs(array) do
        if k == name then
            return true
        end
    end
    return false
end
----------------------------------------

-------------- Utility Functions -------
local function addGuiFrame(parent, frame, style, name, caption)
    frame = frame or {}
    if not frame or not frame.valid then
        if not contains_string(parent.children_names, name) then
            frame = parent.add({type = "frame", direction = "vertical", name = name, style = style})
            frame.caption = caption or frame.caption
        end
    end
    return frame
end

local function addGuiScrollPane(parent, scroll_pane, style, name)
    scroll_pane = scroll_pane or {}
    if not scroll_pane or not scroll_pane.valid then
        scroll_pane = parent.add({
            type = "scroll-pane",
            direction = "vertical",
            name = key,
            style = style})
    end
    return scroll_pane
end

local function addGuiButton(parent, button, style, name, caption, tooltip)
    button = button or {}
    if not button or not button.valid then
        button = parent.add({type = "button", name = name, style = style})
        button.caption = caption or button.caption
        button.tooltip = tooltip or button.tooltip
    end
    return button
end

local function addGuiSpriteButton(parent, button, style, name, sprite, hovered_sprite, clicked_sprite)
    button = button or {}
    if not button or not button.valid then
        button = parent.add({type = "sprite-button", name = name, style = style, sprite = sprite, hovered_sprite = hovered_sprite, clicked_sprite = clicked_sprite})
    end
    return button
end

local function addGuiListBox(parent, list, style, name, items)
    list = list or {}
    if not list or not list.valid then
        list = parent.add({type = "list-box", name = name, items = items})
        list.style = style or list.style
    end
    return list
end

local function addGuiConditional(parent, frame_name, close_button_name)
    local conditional_frame = addGuiFrame(parent, conditional_frame, constants.style.conditional_frame, frame_name)
    addGuiSpriteButton(
        conditional_frame,
        close_button,
        constants.style.close_button_frame,
        close_button_name,
        "utility/close_white",
        "utility/close_black",
        "utility/close_black"
    )
end
----------------------------------------


local function buildGui(parent, unit_number)
    logger.print("function.buildGui")

    local main_frame = addGuiFrame(parent, main_frame, constants.style.main_frame, constants.container.main_panel, "MAIN FRAME "..unit_number)
    main_frame.force_auto_center()

    local tasks_frame = addGuiFrame(main_frame, tasks_frame, constants.style.tasks_frame, constants.container.tasks_panel)
    local scroll_pane = addGuiScrollPane(tasks_frame, scroll_pane, constants.style.scroll_pane, constants.container.scroll_pane)

    ---------------- Add drop down menu to add task ----------------
    local add_task_button = addGuiButton(scroll_pane, add_task_button, constants.style.large_button_frame, constants.container.add_task_button, "+ Add Task")
    local add_task_dropdown_options_frame = addGuiFrame(scroll_pane, add_task_dropdown_options_frame, constants.style.dropdown_options_frame, "add_task_dropdown_options_frame")
    add_task_dropdown_options_frame.visible = false
    local add_task_list = addGuiListBox(add_task_dropdown_options_frame, add_task_list, constants.style.options_list, constants.container.add_task_list, {"Repeatable Timer", "Single User Timer"})
    
    add_task_button_events = {}
    add_task_button_events.onClick = function(event)
        event.element.parent.add_task_dropdown_options_frame.visible = true
    end

    global.entities[unit_number].logic[constants.container.add_task_button] = add_task_button_events

    add_task_list_events = {}
    add_task_list_events.onSelectionChanged = {}
    add_task_list_events.onSelectionChanged[1] = function(event)
        local unit_number = global.opened_entity[event.player_index]
        local unique_gui_index = tostring(global.entities[unit_number].inner_elements_counter + 1)
        global.entities[unit_number].inner_elements_counter = unique_gui_index

        local condition = {}
        condition.dynamic = true
        condition.frame = "new_frame_name_"..unique_gui_index
        condition.close = "new_button_name_"..unique_gui_index
        global.entities[unit_number].logic[unique_gui_index] = condition

        addGuiConditional(event.element.parent.parent, condition.frame, condition.close)      
        event.element.parent.visible = false
        event.element.selected_index = 0

        local events = {}
        events.onClick = function(event)
            local name = event.element.name
            local unit_number = global.opened_entity[event.player_index]
            local number = tonumber(string.sub(name, string.len("new_button_name_") + 1))

            global.entities[unit_number].logic[number] = nil
            event.element.parent.destroy()
        end
        global.entities[unit_number].logic[condition.close] = events
    end
    add_task_list_events.onSelectionChanged[2] = function(event)
        
        event.element.parent.visible = false
        event.element.selected_index = 0
    end
    global.entities[unit_number].logic[constants.container.add_task_list] = add_task_list_events
    ----------------------------------------------------------------

    for _, v in  pairs(global.entities[unit_number].logic) do
        if v.dynamic then
            addGuiConditional(scroll_pane, v.frame, v.close)
        end
    end

    return main_frame
end

local function onGuiOpen(event)
    logger.print("function.onGuiOpen")

    if not event.entity then
        return
    end

    local player = game.players[event.player_index]
    if player.selected then        
        if player.selected.name == constants.entity.name then
            global.opened_entity[event.player_index] = event.entity.unit_number
            player.opened = buildGui(player.gui.screen, event.entity.unit_number)
        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            player.opened = nil
        end
    end
end

local function onGuiClose(event)
    logger.print("function.onGuiClose")

    if event.element then
        local player = game.players[event.player_index]
        if player.opened then        
            player.opened = nil
        end
    
        if global.opened_entity then
            global.opened_entity[event.player_index] = nil
        end

        event.element.destroy()
        event.element = nil
    end
end

local function onGuiClick(event)
    logger.print("function.onGuiClick name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local entity_unit_number = global.opened_entity[event.player_index]

    local logic = global.entities[entity_unit_number].logic[name]
    if logic then
        logic.onClick(event)
    end

end

local function onGuiListClick(event)
    logger.print("function.onGuiListClick name: "..event.element.name)

    local name = event.element.name
    local player = game.players[event.player_index]
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    local logic = global.entities[unit_number].logic[name]
    if logic then
        logic.onSelectionChanged[selected_index](event)
    end
end


script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
script.on_event(defines.events.on_gui_click, onGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, onGuiListClick)

