local constants = require("constants")

local init = false
local debugMode = true

--Print a message
local function debugLog(message)
    if debugMode then
        local player = game.players[1]
        if (player ~= nil) then
            player.print(message)
        end
	end
end

--local function onInit()
--    if not init then
--        global.gui = global.gui or {}
--        init = true
--    end
--end

local function addGuiFrameV(container, parent, key, style, caption)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "frame", direction="vertical", name = key})
	end
	container.caption = caption or container.caption
	container.style = style or container.style
	return container
end

local function drawGui(player, player_index)

    if not global.gui then
        global.gui = global.gui or {}
    end

	global.gui[player_index] = global.gui[player_index] or {}
    local gui = global.gui[player_index]
    
    gui.main = addGuiFrameV(gui.main, player.gui.center, constants.container.main_panel, constants.style.default_frame_fill)
    
    player.opened = gui.main
end

local function onGuiOpen(event)
    debugLog("function.onGuiOpen")
    
    if event.entity and event.entity.name then
        debugLog("Entity: "..event.entity.name)
    end

    if event.player_index and game.players[event.player_index] then
        local player = game.players[event.player_index]    
        
        if player.selected then
            debugLog("Selected: "..player.selected.name)
        end
    end

	local player = game.players[event.player_index]
	if player.selected and player.selected.name == constants.name then
		drawGui(player, event.player_index)
		global.gui.open = true
	end
end

local function onGuiClose(event)
    debugLog("function.onGuiClose")

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

--script.on_init(onInit)
script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
