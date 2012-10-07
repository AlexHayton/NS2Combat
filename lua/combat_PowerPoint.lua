//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_PowerPoint.lua

local HotReload = CombatPowerPoint
if(not HotReload) then
  CombatPowerPoint = {}
  ClassHooker:Mixin("CombatPowerPoint")
end

function CombatPowerPoint:OnLoad()
    ClassHooker:SetClassCreatedIn("PowerPoint", "lua/PowerPoint.lua") 
    self:ReplaceClassFunction("PowerPoint", "GetCanTakeDamageOverride", "PowerPointGetCanTakeDamageOverride_Hook")
end

function CombatPowerPoint:PowerPointGetCanTakeDamageOverride_Hook(self)
    return false
end

if (not HotReload) then
	CombatPowerPoint:OnLoad()
end
