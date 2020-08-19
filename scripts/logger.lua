
local debugMode = false
logger = {}

function logger.print(message)
    if debugMode then
        local player = game.players[1]
        if (player ~= nil) then
            player.print(message)
        end
	end
end

return logger