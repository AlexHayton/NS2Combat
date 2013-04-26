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
    self:PostHookClassFunction("PowerPoint", "OnCreate", "OnCreate_Hook")
    self:PostHookClassFunction("PowerPoint", "OnKill", "OnKill_Hook")
end

function CombatPowerPoint:PowerPointGetCanTakeDamageOverride_Hook(self)
    return kCombatPowerPointsTakeDamage
end

function CombatPowerPoint:OnCreate_Hook(self)
    self.combatCanTakeDamage = kCombatPowerPointsTakeDamage
end

local function AutoRepair(self)
	Shared.Message("Tried to auto repair a power point!")
	self:SetConstructionComplete()
	return false
end

function CombatPowerPoint:OnKill_Hook(self)
	self:AddTimedCallback(AutoRepair, kCombatPowerPointAutoRepairTime)
end

if (not HotReload) then
	CombatPowerPoint:OnLoad()
end
