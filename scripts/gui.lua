local constants = require("constants")
local logger = require("scripts.logger")
local test_counter = 0
local gui_element_id = 0
local gui_elements = {}

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
            frame = parent.add({type = "frame", direction = "vertical", name = name})
            frame.caption = caption or frame.caption
            frame.style = style or frame.style
        end
    end
    return frame
end

local function addGuiScrollPane(parent, scroll_pane, style, name, caption)
    scroll_pane = scroll_pane or {}
    if not scroll_pane or not scroll_pane.valid then
        scroll_pane = parent.add({type = "scroll-pane", direction = "vertical", name = name})
        scroll_pane.caption = caption or scroll_pane.caption
        scroll_pane.style = style or scroll_pane.style
    end
    return scroll_pane
end

local function addGuiButton(parent, button, style, name, caption, tooltip)
    button = button or {}
    if not button or not button.valid then
        button = parent.add({type = "button", name = name})
        button.caption = caption or button.caption
        button.style = style or button.style
        button.tooltip = tooltip or button.tooltip
    end
    return button
end

local function addGuiFlow(parent, flow, name, direction)
    flow = flow or {}
    if not flow or not flow.valid then
        flow = parent.add({type = "flow", name = name, direction = direction})
    end
    return flow
end

local function addGuiListBox(parent, list, style, name, items)
    list = list or {}
    if not list or not list.valid then
        list = parent.add({type = "list-box", name = name, items = items})
        list.style = style or list.style
    end
    return list
end

local function drawGui(player, player_index)

    main = addGuiFrame(player.gui.screen, main, constants.style.main_frame, constants.container.main_panel, "MAIN FRAME 2")
    main.force_auto_center()
    tasks_frame = addGuiFrame(main, tasks_frame, constants.style.tasks_frame, constants.container.tasks_panel)

    ---------------- Add drop down menu to add task ----------------
    add_task_button = addGuiButton(tasks_frame, add_task_button, constants.style.large_button_frame, "add_task_button", "+ Add Task")
    add_task_dropdown_options_frame = addGuiFrame(tasks_frame, add_task_dropdown_options_frame, constants.style.dropdown_options_frame, "add_task_dropdown_options_frame")
    add_task_dropdown_options_frame.visible = false
    add_task_list = addGuiListBox(add_task_dropdown_options_frame, add_task_list, constants.style.options_list, "add_task_list", {"Repeatable Timer", "Single User Timer", "3", "4", "5"})
    ----------------------------------------------------------------

    for key, _ in  pairs(gui_elements) do
        addGuiFrame(tasks_frame, "", constants.style.conditional_frame, key)
    end

    --for key, _ in  pairs(gui_elements) do
    --    local ok, err = pcall(function() addGuiFrame(tasks_frame, "", constants.style.conditional_frame, key) end)
    --    if not ok then
    --        logger.print("function.drawGui ERROR")
    --        for i, name in pairs(tasks_frame.children_names) do
    --            logger.print("  "..name)
    --        end
    --    end
    --end

    player.opened = main
end

local function hideGui(player, player_index)
    logger.print("function.hideFrame")
    player.opened = nil
end

local function onGuiOpen(event)
    logger.print("function.onGuiOpen")
    
    if event.entity and event.entity.name then
        logger.print("Entity: "..event.entity.name)
    end

    if event.player_index and game.players[event.player_index] then
        local player = game.players[event.player_index]    
        
        if player.selected then
            logger.print("Selected: "..player.selected.name)
        end
    end

    local player = game.players[event.player_index]
    if player.selected then        
        if player.selected.name == constants.entity.name then
            drawGui(player, event.player_index)
        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            hideGui(player, event.player_index)
        end
    end
end

local function onGuiClose(event)
    logger.print("function.onGuiClose")

    local player = game.players[event.player_index]
    if player.opened then        
        player.opened = nil
    end

    if event.element then
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
            gui_element_id = gui_element_id + 1
            new_frame_name = "new_test_frame_"..gui_element_id
            gui_elements[new_frame_name] = gui_element_id            
            tasks_frame = event.element.parent.parent
            addGuiFrame(tasks_frame, "", constants.style.conditional_frame, new_frame_name)
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

