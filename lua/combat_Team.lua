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
	self:ReplaceClassFunction("Team", "GetNumPlayersInQueue", "GetNumPlayersInQueue_Hook")
	
end

// AH: Old spawn code here has been moved to PlayingTeam now that we have a spawn queue implemented.

// A cheap trick to stop waves from spawning on the Alien side.
// This is a nasty way of doing it but it works for now!
function CombatTeam:GetNumPlayersInQueue_Hook(self)
    return 0
end

if(HotReload) then
    CombatTeam:OnLoad()
end