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
    self:ReplaceClassFunction("PlayingTeam", "SpawnResourceTower", "SpawnResourceTower_Hook")
    self:ReplaceClassFunction("PlayingTeam", "GetHasTeamLost", "GetHasTeamLost_Hook")
    
    ClassHooker:SetClassCreatedIn("Team", "lua/Team.lua") 
    self:ReplaceClassFunction("Team", "PutPlayerInRespawnQueue", "PutPlayerInRespawnQueue_Hook")
    
    ClassHooker:SetClassCreatedIn("PointGiverMixin", "lua/PointGiverMixin.lua")
    self:PostHookClassFunction("PointGiverMixin", "OnKill", "OnKill_Hook")
    
    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua")
    self:PostHookClassFunction("NS2Gamerules", "JoinTeam", "JoinTeam_Hook")

   
    
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
    local commandStructure = self:SpawnCommandStructure(techPoint)
    
    if commandStructure:isa("Hive") then
        commandStructure:SetFirstLogin()
    end
	
	// Set the command station to be occupied.
	if commandStructure:isa("CommandStation") then
		commandStructure.occupied = true
		//commandStructure:UpdateCommanderLogin(true)
	end
    
end

function CombatPlayingTeam:SpawnResourceTower_Hook(self, techPoint)
    // No RTS!!
end

//___________________
// Hooks Team
//___________________

// ToDo: Dont spawn directly, spawn after a short period of time

function CombatPlayingTeam:PutPlayerInRespawnQueue_Hook(self, player, time)
//Spawn, even if there is no IP
    player:GetTeam():RemovePlayerFromRespawnQueue(player)
        player.isRespawning = true
      SendPlayersMessage({ player }, kTeamMessageTypes.Spawning)

           if Server then
                
                if player.SetSpectatorMode then
                    player:SetSpectatorMode(Spectator.kSpectatorMode.Following)

                end         
                

            end

        if player.combatTable and player.combatTable.giveClassAfterRespawn then
            local newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil, player.combatTable.giveClassAfterRespawn)
        else
            local newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil)        
        end
        return success
end


function CombatPlayingTeam:OnKill_Hook(self, damage, attacker, doer, point, direction)

    // Give XP to killer.
    local pointOwner = attacker
    
    // If the pointOwner is not a player, award it's points to it's owner.
    if pointOwner ~= nil and not HasMixin(pointOwner, "Scoring") and pointOwner.GetOwner then
        pointOwner = pointOwner:GetOwner()
    end    
        
    // Give Xp for Players
   if pointOwner then
        if self:isa("Player") then
                if self.combatTable then
                    pointOwner:AddXp(XpList[self.combatTable.lvl][4])
                else
                    // if enemy dont got a combatTable, get standard Value for Lvl 1
                    pointOwner:AddXp(XpList[1][4])
                end
        else    
		
			// Give XP for killing structures
            pointOwner:AddXp(XpValues[self:GetClassName()])
        end
    end    

end

//___________________
// Hooks NS2Gamerules
//___________________

// Free the lvl when changing Teams
function  CombatPlayingTeam:JoinTeam_Hook(self, player, newTeamNumber, force)

    if player.combatTable then
        if player.combatTable.techtree[1] then
             // give the Lvl back
            player.combatTable.lvlfree = player.combatTable.lvlfree +  player.combatTable.lvl - 1
            // clear the techtree
            player.combatTable.techtree = {}
			player.resources = 999
        end
    end

end


if(hotreload) then
    CombatPlayingTeam:OnLoad()
end