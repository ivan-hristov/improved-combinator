local constants = require("constants")
local logger = require("scripts.logger")
local init = false


local function onInit()
    if not init then
        global.gui = global.gui or {}
        init = true
    end
end

local function addGuiFrameV(container, parent, key, style, caption)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "frame", direction="vertical", name = key})
	end
	container.caption = caption or container.caption
	container.style = style or container.style
	return container
end

local function addGuiButton(container, parent, action, key, style, caption, tooltip)
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
    
    gui.main = addGuiFrameV(gui.main, player.gui.center, constants.container.main_panel, constants.style.default_frame_fill)
    gui.options = addGuiFrameV(gui.options, gui.main, constants.container.options_panel, constants.style.options_frame)
    
    gui.button = addGuiButton(gui.button, gui.options, constants.actions.press_button, "", constants.style.add_condition_button, "first-button", "this-is-the-first-button")

    player.opened = gui.main
end

local function drawEmptyGui(player, player_index)
	global.gui[player_index] = global.gui[player_index] or {}
	local gui = global.gui[player_index]
	
	gui.main = addGuiFrameV(gui.main, player.gui.center, constants.container.hidden_panel, constants.style.hidden_frame)

	player.opened = gui.main
end

local function onGuiOpen(event)
    logger.print("function.onGuiOpen")
	
	onInit()

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
	if player.selected and player.selected.name == constants.entity.name then
		drawGui(player, event.player_index)
		global.gui.open = true
	elseif player.selected then
		if player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
			drawEmptyGui(player, event.player_index)
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




--script.on_init(onInit)
script.on_event(defines.events.on_gui_opened, onGuiOpen)
script.on_event(defines.events.on_gui_closed, onGuiClose)
