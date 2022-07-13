
local debug = false
local playerDataTable = {}


function onPlayerJoined(player)
    playerDataTable[player.playerId] = {
        
    }
end

tm.players.onPlayerJoined.add(onPlayerJoined)

function update()

end


