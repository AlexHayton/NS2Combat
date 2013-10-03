//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Team.lua

local HotReload = CombatTeam
if(not HotReload) then
  CombatTeam = {}
  ClassHooker:Mixin("CombatTeam")
end

function CombatTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("Team", "lua/Team.lua") 
	self:ReplaceClassFunction("Team", "GetNumPlayersInQueue", "GetNumPlayersInQueue_Hook")
	self:ReplaceClassFunction("Team", "RemovePlayer", "RemovePlayer_Hook")
	
end

// A cheap trick to stop waves from spawning on the Alien side.
// This is a nasty way of doing it but it works for now!
function CombatTeam:GetNumPlayersInQueue_Hook(self)
    return 0
end

function CombatTeam:RemovePlayer_Hook(self, player)

    assert(player)
    self:RemovePlayerFromRespawnQueue(player)   
	
end

if (not HotReload) then
	CombatTeam:OnLoad()
end
