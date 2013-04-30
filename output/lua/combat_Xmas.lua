//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Xmas.lua
// functions for the Xmas special

Script.Load("lua/Ragdoll.lua")

kCombatXmasMode = false

kXmasMessage = {"Ho Ho Ho, Santa Gorge brought you a Xmas gift",
                "Find it to earn some extra XP!",
                }
                     
kXmasFoundMessage = " has found the Xmas gift!"                     
kXmasNextSpawn = 0

function combatXmas_GetRandomTime()

    local random = math.random(20, 60)
    if random == 0 then
        random = 60
    end    
    return random 

end

function combatXmas_CheckTime(timeTaken)
    // palce a new gift after some time, but only if the old has been found, if not, destroy it
    if not kXmasNextSpawn or kXmasNextSpawn == 0 then
        kXmasNextSpawn = timeTaken + combatXmas_GetRandomTime()
    else
        if timeTaken >= kXmasNextSpawn then
            if kCombatGiftId then
                local xmasGift = Shared.GetEntity(kCombatGiftId)
            end

            combatXmas_AddGift()
            kXmasNextSpawn = timeTaken + combatXmas_GetRandomTime()
        end
    end
end   


function combatXmas_AddGift(player)

    local position
    local randomPlayer = nil
    
    if player then
        position = player:GetOrigin()
    else
        // if the command is not called by a player, spawn it randomly beside one player
        local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
        local players = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
        
		if (playerCount > 0) then
			randomPlayer = players[math.random(1, playerCount)]
	   
			if randomPlayer then
				for index = 1, 50 do
					position = GetRandomSpawnForCapsule(0.5, 0.5, randomPlayer:GetOrigin(), 10, 60, EntityFilterOne(randomPlayer))
					if position then
						break                
					end
				end
			end
		end
    end

    if position then
        // now we got a position, wait a bit maybe the player is dissapeared then
        local combatGift = CreateEntity(CombatXmasGift.kMapName, position , randomPlayer:GetTeamNumber())
        if combatGift then
            kCombatGiftId = combatGift:GetId()
            combatXmas_SendAppearMessage()
        end
    end
    
end

function combatXmas_SendAppearMessage()

    local players = Shared.GetEntitiesWithClassname("Player")
    for i, player in ientitylist(players) do
        for j, message in ipairs(kXmasMessage) do
            player:SendDirectMessage(message)  
        end
    end
    
end

function combatHalloween_SendPickedUpMessage(pickedUpPlayerName)

    if pickedUpPlayerName then
        local players = Shared.GetEntitiesWithClassname("Player")
        for i, player in ientitylist(players) do
            player:SendDirectMessage(pickedUpPlayerName .. kXmasFoundMessage  )  
        end
    end
    
end

function OnCommandCoXmas(client)

    local player = client:GetControllingPlayer()
    if Shared.GetCheatsEnabled() then
        combatXmas_AddGift(player)
    end

end

if kCombatXmasMode then
    Event.Hook("Console_co_xmas",       OnCommandCoXmas) 
end

    