local constants = require("constants")
local logger = require("scripts.logger")
local init = false


local function onInit()
    if not init then
        global.gui = global.gui or {}
        init = true
    end
end

-- Not Used --
local function addGuiFrameH(parent, container, style, key, caption)
    container = container or {}
    if not container or not container.valid then
        container = parent.add({
            type = "frame",
            style = "dialog_frame",
            direction ="horizontal",
            name = key
        })
    end
    container.caption = caption or container.caption
    container.style = style or container.style
    return container
end

local function addGuiFrameV(parent, container, style, key, caption)
    container = container or {}
    if not container or not container.valid then
        container = parent.add({
            type = "frame",
            style = "dialog_frame",
            direction = "vertical",
            name = key
        })
    end
    container.caption = caption or container.caption
    container.style = style or container.style
    return container
end

local function addGuiButton(parent, container, style, key, caption, action, tooltip)
    container = container or {}
    if key ~= nil then action = action..key end
    if not container or not container.valid then
        container = parent.add({type = "button", name = action})
    end
    if style ~= nil then container.style = style end
    if caption ~= nil then container.caption = caption end
    if tooltip ~= nil then container.tooltip = tooltip end
    return container
end

local function drawGui(player, player_index)
    global.gui[player_index] = global.gui[player_index] or {}
    local gui = global.gui[player_index]
    
    gui.main = addGuiFrameV(player.gui.screen, gui.main, constants.style.main_frame, constants.container.main_panel, "MAIN FRAME")
    gui.main.force_auto_center()

    gui.options = addGuiFrameV(gui.main, gui.options, constants.style.options_frame, constants.container.options_panel)
    gui.button = addGuiButton(gui.options, gui.button, constants.style.large_button_frame, "ac_large_button_1", "Button", "")

    player.opened = gui.main
end

-- Not used --
local function drawEmptyGui(player, player_index)
    global.gui[player_index] = global.gui[player_index] or {}
    local gui = global.gui[player_index]
    
    gui.main = addGuiFrameV(gui.main, player.gui.center, constants.container.hidden_panel, constants.style.hidden_frame)

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
    element = event.element
    name = element.name or "nil"
    parent_name = "nil"
    if element.parent then
        parent_name = element.parent.name
    end

    --logger.print("function.onGuiClick name: "..name.." parent: "..parent_name)
end


script.on_init(onInit)
script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
script.on_event(defines.events.on_gui_click, onGuiClick)
