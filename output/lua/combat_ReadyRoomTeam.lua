//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________


// dirty way to fix a bug
function ReadyRoomTeam:GetTeamType()
    return kNeutralTeamType
end

function ReadyRoomTeam:GetRespawnMapName(player)

    local mapName = player.kMapName    
    
    if mapName == nil then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    // Use previous life form if dead or in commander chair
    if (mapName == MarineCommander.kMapName) 
       or (mapName == AlienCommander.kMapName) 
       or (mapName == Spectator.kMapName) 
       or (mapName == AlienSpectator.kMapName) 
       or (mapName ==  MarineSpectator.kMapName) then 
    
        mapName = player:GetPreviousMapName()
        
    end
    
    // need to set embryos to ready room players, otherwise they wont be able to move
    if mapName == Embryo.kMapName then
        mapName = ReadyRoomPlayer.kMapName
    end
    return mapName
    
end