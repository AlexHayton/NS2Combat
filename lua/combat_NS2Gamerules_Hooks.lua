//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_NS2Gamerules_Hooks.lua

local HotReload = CombatNS2Gamerules
if(not HotReload) then
    CombatNS2Gamerules = {}
	ClassHooker:Mixin("CombatNS2Gamerules")
end

function CombatNS2Gamerules:OnLoad()

    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua")
	self:PostHookClassFunction("NS2Gamerules", "OnCreate", "OnCreate_Hook")
    self:ReplaceClassFunction("NS2Gamerules", "JoinTeam", "JoinTeam_Hook")
	self:PostHookClassFunction("NS2Gamerules", "OnUpdate", "OnUpdate_Hook")
	self:PostHookClassFunction("NS2Gamerules", "ChooseTechPoint", "ChooseTechPoint_Hook"):SetPassHandle(true)
	self:RawHookClassFunction("NS2Gamerules", "ResetGame", "ResetGame_Hook")
	self:RawHookClassFunction("NS2Gamerules", "UpdateMapCycle", "UpdateMapCycle_Hook")
	self:ReplaceClassFunction("NS2Gamerules", "CheckGameStart", "CheckGameStart_Hook")
    
    ClassHooker:SetClassCreatedIn("Gamerules", "lua/Gamerules.lua")
    self:PostHookClassFunction("Gamerules", "OnClientConnect", "OnClientConnect_Hook")
    
    self:ReplaceFunction("NS2Gamerules_GetUpgradedDamage", "NS2Gamerules_GetUpgradedDamage_Hook")
	
end

// Returns bool for success and bool if we've played in the game already.
local function GetUserPlayedInGame(self, player)

	local success = false
	local played = false
	
	local owner = Server.GetOwner(player)
	if owner then
	
		local userId = tonumber(owner:GetUserId())
		
		// Could be invalid if we're still connecting to Steam
		played = table.find(self.userIdsInGame, userId) ~= nil
		success = true
		
	end
	
	return success, played
	
end

local function SetUserPlayedInGame(self, player)

	local owner = Server.GetOwner(player)
	if owner then
	
		local userId = tonumber(owner:GetUserId())
		
		// Could be invalid if we're still connecting to Steam.
		return table.insertunique(self.userIdsInGame, userId)
		
	end
	
	return false
	
end

function UpdateUpgradeCountsForTeam(gameRules, teamIndex)

	// Get the number of players on the team who have the upgrade
	local oldCounts = gameRules.UpgradeCounts[teamIndex]
	local teamPlayers = GetEntitiesForTeam("Player", teamIndex)
	local numInTeam = #teamPlayers
	
	// Reset the upgrade counts
	gameRules.UpgradeCounts[teamIndex] = {}
	for upgradeIndex, upgrade in ipairs(GetAllUpgrades(teamIndex)) do
		gameRules.UpgradeCounts[teamIndex][upgrade:GetId()] = 0
	end
	
	// Recalculate the upgrade counts.
	for index, teamPlayer in ipairs(teamPlayers) do
	
		// Skip dead players
		if (teamPlayer:GetIsAlive()) then
			
			local playerTechTree = teamPlayer:GetCombatTechTree()
			for upgradeIndex, upgrade in ipairs(playerTechTree) do
				// Update the count for this upgrade.
				gameRules.UpgradeCounts[teamIndex][upgrade:GetId()] = gameRules.UpgradeCounts[teamIndex][upgrade:GetId()] + 1
			end
			
		end
		
	end		
	
	// Updates for each player.
	for upgradeId, upgradeCount in pairs(gameRules.UpgradeCounts[teamIndex]) do
		// Send any updates to all players
		if upgradeCount ~= oldCounts[upgradeId] then
			local teamPlayers = GetEntitiesForTeam("Player", teamIndex)
			for index, teamPlayer in ipairs(teamPlayers) do
				SendCombatUpgradeCountUpdate(teamPlayer, upgradeId, upgradeCount)
			end
		end
	end

end

// Don't do this too often - it is expensive!
local function UpdateUpgradeCounts(gameRules)

	UpdateUpgradeCountsForTeam(gameRules, kTeam1Index)
	UpdateUpgradeCountsForTeam(gameRules, kTeam2Index)
	
	// Return true to keep the loop going.
	return true

