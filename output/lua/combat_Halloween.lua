//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Halloween.lua
// functions for the halloween special

kCombatHalloweenMode = false

kHalloWeenMessage = {"!!! The burned Onos has appeared !!!",
                    "kill it before it kills you to earn some extra XP!",
                     }
                     
kHalloWeenKilledMessage = " has killed the burned Onos"
kHalloWeenSpawnTime = math.random(1,5) * 60
kHalloWeenNextSpawn = 0


function combatHalloween_CheckTime(timeTaken)
    // spawn Halloweenai after some minutes, but only if there is no ai
    if kCombatAllAi then
        if table.maxn(kCombatAllAi) == 0 then
            if kHalloWeenNextSpawn <= 0 then
                combatHalloween_RemoveAi()
                kHalloWeenNextSpawn = timeTaken + kHalloWeenSpawnTime
            else
                if timeTaken >= kHalloWeenNextSpawn then
                    combatHalloween_AddAi()
                    kHalloWeenNextSpawn = timeTaken + kHalloWeenSpawnTime
                end
            end
        else
            kHalloWeenNextSpawn = timeTaken + kHalloWeenSpawnTime
        end        
    else
        kCombatAllAi = {}
    end
    
end


function combatHalloween_AddAi(player)

    local position
    
    if player then
        position = player:GetOrigin()
    else
        // if the command is not called by a player, spawn it randomly beside one player
        local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
        local players = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
        
        local randomPlayer = players[math.random(playerCount)]
        while not randomPlayer:GetIsOnGround() do
            randomPlayer = players[math.random(playerCount)]
        end
                
        if randomPlayer then
            position = randomPlayer:GetOrigin() + Vector(1, 0, 0)
        end
    end

    if position then
        newAi = CreateEntity(AITEST.kMapName, position + Vector(1, 0, 0), kNeutralTeamType)
        if not kCombatAllAi then
            kCombatAllAi = {}
        end

        combatHalloween_SendAppearMessage()
        table.insert(kCombatAllAi, newAi:GetId()) 

    end
    
end


function combatHalloween_RemoveAi()

    if kCombatAllAi then
        if table.maxn(kCombatAllAi) > 0 then

            for i, entry in ipairs(kCombatAllAi) do
                local aiEntity = Shared.GetEntity(entry)
                if aiEntity then
                    DestroyEntity(aiEntity)
                end    
            end
            
            kCombatAllAi = {}
            
        end
    else
        kCombatAllAi = {}
    end

end

function combatHalloween_SendAppearMessage()

    local players = Shared.GetEntitiesWithClassname("Player")
    for i, player in ientitylist(players) do
        for j, message in ipairs(kHalloWeenMessage) do
            player:SendDirectMessage(message)  
        end
    end
    
end

function combatHalloween_SendKilledMessage(killerName)

    if killerName then
        local players = Shared.GetEntitiesWithClassname("Player")
        for i, player in ientitylist(players) do
            player:SendDirectMessage(killerName .. kHalloWeenKilledMessage )  
        end
    end
    
end


// Console Functions for testing

function OnCommandAddAi(client)

    if client ~= nil then
        local steamId = client:GetUserId()
        if Shared.GetCheatsEnabled() or IsSuperAdmin(steamId) then
            local player = client:GetControllingPlayer()
            combatHalloween_AddAi(player)        	
	    end    
    end
    
end

// delete added Ais
function OnCommandRemoveAi(client)

    if client ~= nil then
        local steamId = client:GetUserId()
        if Shared.GetCheatsEnabled() or IsSuperAdmin(steamId) then
            combatHalloween_RemoveAi()
	    end    
    end
    
end

if kCombatHalloweenMode then
    Event.Hook("Console_addai", OnCommandAddAi)
    Event.Hook("Console_removeai", OnCommandRemoveAi)
end

    