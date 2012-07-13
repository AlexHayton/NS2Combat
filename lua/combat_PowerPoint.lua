//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_PowerPoint.lua

local HotReload = CombatPowerPoint
if(not HotReload) then
  CombatPowerPoint = {}
end

ClassHooker:Mixin("CombatPowerPoint")

function CombatPowerPoint:OnLoad()
    ClassHooker:SetClassCreatedIn("PowerPoint", "lua/PowerPoint.lua") 
    self:ReplaceClassFunction("PowerPoint", "GetCanTakeDamageOverride", "PowerPointGetCanTakeDamageOverride_Hook")
end

function CombatPowerPoint:PowerPointGetCanTakeDamageOverride_Hook(self)
    return false
end

CombatPowerPoint:OnLoad()