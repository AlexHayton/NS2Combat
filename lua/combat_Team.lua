//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_Team.lua

if(not CombatTeam) then
  CombatTeam = {}
end

local HotReload = ClassHooker:Mixin("CombatTeam")

function CombatTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("Team", "lua/Team.lua") 
    self:ReplaceClassFunction("Team", "PutPlayerInRespawnQueue", "PutPlayerInRespawnQueue_Hook")
	
end

// ToDo: Dont spawn directly, spawn after a short period of time
// AH: Implement some kind of spawn queue and timer here...
function CombatTeam:PutPlayerInRespawnQueue_Hook(self, player, time)
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
		
		// Make a nice effect when you spawn.
		if newPlayer:isa("Marine") then
			newPlayer:TriggerEffects("infantry_portal_spawn")
		elseif newPlayer:isa("Alien") then
			newPlayer:TriggerEffects("egg_death")
		end
		
        return success
end

if(HotReload) then
    CombatTeam:OnLoad()
end