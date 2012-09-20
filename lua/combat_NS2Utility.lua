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
    self:ReplaceClassFunction("Spit", "ProcessHit", "ProcessHit_Hook") 
end

// for focus to make more dmg
function CombatNS2Utility:AttackMeleeCapsule_Hook(weapon, player, damage, range, optionalCoords, altMode)

    // Enable tracing on this capsule check, last argument.
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true)
    
    if didHit then
        // check if player has focus then do more dmg, only on some weapons, so check weapon
        if player:GotFocus() then
            damage = damage * kCombatFocusDamageScalar
        end
        
        weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
        
    end
    
    return didHit, target, endPoint, surface
    
end

// only possible to replace it, hooking the mixin or the function is not possible

function CombatNS2Utility:ProcessHit_Hook(self, targetHit, surface, normal)

    if normal:GetLength() == 0 then
        DestroyEntity(self)
        
    elseif not targetHit then
    
        self.onSurface = true
        
        local coords = Coords.GetIdentity()
        coords.origin = self:GetOrigin()
        coords.yAxis = normal
        coords.zAxis = GetNormalizedVector(self.desiredVelocity)
        coords.xAxis = coords.zAxis:CrossProduct(coords.yAxis)
        coords.zAxis = coords.yAxis:CrossProduct(coords.xAxis)
        
        self:SetCoords(coords)

    // Don't hit owner - shooter
    elseif self:GetOwner() ~= targetHit then
    
        self:TriggerEffects("spit_hit", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) } )
    
        if self:GetOwner():GotFocus() then
            self:DoDamage(Spit.kDamage * kCombatFocusDamageScalar, targetHit, self:GetOrigin(), nil, surface)
        else
            self:DoDamage(Spit.kDamage, targetHit, self:GetOrigin(), nil, surface)
        end
        
        if targetHit and targetHit:isa("Marine") then
        
            local direction = self:GetOrigin() - targetHit:GetEyePos()
            direction:Normalize()
            targetHit:OnSpitHit(direction)
            
        end
        
        DestroyEntity(self)
        
    end    
    
end

if (not HotReload) then
	CombatNS2Utility:OnLoad()
end