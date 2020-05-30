local constants = require("constants")
local logger = require("scripts.logger")
local init = false

------------- String Utils -------------
local function starts_with(str, start)
    return str:sub(1, #start) == start
end
----------------------------------------

local function onInit()
    if not init then
        global.gui = global.gui or {}
        init = true
    end
end

local function addGuiFrame(parent, frame, style, name, caption)
    frame = frame or {}
    if not frame or not frame.valid then
        frame = parent.add({type = "frame", direction = "vertical", name = name})
        frame.caption = caption or frame.caption
        frame.style = style or frame.style
    end
    return frame
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
    global.gui[player_index] = global.gui[player_index] or {}
    local gui = global.gui[player_index]

    gui.main = addGuiFrame(player.gui.screen, gui.main, constants.style.main_frame, constants.container.main_panel, "MAIN FRAME")
    gui.main.force_auto_center()

    gui.tasks_frame = addGuiFrame(gui.main, gui.tasks_frame, constants.style.tasks_frame, constants.container.tasks_panel)

    gui.ac_btn_1 = addGuiButton(gui.tasks_frame, gui.ac_btn_1, constants.style.large_button_frame, "ac_btn_1", "+ Button")
    gui.ac_frame_opt_1 = addGuiFrame(gui.tasks_frame, gui.ac_frame_opt_1, constants.style.options_frame, "ac_frame_opt_1")
    gui.ac_frame_opt_1.visible = false
    gui.ac_opt_1 = addGuiListBox(gui.ac_frame_opt_1, gui.ac_opt_1, constants.style.options_list, "ac_opt_1", {"item1", "item2"})
    

    gui.ac_btn_2 = addGuiButton(gui.tasks_frame, gui.ac_btn_2, constants.style.large_button_frame, "ac_btn_2", "+ Button 2")
    gui.ac_frame_opt_2 = addGuiFrame(gui.tasks_frame, gui.ac_frame_opt_2, constants.style.options_frame, "ac_frame_opt_2")
    gui.ac_frame_opt_2.visible = false
    gui.ac_opt_2 = addGuiListBox(gui.ac_frame_opt_2, gui.ac_opt_2, constants.style.options_list, "ac_opt_2", {"new items1", "new items2", "new items3"})

    player.opened = gui.main
end

local function hideGui(player, player_index)
    logger.print("function.hideFrame")
    global.gui[player_index] = nil
    global.gui.open = false
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
            global.gui.open = true
        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            hideGui(player, event.player_index)
        end
    end
end

local function onGuiClose(event)
    logger.print("function.onGuiClose")

    local player = game.players[event.player_index]
    if global.gui ~= nil and event.gui_type == defines.gui_type.custom then
        if global.gui.open and global.gui[event.player_index] ~= nil and global.gui[event.player_index].main == event.element then
            if global.gui[event.player_index].main and global.gui[event.player_index].main.valid then
                global.gui[event.player_index].main.destroy()
            end
            global.gui[event.player_index] = nil
            global.gui.open = false
            player.opened = nil
        end
    end
end

local function onGuiClick(event)
    global.gui[event.player_index] = global.gui[event.player_index] or {}
    local gui = global.gui[event.player_index]
    local name = event.element.name
    local player = game.players[event.player_index]

    if starts_with(name, "ac_btn_") then
        gui["ac_frame_opt_"..string.sub(name, -1)].visible = true
    end

    logger.print("function.onGuiClick name: "..name)
end

local function onGuiListClick(event)
    local name = event.element.name
    local index = event.element.selected_index

    if starts_with(name, "ac_opt_") then
        event.element.parent.visible = false
        event.element.selected_index = 0
    end

    logger.print("function.onGuiListClick name: "..name..", index: "..index)
end


script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
script.on_event(defines.events.on_gui_click, onGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, onGuiListClick)

