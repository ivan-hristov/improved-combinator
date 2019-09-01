
local debugMode = true
local logger = {}

logger.print = function(message)
    if debugMode then
        local player = game.players[1]
        if (player ~= nil) then
            player.print(message)
        end
	end
end

return logger