//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Balance.lua

if(not CombatBalance) then
  CombatBalance = {}
end


local HotReload = ClassHooker:Mixin("CombatBalance")

function CombatBalance:OnLoad()
    ClassHooker:SetClassCreatedIn("PowerPoint", "lua/PowerPoint.lua") 
    self:ReplaceClassFunction("PowerPoint", "GetCanTakeDamageOverride", "PowerPointGetCanTakeDamageOverride_Hook")
end


function CombatBalance:PowerPointGetCanTakeDamageOverride_Hook(self)
    return false
end


if(hotreload) then
    CombatBalance:OnLoad()
end