end

function CombatNS2Gamerules:OnCreate_Hook(self)

	self.UpgradeCounts = {}
	self.UpgradeCounts[kTeam1Index] = {}
	for index, upgrade in ipairs(GetAllUpgrades(kTeam1Index)) do
		self.UpgradeCounts[kTeam1Index][upgrade:GetId()] = 0
	end
	
	self.UpgradeCounts[kTeam2Index] = {}
	for index, upgrade in ipairs(GetAllUpgrades(kTeam2Index)) do
		self.UpgradeCounts[kTeam2Index][upgrade:GetId()] = 0
	end
	
	// Recalculate these every half a second.
	self:AddTimedCallback(UpdateUpgradeCounts, kCombatUpgradeUpdateInterval)

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
		
		local client = Server.GetOwner(newPlayer)
		local clientUserId = client and client:GetUserId() or 0
		local disconnectedPlayerRes = self.disconnectedPlayerResources[clientUserId]
		if disconnectedPlayerRes then
		
			newPlayer:SetResources(disconnectedPlayerRes)
			self.disconnectedPlayerResources[clientUserId] = nil
			
		else
		
			// Give new players starting resources. Mark players as "having played" the game (so they don't get starting res if
			// they join a team again, etc.)
			local success, played = GetUserPlayedInGame(self, newPlayer)
			if success and not played then
				newPlayer:SetResources(kPlayerInitialIndivRes)
			end
			
		end
		
		if self:GetGameStarted() then
			SetUserPlayedInGame(self, newPlayer)
		end
            
		
		newPlayer:TriggerEffects("join_team")
		
	end
	
	// This is the new bit for Combat
	if (success) then
        
        // Only reset things like techTree, scan, camo etc.		
		newPlayer:CheckCombatData()	
		local lastTeamNumber = newPlayer.combatTable.lastTeamNumber
		newPlayer:Reset_Lite()

		//newPlayer.combatTable.xp = player:GetXp()
		// if the player joins the same team, subtract one level
		if lastTeamNumber == newTeamNumber then
			if newPlayer:GetLvl() >= kCombatPenaltyLevel + 1 then
			    local newXP = Experience_XpForLvl(newPlayer:GetLvl()-1)
				newPlayer.score = newXP
				newPlayer.combatTable.lvl = newPlayer:GetLvl()
				newPlayer:SendDirectMessage( "You lost " .. kCombatPenaltyLevel .. " level for rejoining the same team!")
			end
		end
		newPlayer:AddLvlFree(newPlayer:GetLvl() - 1 + kCombatStartUpgradePoints)
		
		//set spawn protect
		newPlayer:SetSpawnProtect()
		
		// Send upgrade updates for each player.
		if newTeamNumber == kTeam1Index or newTeamNumber == kTeam2Index then
			for upgradeId, upgradeCount in pairs(self.UpgradeCounts[newTeamNumber]) do
				// Send all upgrade counts to this player
				SendCombatUpgradeCountUpdate(newPlayer, upgradeId, upgradeCount)
			end
		end
		
		// Send timer updates
		SendCombatGameTimeUpdate(newPlayer)
		
	end
	
	// Return old player
	return success, player
		
end

