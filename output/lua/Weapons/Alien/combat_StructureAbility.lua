//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_StructureAbility.lua

local HotReload = CombatStructureAbility
if(not HotReload) then
  CombatStructureAbility = {}
  ClassHooker:Mixin("CombatStructureAbility")
end

function CombatStructureAbility:OnLoad()

    ClassHooker:SetClassCreatedIn("StructureAbility", "lua/Weapons/Alien/StructureAbility.lua") 
	if (Client) then
		_addHookToTable(self:ReplaceClassFunction("StructureAbility", "IsAllowed", "IsAllowed_Hook"))
	else
		self:ReplaceClassFunction("StructureAbility", "IsAllowed", "IsAllowed_Hook")
	end
	
end

function CombatStructureAbility:IsAllowed_Hook(self, player)

	local dropStructureId = self:GetDropStructureId()
	if dropStructureId == kTechId.Web or dropStructureId == kTechId.BabblerEgg then
		return GetIsTechUnlocked(player, dropStructureId)
	end

    return true
	
end

if (not HotReload) then
	CombatStructureAbility:OnLoad()
end
