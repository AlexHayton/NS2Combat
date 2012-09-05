//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_NS2Gamerules.lua


local HotReload = CombatNS2Gamerules
if(not HotReload) then
    CombatNS2Gamerules = {}
	ClassHooker:Mixin("CombatNS2Gamerules")
end

function CombatNS2Gamerules:OnLoad()

    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua")
    self:ReplaceClassFunction("NS2Gamerules", "JoinTeam", "JoinTeam_Hook")
	self:ReplaceClassFunction("NS2Gamerules", "GetUserPlayedInGame", "GetUserPlayedInGame_Hook")
	self:PostHookClassFunction("NS2Gamerules", "OnUpdate", "OnUpdate_Hook")
	self:PostHookClassFunction("NS2Gamerules", "ChooseTechPoint", "ChooseTechPoint_Hook"):SetPassHandle(true)
	self:RawHookClassFunction("NS2Gamerules", "ResetGame", "ResetGame_Hook")
    
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
        if player and player:GetTeamNumber() ~= newTeamNumber or force then
		
			local team = self:GetTeam(newTeamNumber)
			local oldTeam = self:GetTeam(player:GetTeamNumber())
			
			// Remove the player from the old queue if they happen to be in one
			if oldTeam ~= nil then
				oldTeam:RemovePlayerFromRespawnQueue(player)
			end
			
			// Spawn immediately if going to ready room, game hasn't started, cheats on, or game started recently
			if newTeamNumber == kTeamReadyRoom or self:GetCanSpawnImmediately() or force then
				
				success, newPlayer = team:ReplaceRespawnPlayer(player, nil, nil)
					
				local teamTechPoint = team.GetInitialTechPoint and team:GetInitialTechPoint()
				if teamTechPoint then
					newPlayer:OnInitialSpawn(teamTechPoint:GetOrigin())
				end
                
		else
		
			// Destroy the existing player and create a spectator in their place.
            newPlayer = player:Replace(team:GetSpectatorMapName(), newTeamNumber)
			
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
		
		// Only reset things like techTree, scan, camo etc.		
		newPlayer:CheckCombatData()		
		newPlayer:Reset_Lite()

		//newPlayer.combatTable.xp = player:GetXp()
		newPlayer:AddLvlFree(player:GetLvl() - 1 + kCombatStartUpgradePoints)
		
		//set spawn protect
		newPlayer:SetSpawnProtect()
		
	end
	
	// Return old player
	return success, player
		
end

// Stop NS2 Giving us 25 personal res at the start.
function CombatNS2Gamerules:GetUserPlayedInGame_Hook(self, player)

	local success = true
	local played = true
	return success, played

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
		// Send the avg as a message to the player (%d doesn't work with SendDirectMessage)
		if avgXp > 0 then
		    player:SendDirectMessage("You joined the game late... you get " .. avgXp .. " XP to spend!")
		    // get AvgXp 
		    player:AddXp(avgXp)
        end
	end    

end

// After a certain amount of time the aliens need to win (except if it's marines vs marines).
function CombatNS2Gamerules:OnUpdate_Hook(self, timePassed)
	local team1 = self:GetTeam(1)
	local team2 = self:GetTeam(2)
	
	// Check that it's Marines vs Aliens...
	if self:GetGameState() == kGameState.Started then
		if team1:isa("MarineTeam") and team2:isa("AlienTeam") then
			if self.timeSinceGameStateChanged >= kCombatTimeLimit then
				team2.combatTeamWon = true
			else
				// send timeleft to all players, but only every few min
				local exactTimeLeft = (kCombatTimeLimit - self.timeSinceGameStateChanged)
				local timeLeft = math.ceil(exactTimeLeft)
				
                if 	kCombatTimeLeftPlayed ~= timeLeft and
					((timeLeft % kCombatTimeReminderInterval) == 0 or 
					 (timeLeft == 60) or (timeLeft == 30) or
					 (timeLeft == 20) or (timeLeft == 10) or
					 (timeLeft <= 5)) then
                    local playersTeam1 = GetEntitiesForTeam("Player", kTeam1Index)
                    local playersTeam2 = GetEntitiesForTeam("Player", kTeam2Index)
					
					local timeLeftText
					if (timeLeft > 60) then
						timeLeftText = math.ceil(timeLeft/60) .." minutes"
					elseif (timeLeft == 60) then
						timeLeftText = "1 minute"
					elseif (timeLeft == 1) then
						timeLeftText = "1 second"
					else
						timeLeftText = timeLeft .." seconds"
					end
                    
                    for index, player in ipairs(playersTeam1) do
                        player:SendDirectMessage( timeLeftText .." left until Marines have lost!")
                    end
                    
                    for index, player in ipairs(playersTeam2) do
                        player:SendDirectMessage( timeLeftText .." left until Aliens have won!")
                    end
                    
                    kCombatTimeLeftPlayed = timeLeft                
                end
			end
		end
	else
	    // reset kCombatTimeLeftPlayed
	    if kCombatTimeLeftPlayed ~= 0 then
	        kCombatTimeLeftPlayed = 0
	    end
	end
end


// let ns2 find a techPoint for team1 and search the nearest techPoint for team2
function CombatNS2Gamerules:ChooseTechPoint_Hook(handle, self, techPoints, teamNumber)

    //GetLocationName() to get the name
    spawnTeam1Location, spawnTeam2Location = CombatGetSpawns()
    local allTechPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
        
    if  spawnTeam1Location ~= nil and  spawnTeam2Location ~=nil  then
    
        for i, techPoint in ipairs(allTechPoints) do
            // find the techPoint that fits to our team and LocationName
            if techPoint:GetLocationName() == ConditionalValue(teamNumber == kTeam1Index, spawnTeam1Location, spawnTeam2Location) then
                spawnTechPoint = techPoint
                break
            end                
        end
        
        CombatInitProps()
        // when no techPoint could be found, take the original techPoints
        
    else    
        
        // no spawn pairs, so search 2 near spawns 
        if teamNumber == kTeam1Index then        
            // if its team1, just search any random techPoint  
            local randomNumber = math.random(1, table.maxn(allTechPoints))
            spawnTechPoint = allTechPoints[randomNumber]
            
        else
        
            local team1TeachPoint = GetGamerules():GetTeam1():GetInitialTechPoint()
            local closestRange = nil
            
            for i, currentTechPoint in ipairs(allTechPoints) do
                // skip if we found team1techpoint
                if currentTechPoint ~= team1TeachPoint then
                    range = GetPathDistance(team1TeachPoint:GetOrigin(), currentTechPoint:GetOrigin())
                    if not closestRange then
                        closestRange = range
                        spawnTechPoint = currentTechPoint                    
                    else
                        if range < closestRange then
                            closestRange = range
                            spawnTechPoint = currentTechPoint
                        end
                    end
                end
            end 
  
        end
        
    end
        
    if spawnTechPoint then
        handle:SetReturn(spawnTechPoint)
    end
    
end


function CombatNS2Gamerules:ResetGame_Hook(self)

	// Reset teams and timers
	local team1 = self:GetTeam(1)
	local team2 = self:GetTeam(2)
	team1.combatTeamWon = nil
	team2.combatTeamWon = nil
	self.timeSinceGameStateChanged = 0

    // reset SpawnCombo to set them again
    combatSpawnCombo = nil
    combatSpawnComboIndex  = nil
    
    // we deactivated the prop system so this is not needed at the moment
    //CombatDeleteProps()

end

if (not HotReload) then
	CombatNS2Gamerules:OnLoad()
end