// If the client connects, send him the welcome Message
// Also grant average XP.
function CombatNS2Gamerules:OnClientConnect_Hook(self, client)

    local player = client:GetControllingPlayer()

	// Tell the player that Combat Mode is active.
    SendCombatModeActive(client, kCombatModActive)
	
	player:CheckCombatData()
    
    for i, message in ipairs(combatWelcomeMessage) do
        player:SendDirectMessage(message)  
    end
	
	// Give the player the average XP of all players on the server.
    if GetGamerules():GetGameStarted() then
		player.combatTable.setAvgXp = true
		local avgXp = Experience_GetAvgXp(player)
		// Send the avg as a message to the player (%d doesn't work with SendDirectMessage)
		if avgXp > 0 then
		    player:SendDirectMessage("You joined the game late... you will get some free Xp when you join a team!")
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
			// send timeleft to all players, but only every few min
			local exactTimeLeft = (kCombatTimeLimit - self.timeSinceGameStateChanged)
			local timeTaken = math.ceil(self.timeSinceGameStateChanged)
			local timeLeft = math.ceil(exactTimeLeft)
				
			if self:GetHasPassedTimelimit() then
				team2.combatTeamWon = true
			else
			    // spawn Halloweenai after some minutes
			    if kCombatHalloweenMode then
                    combatHalloween_CheckTime(timeTaken)
			    end
				// spawn Xmas gift after some time
				if kCombatXmasMode then
                    combatXmas_CheckTime(timeTaken)
			    end
				// send timeleft to all players, but only every few min
                if 	kCombatTimeLeftPlayed ~= timeLeft and
					((timeLeft % kCombatTimeReminderInterval) == 0 or 
					 (timeLeft == 60) or (timeLeft == 30) or
					 (timeLeft == 20) or (timeLeft == 10) or
					 (timeLeft <= 5)) then
                    local playersTeam1 = GetEntitiesForTeam("Player", kTeam1Index)
                    local playersTeam2 = GetEntitiesForTeam("Player", kTeam2Index)
					
					local timeLeftText = GetTimeText(timeLeft)
                    for index, player in ipairs(playersTeam1) do
                        player:SendDirectMessage( timeLeftText .." left until Marines have lost!")
                    end
                    
                    for index, player in ipairs(playersTeam2) do
                        player:SendDirectMessage( timeLeftText .." left until Aliens have won!")
                    end
                    
                    kCombatTimeLeftPlayed = timeLeft                
                end
			end
			
			// Periodic events...
			if timeTaken ~= kCombatTimePlayed then
				// Balance the teams once every 5 minutes or so...
				if timeTaken % kCombatRebalanceInterval == 0 then
					local avgXp = Experience_GetAvgXp()
					for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do      
						// Ignore players that are not on a team.
						if player:GetIsPlaying() then
							player:BalanceXp(avgXp)
						end
					end
				end
				
				kCombatTimePlayed = timeTaken
			end
		end
	else
		// reset kCombatTimePlayed
	    if kCombatTimePlayed ~= 0 then
	        kCombatTimePlayed = 0
	    end
	
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
	
		// Use some custom spawn picker code when the map gets too large.
		if #allTechPoints >= 5 then
        
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
	
	// Send timer updates
	for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
		SendCombatGameTimeUpdate(player)
	end

end

function CombatNS2Gamerules:UpdateMapCycle_Hook(self)

	if self.timeToCycleMap ~= nil and Shared.GetTime() >= self.timeToCycleMap then

		local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
		ModSwitcher_Save(nil, nil, playerCount, nil, nil, false)
	
	end

end

function CombatNS2Gamerules:NS2Gamerules_GetUpgradedDamage_Hook(attacker, doer, damage, damageType)

    local damageScalar = 1

    if attacker ~= nil then
    
        // Damage upgrades only affect weapons, not ARCs, Sentries, MACs, Mines, etc.
        if doer:isa("Weapon") or doer:isa("Grenade") or doer:isa("Minigun") or doer:isa("Railgun") then
        
            if(GetHasTech(attacker, kTechId.Weapons3, true)) then
            
                damageScalar = kWeapons3DamageScalar
                
            elseif(GetHasTech(attacker, kTechId.Weapons2, true)) then
            
                damageScalar = kWeapons2DamageScalar
                
            elseif(GetHasTech(attacker, kTechId.Weapons1, true)) then
            
                damageScalar = kWeapons1DamageScalar
                
            end
            
        end
        
    end
        
    return damage * damageScalar

end

function CombatNS2Gamerules:CheckGameStart_Hook(self)

    if self:GetGameState() == kGameState.NotStarted or self:GetGameState() == kGameState.PreGame then
        
        // Start pre-game when both teams have players or when once side does if cheats are enabled
        local team1Players = self.team1:GetNumPlayers()
        local team2Players = self.team2:GetNumPlayers()
            
        if (team1Players > 0 and team2Players > 0) or (Shared.GetCheatsEnabled() and (team1Players > 0 or team2Players > 0)) then
            
            if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
            end
                
        elseif self:GetGameState() == kGameState.PreGame then
            self:SetGameState(kGameState.NotStarted)
        end
            
    end

end

if (not HotReload) then
	CombatNS2Gamerules:OnLoad()
end