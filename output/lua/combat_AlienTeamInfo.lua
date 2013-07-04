//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_AlienTeam.lua

local HotReload = CombatAlienTeamInfo
if(not HotReload) then
  CombatAlienTeamInfo = {}
  ClassHooker:Mixin("CombatAlienTeamInfo")
end

function CombatAlienTeamInfo:OnLoad()

    ClassHooker:SetClassCreatedIn("AlienTeamInfo", "lua/AlienTeamInfo.lua") 
	self:PostHookClassFunction("AlienTeamInfo", "OnUpdate", "OnUpdate_Hook")
	
end

function CombatAlienTeamInfo:OnUpdate_Hook(self, deltaTime)

    self.veilLevel = 3
	self.spurLevel = 3
	self.shellLevel = 3
    
end

if (not HotReload) then
	CombatAlienTeamInfo:OnLoad()
end