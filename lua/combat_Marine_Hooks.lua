//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Marine.lua

local HotReload = CombatMarine
if(not HotReload) then
  CombatMarine = {}
  ClassHooker:Mixin("CombatMarine")
end
    
function CombatMarine:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Marine", "lua/Marine.lua") 
	self:RawHookClassFunction("Marine", "OnKill", "MarineOnKill_Hook") 
    self:ReplaceClassFunction("Marine", "Drop", "Drop_Hook")
	self:ReplaceClassFunction("Marine", "GiveJetpack", "GiveJetpack_Hook")
	self:PostHookClassFunction("Marine", "OnTakeDamage", "OnTakeDamage_Hook")
    
end

//___________________
// Hooks Marine
//___________________

// Dont' drop Weapons after getting killed, but destroy them!
function CombatMarine:MarineOnKill_Hook(self, damage, attacker, doer, point, direction)

    self:DestroyWeapons()
	
end

// Weapons can't be dropped anymore
function CombatMarine:Drop_Hook(self, weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)

	// just do nothing

end

// Return the new marine so that we can update the player that is referenced.
function CombatMarine:GiveJetpack_Hook(self)

    local activeWeapon = self:GetActiveWeapon()
    local activeWeaponMapName = nil
    local health = self:GetHealth()
    
    if activeWeapon ~= nil then
        activeWeaponMapName = activeWeapon:GetMapName()
    end
    
    local jetpackMarine = self:Replace(JetpackMarine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
    
    jetpackMarine:SetActiveWeapon(activeWeaponMapName)
    jetpackMarine:SetHealth(health)
    
	return jetpackMarine
	
end

function CombatMarine:OnTakeDamage_Hook(self, damage, attacker, doer, point)

	// Activate the Catalyst Pack.
	self:CheckCombatData()
	self:CheckCatalyst()

end

if (not HotReload) then
	CombatMarine:OnLoad()
end