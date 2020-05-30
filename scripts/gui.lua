local constants = require("constants")
local logger = require("scripts.logger")
local init = false


local function onInit()
    if not init then
        global.gui = global.gui or {}
        init = true
    end
end

local function addGuiFrame(parent, container, style, direction, frame_name, caption)
    container = container or {}
    if not container or not container.valid then
        container = parent.add({type = "frame", style = "dialog_frame", direction = direction, name = frame_name})
    end
    container.caption = caption or container.caption
    container.style = style or container.style
    return container
end

local function addGuiButton(parent, container, style, button_name, caption, tooltip)
    container = container or {}
    if not container or not container.valid then
        container = parent.add({type = "button", name = button_name})
    end
    if style ~= nil then container.style = style end
    if caption ~= nil then container.caption = caption end
    if tooltip ~= nil then container.tooltip = tooltip end
    return container
end

local function drawGui(player, player_index)
    global.gui[player_index] = global.gui[player_index] or {}
    local gui = global.gui[player_index]

    gui.main_frame = addGuiFrame(player.gui.screen, gui.main_frame, constants.style.main_frame, "vertical", constants.container.main_panel, "MAIN FRAME")
    gui.main_frame.force_auto_center()

    gui.options_frame = addGuiFrame(gui.main_frame, gui.options_frame, constants.style.tasks_frame, "vertical", constants.container.tasks_panel)


    --gui.button = addGuiButton(gui.options_frame, gui.button, constants.style.large_button_frame, "ac_large_button_1", "+ Button")

    --gui.options = gui.options_frame.add({type = "list-box", name = "ac_options", items = {"item1", "item2"} })
    --gui.options.style = constants.style.options_list


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
    name = event.element.name or "nil"
    logger.print("function.onGuiClick name: "..name)
end

local function onGuiListClick(event)
    name = event.element.name or "nil"
    index = event.element.selected_index or "nil"
    --event.element.visible = false

    logger.print("function.onGuiListClick name: "..name.." index: "..index)
end


script.on_init(onInit)
script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
--script.on_event(defines.events.on_gui_click, onGuiClick)
--script.on_event(defines.events.on_gui_selection_state_changed, onGuiListClick)

