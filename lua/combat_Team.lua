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

    local success = false
    player:GetTeam():RemovePlayerFromRespawnQueue(player)
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
    
    if not success then
        // if it failes, move him back to the queue
        player:GetTeam():PutPlayerInRespawnQueue(player, time)           
    else 
    
        // Make a nice effect when you spawn.
        if newPlayer:isa("Marine") then
            newPlayer:TriggerEffects("infantry_portal_spawn")
        // Aliens hatch due the CoEvolve function
        end
    end

    return success
    
end

if(HotReload) then
    CombatTeam:OnLoad()
end