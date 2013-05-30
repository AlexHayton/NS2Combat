//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

kBaseNpcDamage = 0.1
kNpcDamageDifficultyIncrease = 0.035

// if its easy you only take half damage
local originalGetDamageByType = GetDamageByType
function GetDamageByType(target, attacker, doer, damage, damageType)
    
	// Store away whether the attacker was an NPC. This fixes bugs with e.g. lerk poison bite, grenades etc after the owner has died.
    if (attacker and attacker.isaNpc) or (doer and doer.damageFromNpc) then
		if doer and not doer.damageFromNpc then
			doer.damageFromNpc = true
		end
		
		if attacker and attacker.difficulty then
			damage = damage * (kBaseNpcDamage + (kNpcDamageDifficultyIncrease * attacker.difficulty))
		else
			damage = damage * 0.1
		end
    end
    return originalGetDamageByType(target, attacker, doer, damage, damageType)
end