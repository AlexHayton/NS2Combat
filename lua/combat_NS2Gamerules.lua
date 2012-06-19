//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_NS2Gamerules.lua

if(not CombatNS2Gamerules) then
  CombatNS2Gamerules = {}
end

local HotReload = ClassHooker:Mixin("CombatNS2Gamerules")

function CombatNS2Gamerules:OnLoad()

    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua")
    self:ReplaceClassFunction("NS2Gamerules", "JoinTeam", "JoinTeam_Hook")
    
    ClassHooker:SetClassCreatedIn("Gamerules", "lua/Gamerules.lua")
    self:PostHookClassFunction("Gamerules", "OnClientConnect", "OnClientConnect_Hook")
	
end

	// Free the lvl when changing Teams
    /**
     * Returns two return codes: success and the player on the new team. This player could be a new
     * player (the default respawn type for that team) or it will be the original player if the team 
     * wasn't changed (false, original player returned). Pass force = true to make player change team 
     * no matter what and to respawn immediately.
     */
function CombatNS2Gamerules:JoinTeam_Hook(self, player, newTeamNumber, force)

	// The PostHook doesn't work because this function returns two values
	// So we need to replace instead. Sorry!
	local success = false
        
	// Join new team
	if(player and player:GetTeamNumber() ~= newTeamNumber or force) then
	
		local team = self:GetTeam(newTeamNumber)
		local oldTeam = self:GetTeam(player:GetTeamNumber())
		
		// Remove the player from the old queue if they happen to be in one
		if oldTeam ~= nil then
			oldTeam:RemovePlayerFromRespawnQueue(player)
		end
		
		// Spawn immediately if going to ready room, game hasn't started, cheats on, or game started recently
		if newTeamNumber == kTeamReadyRoom or self:GetCanSpawnImmediately() or force then
			success, newPlayer = team:ReplaceRespawnPlayer(player, nil, nil)
		else
		
			// Destroy the existing player and create a spectator in their place.
			local mapName = ConditionalValue(team:isa("AlienTeam"), AlienSpectator.kMapName, Spectator.kMapName)
			newPlayer = player:Replace(mapName, newTeamNumber)
			
			// Queue up the spectator for respawn.
			team:PutPlayerInRespawnQueue(newPlayer, Shared.GetTime())
			
			success = true
			
		end
		
		// Update frozen state of player based on the game state and player team.
		if team == self.team1 or team == self.team2 then
		
			local devMode = Shared.GetDevMode()
			local inCountdown = self:GetGameState() == kGameState.Countdown
			if not devMode and inCountdown then
				newPlayer.frozen = true
			end
			
		else
		
			// Ready room or spectator players should never be frozen
			newPlayer.frozen = false
			
		end
		
		newPlayer:TriggerEffects("join_team")
		
	end
	
	// This is the new bit for Combat
	if (success) then
		
		// Reinitialise the tech tree
		newPlayer.combatTechTree = nil
		newPlayer:CheckCombatData()
		
		// Update the combat data.
		newPlayer.combatTable.xp = player:GetXp()
		newPlayer.combatTable.lvlfree = player:GetLvl()
		newPlayer.combatTable.techtree = {}
		
		// don't get JP rine again when you're now an Alien
		newPlayer.combatTable.giveClassAfterRespawn = nil

	end
	
	return success, newPlayer
		
end

// If the client connects, send him the welcome Message
// Also grant average XP.
function CombatNS2Gamerules:OnClientConnect_Hook(self, client)
    local player = client:GetControllingPlayer()
    
    for i, message in ipairs(combatWelcomeMessage) do
        player:SendDirectMessage(message)  
    end
	
	// Give the player the average XP of all players on the server.
    if GetGamerules():GetGameStarted() then
		local avgXp = Experience_GetAvgXp()
		// Printing the avg xp to the Server Console for testing
		Print("You joined the game late... you get %d XP to spend!", avgXp)
		// get AvgXp 
		player:AddXp(avgXp)
	end    

end

if(HotReload) then
    CombatNS2Gamerules:OnLoad()
end