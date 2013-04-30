//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Weapon.lua


if(not CombatWeapon) then
    CombatWeapon = {}
end

ClassHooker:Mixin("CombatWeapon")
    
function CombatWeapon:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Weapon", "lua/Weapons/Weapon.lua") 
    self:PostHookClassFunction("Weapon", "OnPrimaryAttack", "OnPrimaryAttack_Hook") 
	self:PostHookClassFunction("Weapon", "OnSecondaryAttack", "OnSecondaryAttack_Hook") 
    
end

function CombatWeapon:OnPrimaryAttack_Hook(self, player)

	if (player:isa("Marine") or player:isa("Exo")) then
		player:CheckCombatData()
		player:CheckCatalyst()
	end

end


function CombatWeapon:OnSecondaryAttack_Hook(self, player)

	if (player:isa("Marine") or player:isa("Exo")) then
		player:CheckCombatData()
		player:CheckCatalyst()
	end

end


CombatWeapon:OnLoad()