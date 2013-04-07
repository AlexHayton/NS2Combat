//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcMarineMixin = CreateMixin( NpcMarineMixin )
NpcMarineMixin.type = "NpcMarine"

NpcMarineMixin.kAmmoUpdateRate = 4
NpcMarineMixin.lowHealthFactor = 0.2 // if health is 20% we need to do something
NpcMarineMixin.armorySearchRange = 20 // armory will be searched in this range

NpcMarineMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcMarineMixin.expectedCallbacks =
{
}


NpcMarineMixin.networkVars =  
{
}


function NpcMarineMixin:__initmixin()   
end


function NpcMarineMixin:AiSpecialLogic()
    // just sprint all the time
    //self:PressButton(Move.MovementModifier)
end


function NpcMarineMixin:CheckImportantEvents()
    // if health is low and we have no order, got to an armory if near
    local healthFactor = self:GetHealth() / self:GetMaxHealth()
    local order = self:GetCurrentOrder() 
    local origin = self:GetOrigin()
    
    if healthFactor <= NpcMarineMixin.lowHealthFactor or self:GetWeaponOutOfAmmo(1) or self:GetWeaponOutOfAmmo(2) then
        // only go healing when no order or no attack order and armory will help us 
        if not order or order:GetType() ~= kTechId.Attack then
        
            local armorys = GetEntitiesWithinRange("Armory",  origin , NpcMarineMixin.armorySearchRange )
            if armorys then
                // search nearest armory
                local nearestArmory = nil
                local distance = nil

                for i, armory in ipairs(armorys) do
                    if armory:GetTeamNumber() == self:GetTeamNumber() then
                        if not nearestArmory then
                            nearestArmory = armory
                            distance = origin:GetDistanceTo(armory:GetOrigin())
                        else
                            if origin:GetDistanceTo(armory:GetOrigin()) < distance then
                                nearestArmory = armory
                                distance = origin:GetDistanceTo(armory:GetOrigin())  
                            end
                        end
                    end
                end
                
                if nearestArmory then
                    self:GiveOrder(kTechId.Move , nearestArmory:GetId(), nearestArmory:GetOrigin())
                end   
                
            end
         
        end
    end

end

function NpcMarineMixin:CheckCrouch(targetPosition)

    local activeWeapon = self:GetActiveWeapon()
    // only crouch when using an axe
    if activeWeapon and activeWeapon:isa("Axe") then
        // crouch if we need to
        local yRange = targetPosition.y - self:GetEyePos().y
        local target = false
        
        if self.target then
            target =  Shared.GetEntity(self.target)
        end
        
        if (self:GetCanCrouch() and yRange > self:GetCrouchShrinkAmount()) or (target and target:isa("Egg")) then
            self:PressButton(Move.Crouch)
        end
    end
    
end

function NpcMarineMixin:UpdateOrderLogic()

    local order = self:GetCurrentOrder()             
    local activeWeapon = self:GetActiveWeapon()

    if order ~= nil then
        if (order:GetType() == kTechId.Attack) then
        
            local target = Shared.GetEntity(order:GetParam())
            if target then
            
                if activeWeapon then
                    outOfAmmo = (activeWeapon:isa("ClipWeapon") and (activeWeapon:GetAmmo() == 0))  
          
                    // Some bots switch to axe to take down structures
                    if (GetReceivesStructuralDamage(target) and self.prefersAxe and not activeWeapon:isa("Axe")) or 
                            (self:GetWeaponOutOfAmmo(kPrimaryWeaponSlot) and self:GetWeaponOutOfAmmo(kSecondaryWeaponSlot)) then
                        self:PressButton(Move.Weapon3)
                    elseif ((target:isa("Player") or not GetReceivesStructuralDamage(target)) and not activeWeapon:isa("Rifle"))
                            and not self:GetWeaponOutOfAmmo(kPrimaryWeaponSlot) then
                        self:PressButton(Move.Weapon1)
                    // If we're out of ammo in our primary weapon, switch to next weapon (pistol or axe)
                    elseif outOfAmmo then
                        self:PressButton(Move.NextWeapon)                   
                    end
                    
                end                

            end
            
        elseif (order:GetType() == kTechId.Build or order:GetType() == kTechId.Construct) then
            // if we're near the build, look if we can build it
            if order:GetLocation() and (self:GetOrigin() - order:GetLocation()):GetLengthXZ() <= kPlayerUseRange then
                local targetEnt = Shared.GetEntity(order:GetParam())
                local ent = self:PerformUseTrace()            
                if ent and ent == targetEnt then
                    if not ent:GetIsBuilt() then
                        self:PressButton(Move.Use)
                        self.inTargetRange = true
                        self.toClose = false
                    else
                        self:DeleteCurrentOrder()
                    end
                end
            end
            // if not, do nothing, we will walk there
        end

    else
        if not activeWeapon:isa("Rifle") then
            // don't check this to often
            if not self.timeLastAmmoUpdate or ((Shared.GetTime() - self.timeLastAmmoUpdate) > NpcMarineMixin.kAmmoUpdateRate) then
                if not self:GetWeaponOutOfAmmo(kPrimaryWeaponSlot) then
                    self:PressButton(Move.Weapon1)
                end
                self.timeLastAmmoUpdate = Shared.GetTime()
            end
        end
        
    end    
   
end

function NpcMarineMixin:AttackOverride(activeWeapon) 

    if not activeWeapon:isa("Pistol") or not self.pistolFired then
        self:PressButton(Move.PrimaryAttack)
        self.pistolFired = true
    else
        self.pistolFired = false
    end             


end


function NpcMarineMixin:GetWeaponOutOfAmmo(weaponSlot)
    weaponSlot = weaponSlot or kPrimaryWeaponSlot
          
    for i = 0, self:GetNumChildren() - 1 do
    
        local child = self:GetChildAtIndex(i)
        if child:isa("ClipWeapon") and child:GetHUDSlot() == weaponSlot then
            return child:GetAmmo() == 0
        end
        
    end
    
    return false
    
end




