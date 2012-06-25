//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_PlayingTeam.lua


if(not CombatPlayingTeam) then
  CombatPlayingTeam = {}
end


local HotReload = ClassHooker:Mixin("CombatPlayingTeam")
    
function CombatPlayingTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("PlayingTeam", "lua/PlayingTeam.lua") 
    self:ReplaceClassFunction("PlayingTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
    self:ReplaceClassFunction("PlayingTeam", "GetHasTeamLost", "GetHasTeamLost_Hook")
	self:ReplaceClassFunction("PlayingTeam", "UpdateTechTree", "UpdateTechTree_Hook")
	self:ReplaceClassFunction("PlayingTeam", "Update", "Update_Hook")
    
end

//___________________
// Hooks Playing Team
//___________________

function CombatPlayingTeam:GetHasTeamLost_Hook(self, handle)
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

function CombatPlayingTeam:UpdateTechTree_Hook(self)

    PROFILE("PlayingTeam:UpdateTechTree")
    
    // Compute tech tree availability only so often because it's very slooow
    if self.techTree ~= nil then
		if (self.timeOfLastTechTreeUpdate == nil or Shared.GetTime() > self.timeOfLastTechTreeUpdate + PlayingTeam.kTechTreeUpdateTime) then

			local techIds = {}
			
			for index, structure in ipairs(GetEntitiesForTeam("Structure", self:GetTeamNumber())) do
			
				if structure:GetIsBuilt() and structure:GetIsActive(true) then
				
					table.insert(techIds, structure:GetTechId())
					
				end
				
			end
			
			self.techTree:Update(techIds)

			// Send tech tree base line to players that just switched teams or joined the game        
			// Also refresh and update existing players' tech trees.
			local players = self:GetPlayers()
			
			for index, player in ipairs(players) do

				player:UpdateTechTree()
			
				if player:GetSendTechTreeBase() then
				
					if player:GetTechTree() ~= nil then            
						player:GetTechTree():SendTechTreeBase(player)
					end
					
					player:ClearSendTechTreeBase()
					
				end
				
				// Send research, availability, etc. tech node updates to players   
				if player:GetTechTree() ~= nil then            
					player:GetTechTree():SendTechTreeUpdates({ player })
				end
				
			end
			
			self.timeOfLastTechTreeUpdate = Shared.GetTime()
			
			self:OnTechTreeUpdated()
			
		end
	end
    
end

// Respawn timers.
function CombatPlayingTeam:Update_Hook(self, timePassed)

	if self.timeSinceLastSpawn == nil then 
		CombatPlayingTeam:ResetSpawnTimer(self)
	end
	
	// Increment the spawn timer
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + timePassed
	
	// Spawn all players in the queue once every 10 seconds or so.
	if (#self.respawnQueue > 0) then
		
		// Are we ready to spawn? This is based on the time since the last spawn...
		local timeToSpawn = (self.timeSinceLastSpawn >= kCombatRespawnTimer)
		
		if timeToSpawn then
			// Reset the spawn timer.
			CombatPlayingTeam:ResetSpawnTimer(self)
			
			// Loop through the respawn queue and spawn dead players.
			// Also handle the case where there are too many players to spawn all of them - do it on a FIFO basis.
			local lastPlayer = nil
			local thisPlayer = self:GetOldestQueuedPlayer()
			
			while (lastPlayer == thisPlayer) or (thisPlayer ~= nil) do
				CombatPlayingTeam:SpawnPlayer(thisPlayer)
				lastPlayer = thisPlayer
				thisPlayer = self:GetOldestQueuedPlayer()
			end
		else
			// Send any 'waiting to respawn' messages (normally these only go to AlienSpectators)
			for index, player in pairs(self:GetPlayers()) do				
				if not player.waitingToSpawnMessageSent then
					SendPlayersMessage({ player }, kTeamMessageTypes.SpawningWait)
					player.waitingToSpawnMessageSent = true

					// TODO: Update the GUI so that marines can get the 'ready to spawn in ... ' message too.
					// After that is done, remove the AlienSpectator check here.
					if (player:isa("AlienSpectator")) then
						player:SetWaveSpawnEndTime(nextSpawnTime)
					end
				end
			end
		end
		
	end
	
end

function CombatPlayingTeam:ResetSpawnTimer(self)

	// Reset the spawn timer
	self.timeSinceLastSpawn = 0
	self.nextSpawnTime = Shared.GetTime() + kCombatRespawnTimer
			
end

function CombatPlayingTeam:SpawnPlayer(player)

	player.isRespawning = true
	SendPlayersMessage({ player }, kTeamMessageTypes.Spawning)

    if Server then
        
        if player.SetSpectatorMode then
            player:SetSpectatorMode(Spectator.kSpectatorMode.Following)
        end        
 
    end

    if player.combatTable and player.combatTable.giveClassAfterRespawn then
        success, newPlayer  = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil, player.combatTable.giveClassAfterRespawn)
    else
        // let Aliens spawn in an Egg (that they get theire ups back
        if player:GetTeamNumber() == kAlienTeamType then            

            success, newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil)
            if success then
                newPlayer:DropToFloor()
                newPlayer:CoEvolve()
            end 
            
        else
            // if it's a Marine, spawn him normally
            success, newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil)        
        end
		
    end
    
    if success then
        // Make a nice effect when you spawn.
		// Aliens hatch due the CoEvolve function
        if newPlayer:isa("Marine") then
            newPlayer:TriggerEffects("infantry_portal_spawn")
        end
		newPlayer:GetTeam():RemovePlayerFromRespawnQueue(newPlayer)
    end

    return success

end

if(hotreload) then
    CombatPlayingTeam:OnLoad()
end