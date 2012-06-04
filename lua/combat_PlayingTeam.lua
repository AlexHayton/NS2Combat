//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
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
    
    ClassHooker:SetClassCreatedIn("MarineTeam", "lua/MarineTeam.lua") 
    self:ReplaceClassFunction("MarineTeam", "SpawnInitialStructures", "MarineTeamSpawnInitialStructures_Hook")
    self:ReplaceClassFunction("MarineTeam", "SpawnInfantryPortals", "MaineTeamSpawnInfantryPortals_Hook")
    self:ReplaceClassFunction("MarineTeam", "Update", "MarineTeamUpdate_Hook")
    
    ClassHooker:SetClassCreatedIn("Team", "lua/Team.lua") 
    self:ReplaceClassFunction("Team", "PutPlayerInRespawnQueue", "PutPlayerInRespawnQueue_Hook")
    
    ClassHooker:SetClassCreatedIn("PointGiverMixin", "lua/PointGiverMixin.lua")
    self:PostHookClassFunction("PointGiverMixin", "OnKill", "OnKill_Hook")
    
    ClassHooker:SetClassCreatedIn("Hive", "lua/Hive.lua")
    self:ReplaceClassFunction("Hive", "GenerateEggSpawns", "GenerateEggSpawns_Hook")
    self:ReplaceClassFunction("Hive", "SpawnEgg", "SpawnEgg_Hook")

   
    
end

//___________________
// Hooks Playing Team
//___________________

function CombatPlayingTeam:GetHasTeamLost_Hook(handle, self)
    // Don't bother with the original - we just set our own logic here.
    
	if(GetGamerules():GetGameStarted() and not Shared.GetCheatsEnabled()) then
    
        // Team can't respawn or last Command Station or Hive destroyed
        local abilityToRespawn = self:GetHasAbilityToRespawn()
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
    
end

function CombatPlayingTeam:SpawnResourceTower_Hook(self, techPoint)
    // No RTS!!
end


//___________________
// Hooks MarineTeam
//___________________

function CombatPlayingTeam:MarineTeamSpawnInitialStructures_Hook(self, techPoint)
    PlayingTeam.SpawnInitialStructures(self, techPoint)
    // ToDo: Spaw Armory, too
end

function CombatPlayingTeam:MaineTeamSpawnInfantryPortals_Hook(self, techPoint)
    // No IPS
end

// Don't Check for IPS
function CombatPlayingTeam:MarineTeamUpdate_Hook(self, timePassed)

    PlayingTeam.Update(self, timePassed)
    
    self:UpdateSquads(timePassed)
    
    // Update distress beacon mask
    self:UpdateGameMasks(timePassed)
   
    if GetGamerules():GetGameStarted() then
      
    end
    
end


//___________________
// Hooks Team
//___________________

// ToDo: Dont spawn directly, spawn after a short period of time

function CombatPlayingTeam:PutPlayerInRespawnQueue_Hook(self, player, time)
//Spawn, even if there is no IP
    player:GetTeam():RemovePlayerFromRespawnQueue(player)
      SendPlayersMessage({ player }, kTeamMessageTypes.Spawning)
            
            if Server then
                
                if player.SetSpectatorMode then
                    player:SetSpectatorMode(Spectator.kSpectatorMode.Following)
                end         
                

            end
    
        local newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil)        
        
        return success
end


function CombatPlayingTeam:OnKill_Hook(self, damage, attacker, doer, point, direction)

    // Give XP to killer.
    local pointOwner = attacker
    
    // If the pointOwner is not a player, award it's points to it's owner.
    if pointOwner ~= nil and not HasMixin(pointOwner, "Scoring") and pointOwner.GetOwner then
        pointOwner = pointOwner:GetOwner()
    end    
        

   if (pointOwner and self:isa("Player")) then
            if (XpList[self.combatTable]) then
                pointOwner:AddXp(XpList[self.combatTable.lvl][4])
            else
                // if enemy dont got a combatTable, get standard Value for Lvl 1
                pointOwner:AddXp(XpList[1][4])
            end
    end

end


//___________________
// Hooks Hive
//___________________


// No eggs will be spawned
function CombatPlayingTeam:GenerateEggSpawns_Hook(self)
// Do nothing
end

 function CombatPlayingTeam:SpawnEgg_Hook(self)
 // Do nithing
 end



if(hotreload) then
    CombatPlayingTeam:OnLoad()
end