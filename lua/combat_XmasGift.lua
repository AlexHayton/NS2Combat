// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AmmoPack.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/DropPack.lua")
Script.Load("lua/PickupableMixin.lua")
Script.Load("lua/combat_ExperienceLevels.lua")

class 'CombatXmasGift' (DropPack)

CombatXmasGift.kMapName = "combat_xmas_gift"

CombatXmasGift.kModelName = PrecacheAsset("seasonal/holiday2012/models/gift_box_01.model")
CombatXmasGift.kPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_ammo")

CombatXmasGift.Xp = 100

function CombatXmasGift:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(CombatXmasGift.kModelName)
    
    InitMixin(self, PickupableMixin, { kRecipientType = "Player" })
    
    if Server then
        self:_CheckForPickup()
    end

end

function CombatXmasGift:OnTouch(recipient)

    // give xp
    StartSoundEffectAtOrigin(AmmoPack.kPickupSound, recipient:GetOrigin())
    recipient:AddXp(CombatXmasGift.Xp * (math.random(1, 5) / 5))
    combatHalloween_SendPickedUpMessage(recipient:GetName())
    
end

function CombatXmasGift:GetIsValidRecipient(recipient)
    if not Client then
        //return ( recipient:isa("Marine") or recipient:isa("Alien") ) and (recipient:GetXp() < maxXp)
        return ( recipient:isa("Marine") or recipient:isa("Alien") ) and recipient:GetXp() < maxXp
    else
        // return false to avoid the GUIPicups (will cause an error)
        return false
    end
end

// that the xmas gift doesnt appear anymore
function CombatXmasGift:GetIsPermanent()
    return true
end

function CombatXmasGift:GetPlayInstantRagdoll()
    return true
end

Shared.LinkClassToMap("CombatXmasGift", CombatXmasGift.kMapName)
