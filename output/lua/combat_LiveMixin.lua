//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_LiveMixin.lua
local OriginalTakeDamage = LiveMixin.TakeDamage

/**
 * Returns true if the damage has killed the entity.
 */
function LiveMixin:TakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType)

	local entityKilled = false
	local damageDone = 0
		
	// Devoured players should only take damage from the Onos!
	if (not self:isa("DevouredPlayer")) or (self:isa("DevouredPlayer") and attacker:isa("Onos")) then
		entityKilled, damageDone = OriginalTakeDamage(self, damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType)
	end
	
	return entityKilled, damageDone
    
end