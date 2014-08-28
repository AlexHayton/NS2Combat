//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_PlayingTeam.lua

local HotReload = CombatPlayingTeam
if(not HotReload) then
  CombatPlayingTeam = {}
  ClassHooker:Mixin("CombatPlayingTeam")
end
    
function CombatPlayingTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("PlayingTeam", "lua/PlayingTeam.lua") 
    self:ReplaceClassFunction("PlayingTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
    self:ReplaceClassFunction("PlayingTeam", "GetHasTeamLost", "GetHasTeamLost_Hook")
	self:ReplaceClassFunction("PlayingTeam", "UpdateTechTree", function() return true end)
	self:ReplaceClassFunction("PlayingTeam", "Update", "Update_Hook")
	self:ReplaceClassFunction("PlayingTeam", "RespawnPlayer", "RespawnPlayer_Hook")
    
end

//___________________
// Hooks Playing Team
//___________________

function CombatPlayingTeam:GetHasTeamLost_Hook(self)
    // Don't bother with the original - we just set our own logic here.
	// You can lose with cheats on (testing purposes)
	if(GetGamerules():GetGameStarted()) then
    
        // Team can't respawn or last Command Station or Hive destroyed
        local numCommandStructures = self:GetNumCommandStructures()
        
        if  ( numCommandStructures == 0 ) or
            ( self:GetNumPlayers() == 0 ) then
            
            return true
            
        end
            
    end

    return false

end

function CombatPlayingTeam:SpawnInitialStructures_Hook(self, techPoint)
    // Dont Spawn RTS or Cysts
        
    ASSERT(techPoint ~= nil)

    // Spawn hive/command station at team location
    local commandStructure = techPoint:SpawnCommandStructure(self:GetTeamNumber())
    assert(commandStructure ~= nil)
    commandStructure:SetConstructionComplete()
    
    // Use same align as tech point.
    local techPointCoords = techPoint:GetCoords()
    techPointCoords.origin = commandStructure:GetOrigin()
    commandStructure:SetCoords(techPointCoords)
    
    //if commandStructure:isa("Hive") then
      //  commandStructure:SetFirstLogin()
    //end
	
	// Set the command station to be occupied.
	if commandStructure:isa("CommandStation") then
		commandStructure.occupied = true
		//commandStructure:UpdateCommanderLogin(true)
	end
	
	return tower, commandStructure
    
end

// Respawn timers.
function CombatPlayingTeam:Update_Hook(self, timePassed)

	if self.timeSinceLastSpawn == nil then 
		CombatPlayingTeam:ResetSpawnTimer(self)
	end
	
	// Increment the spawn timer
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + timePassed
	
    // check if there are really no Spectators (should fix the spawnbug)
	local players = GetEntitiesForTeam("Spectator", self:GetTeamNumber())
	
	// Spawn all players in the queue once every 10 seconds or so.
	if (#self.respawnQueue > 0) or (#players > 0)  then
		
		// Are we ready to spawn? This is based on the time since the last spawn wave...
		local respawnTimer = kCombatRespawnTimer
		if GetHasTimelimitPassed() then
			respawnTimer = kCombatOvertimeRespawnTimer
		end
		local timeToSpawn = (self.timeSinceLastSpawn >= respawnTimer)
		
		if timeToSpawn then
			// Reset the spawn timer.
			CombatPlayingTeam:ResetSpawnTimer(self)
			
			// Loop through the respawn queue and spawn dead players.
			// Also handle the case where there are too many players to spawn all of them - do it on a FIFO basis.
			local lastPlayer = nil
			local thisPlayer = self:GetOldestQueuedPlayer()
			
			if thisPlayer then
                while (lastPlayer == thisPlayer) or (thisPlayer ~= nil) do
                    local success = CombatPlayingTeam:SpawnPlayer(thisPlayer)
                    // Don't crash the server when no more players can spawn...
                    if not success then break end
                    
                    lastPlayer = thisPlayer
                    thisPlayer = self:GetOldestQueuedPlayer()
                end
            else
                // somethings wrong, spawn all Spectators
                for i, player in ipairs(players) do
                    local success = CombatPlayingTeam:SpawnPlayer(player)
                    // Don't crash the server when no more players can spawn...
                    if not success then break end
                end
            end
			
			// If there are any players left, send them a message about why they didn't spawn.
			if (#self.respawnQueue > 0) then
				for i, player in ipairs(self.respawnQueue) do
				    // sanity check if there are ids instead of objects
				    if (IsNumber(player)) then
				        player = Shared.GetEntity(player)
				    end
				    if (player) then
					    player:SendDirectMessage("Could not find a valid spawn location for you... You will spawn in the next wave instead!")
                    end					    
				end
			elseif (#players > 0) then
                for i, player in ipairs(players) do
					player:SendDirectMessage("Could not find a valid spawn location for you... You will spawn in the next wave instead!")
				end
            end
            
		else
			// Send any 'waiting to respawn' messages (normally these only go to AlienSpectators)
			for index, player in pairs(self:GetPlayers()) do				
				if not player.waitingToSpawnMessageSent then
					if player:GetIsAlive() == false then
						SendPlayersMessage({ player }, kTeamMessageTypes.SpawningWait)
						player.waitingToSpawnMessageSent = true

						// TODO: Update the GUI so that marines can get the 'ready to spawn in ... ' message too.
						// After that is done, remove the AlienSpectator check here.
						if (player:isa("AlienSpectator")) then
							player.timeWaveSpawnEnd = nextSpawnTime
						end
					end
				end
			end
		end
	
	end
	
	if not self.timeSincePropEffect then
        self.timeSincePropEffect = 0
    else
        self.timeSincePropEffect = self.timeSincePropEffect + timePassed
    end
	
	if self.timeSincePropEffect >= kPropEffectTimer then
        // resend prop messages	        
        CombatUpdatePropEffect(self)
        self.timeSincePropEffect = 0
    end
    
end

function CombatPlayingTeam:ResetSpawnTimer(self)

	// Reset the spawn timer
	self.timeSinceLastSpawn = 0
	if not GetHasTimelimitPassed() then
		self.nextSpawnTime = Shared.GetTime() + kCombatRespawnTimer
	else
		self.nextSpawnTime = Shared.GetTime() + kCombatOvertimeRespawnTimer
	end
			
end

function CombatPlayingTeam:SpawnPlayer(player)

    local success = false

	player.isRespawning = true
	SendPlayersMessage({ player }, kTeamMessageTypes.Spawning)

    if Server then
        
        if player.SetSpectatorMode then
            player:SetSpectatorMode(kSpectatorMode.Following)
        end
  
    end

    if player.combatTable and player.combatTable.giveClassAfterRespawn then
        success, newPlayer  = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil, player.combatTable.giveClassAfterRespawn)
    else
		// Spawn normally		
        success, newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil)
    end
	
	if success then
		// Give any upgrades back
        newPlayer:GiveUpsBack()    
	
        // Make a nice effect when you spawn.
		// Aliens hatch due the CoEvolve function
        if newPlayer:isa("Marine") or newPlayer:isa("Exo") then
            newPlayer:TriggerEffects("infantry_portal_spawn")
        end
		newPlayer:TriggerEffects("spawnSoundEffects")
		newPlayer:GetTeam():RemovePlayerFromRespawnQueue(newPlayer)
		
		// Remove the third-person mode (bug introduced in 216).
		newPlayer:SetCameraDistance(0)
		
		//give him spawn Protect (dont set the time here, just that spawn protect is active)
		newPlayer:SetSpawnProtect()
		
		// always switch to first weapon
		newPlayer:SwitchWeapon(1)
		
		// Send timer updates
		SendCombatGameTimeUpdate(newPlayer)
    end

    return success

end

// Another copy job I'm afraid...
// The default spawn code just isn't strong enough for us. Give it a dose of coffee.
// Call with origin and angles, or pass nil to have them determined from team location and spawn points.
function CombatPlayingTeam:RespawnPlayer_Hook(self, player, origin, angles)

    local success = false
    local initialTechPoint = Shared.GetEntity(self.initialTechPointId)
    
    if origin ~= nil and angles ~= nil then
        success = Team.RespawnPlayer(self, player, origin, angles)
    elseif initialTechPoint ~= nil then
    
        // Compute random spawn location
        local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
		local spawnOrigin = nil
		
		// Try it 10 times here
		for index = 1, 10 do
			spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, initialTechPoint:GetOrigin(), kSpawnMinDistance, 25, EntityFilterAll())
			if spawnOrigin ~= nil then
				break
			end
		end
		
        if spawnOrigin ~= nil then
        
            // Orient player towards tech point
            local lookAtPoint = initialTechPoint:GetOrigin() + Vector(0, 5, 0)
            local toTechPoint = GetNormalizedVector(lookAtPoint - spawnOrigin)
            success = Team.RespawnPlayer(self, player, spawnOrigin, Angles(GetPitchFromVector(toTechPoint), GetYawFromVector(toTechPoint), 0))
            
        else
        
			player:SendDirectMessage("No room to spawn. You should spawn in the next wave instead!")
            Print("PlayingTeam:RespawnPlayer: Couldn't compute random spawn for player. Will retry at next wave...\n")
			// Escape the player's name here... names like Sandwich% cause a crash to appear here!
			local escapedPlayerName = string.gsub(player:GetName(), "%%", "")
			Print("PlayingTeam:RespawnPlayer: Name: " .. escapedPlayerName .. " Class: " .. player:GetClassName())
            
        end
        
    else
        Print("PlayingTeam:RespawnPlayer(): No initial tech point.")
    end
    
    return success
    
end

if (not HotReload) then
	CombatPlayingTeam:OnLoad()
end
