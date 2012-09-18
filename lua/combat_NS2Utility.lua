//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_NS2Utlility.lua

local HotReload = CombatNS2Utility
if(not HotReload) then
  CombatNS2Utility = {}
  ClassHooker:Mixin("CombatNS2Utility")
end
    
function CombatNS2Utility:OnLoad()
    self:ReplaceFunction("AttackMeleeCapsule", "AttackMeleeCapsule_Hook")
end

// for focus to make more dmg
function CombatNS2Utility:AttackMeleeCapsule_Hook(weapon, player, damage, range, optionalCoords, altMode)

    // Enable tracing on this capsule check, last argument.
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true)
    
    if didHit then
        // check if player has focus then do more dmg, only on some weapons, so check weapon
        if player:GotFocus() then
            damage = damage * kCombatFocusScalar
        end
        
        weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
        
    end
    
    return didHit, target, endPoint, surface
    
end

if (not HotReload) then
	CombatNS2Utility:OnLoad()
end