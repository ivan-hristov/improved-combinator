local constants = require("constants")
local logger = require("scripts.logger")
local unique_gui_index = 0

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

local function addGuiListBox(parent, list, style, name, items)
    list = list or {}
    if not list or not list.valid then
        list = parent.add({type = "list-box", name = name, items = items})
        list.style = style or list.style
    end
    return list
end

local function drawGui(player, player_index, entity)
    logger.print("function.drawGui")

    main = addGuiFrame(player.gui.screen, main, constants.style.main_frame, constants.container.main_panel, "MAIN FRAME "..entity.unit_number)
    main.force_auto_center()
    tasks_frame = addGuiFrame(main, tasks_frame, constants.style.tasks_frame, constants.container.tasks_panel)
    scroll_pane = addGuiScrollPane(tasks_frame, scroll_pane, constants.style.scroll_pane, "ac_scroll_pane")

    ---------------- Add drop down menu to add task ----------------
    add_task_button = addGuiButton(scroll_pane, add_task_button, constants.style.large_button_frame, "add_task_button", "+ Add Task")
    add_task_dropdown_options_frame = addGuiFrame(scroll_pane, add_task_dropdown_options_frame, constants.style.dropdown_options_frame, "add_task_dropdown_options_frame")
    add_task_dropdown_options_frame.visible = false
    add_task_list = addGuiListBox(add_task_dropdown_options_frame, add_task_list, constants.style.options_list, "add_task_list", {"Repeatable Timer", "Single User Timer", "3", "4", "5"})
    ----------------------------------------------------------------

    for _, v in  pairs(global.entities[entity.unit_number].logic) do
        addGuiFrame(scroll_pane, "", constants.style.conditional_frame, v)
    end

    global.opened_entity[player_index] = entity.unit_number
    player.opened = main
end

local function hideGui(player)
    logger.print("function.hideFrame")
    player.opened = nil
end

local function onGuiOpen(event)
    logger.print("function.onGuiOpen")

    if not event.entity then
        return
    end

    logger.print("Entity: "..event.entity.name..", ID: "..event.entity.unit_number)

    if event.player_index and game.players[event.player_index] then
        local player = game.players[event.player_index]    
        
        if player.selected then
            logger.print("Selected: "..player.selected.name)
        end
    end

    local player = game.players[event.player_index]
    if player.selected then        
        if player.selected.name == constants.entity.name then
            drawGui(player, event.player_index, event.entity)
        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            hideGui(player)
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
    local name = event.element.name
    local player = game.players[event.player_index]

    if name == "add_task_button" then
        tasks_frame = event.element.parent
        tasks_frame.add_task_dropdown_options_frame.visible = true
    end

    logger.print("function.onGuiClick name: "..name)
end

local function onGuiListClick(event)

    local name = event.element.name
    local index = event.element.selected_index

    if starts_with(name, "add_task_list") then
        if event.element.selected_index == 1 then
            unique_gui_index = unique_gui_index + 1
            new_element_name = "new_frame_name_"..unique_gui_index            

            addGuiFrame(event.element.parent.parent, nil, constants.style.conditional_frame, new_element_name)
  
            entity_unit_number = global.opened_entity[event.player_index]
            global.entities[entity_unit_number].logic = global.entities[entity_unit_number].logic or {}
            table.insert(global.entities[entity_unit_number].logic, new_element_name)
        end

        event.element.parent.visible = false
        event.element.selected_index = 0
    end

    logger.print("function.onGuiListClick name: "..name..", index: "..index)
end


script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
script.on_event(defines.events.on_gui_click, onGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, onGuiListClick)

