//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/Weapons/Weapon.lua")

class 'PortalGun' (Weapon)

PortalGun.kMapName = "portalgun"

PortalGun.kModelName = PrecacheAsset("models/marine/rifle/rifle.model")
PortalGun.kViewModelName = PrecacheAsset("models/marine/rifle/rifle_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/rifle/rifle_view.animation_graph")

PortalGun.kRange = 150
PortalGun.attackInverval = 0.5
local kSpread = Math.Radians(0)

local networkVars =
{
    sprintAllowed = "boolean",
    blockingPrimary = "boolean",
    timeAttackStarted = "time",
    portal1Id = "entityid",
    portal2Id = "entityid",
}

function PortalGun:OnCreate()

    Weapon.OnCreate(self)
    
    self.sprintAllowed = true
    self.primaryAttacking = false
    self.secondaryAttacking = false
    self.blockingPrimary = false
    self.timeAttackStarted = 0
    portal1Id = nil
    portal2Id = nil

end

function PortalGun:OnInitialized()

    Weapon.OnInitialized(self)
    
    self:SetModel(PortalGun.kModelName)

end

function PortalGun:OnDestroy()

    Weapon.OnDestroy(self)
    
    if Server then
        if self.portal1Id then
            local destroyPortal = Shared.GetEntity(self.portal1Id)
            if destroyPortal then
                DestroyEntity(destroyPortal)         
            end
        end
        
        if self.portal2Id then
            local destroyPortal2 = Shared.GetEntity(self.portal2Id)
            if destroyPortal2 then
                DestroyEntity(destroyPortal2)         
            end
        end
    end

end

function PortalGun:GetViewModelName()
    return PortalGun.kViewModelName
end

function PortalGun:GetAnimationGraphName()
    return kAnimationGraph
end

function PortalGun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function PortalGun:GetRange()
    return kRange
end

// Max degrees that weapon can swing left or right
function PortalGun:GetSwingAmount()
    return 10
end

function PortalGun:GetShowDamageIndicator()
    return true
end

function PortalGun:GetSprintAllowed()
    return self.sprintAllowed
end

function PortalGun:GetDeathIconIndex()
    return kDeathMessageIcon.Axe
end

function PortalGun:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
end

function PortalGun:OnHolster(player)

    Weapon.OnHolster(self, player)
    
    self.sprintAllowed = true
    self.primaryAttacking = false
    
end

function PortalGun:OnPrimaryAttack(player)

    if Shared.GetTime() >= self.timeAttackStarted + PortalGun.attackInverval then
        self:FirePortal(player, 1)
        self.primaryAttacking = true
        self.secondaryAttacking = false
        self.timeAttackStarted = Shared.GetTime()
    end 
    
    //if self:GetPrimaryIsBlocking() then
      //  self.blockingPrimary = true
    //end

end

function PortalGun:OnSecondaryAttack(player)

    if Shared.GetTime() >= self.timeAttackStarted + PortalGun.attackInverval then
        self:FirePortal(player, 2)
        self.primaryAttacking = false
        self.secondaryAttacking = true
        self.timeAttackStarted = Shared.GetTime()
    end
        
end

function PortalGun:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
end

function PortalGun:OnSecondaryAttackEnd(player)

    self.secondaryAttacking = false
    
end


/**
 * Fires the specified number of bullets in a cone from the player's current view.
 */
function PortalGun:FirePortal(player, type)

    PROFILE("FirePortal")

    local viewAngles = player:GetViewAngles()
    local viewCoords = player:GetViewCoords()
    local shootCoords = viewAngles:GetCoords()
    
    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    
    local startPoint = player:GetEyePos() 
    
    // Calculate spread for each shot, in case they differ    
    local randomAngle  = NetworkRandom() * math.pi * 2
    local randomRadius = NetworkRandom() * NetworkRandom() * math.tan(kSpread)
    local spreadDirection = (viewCoords.xAxis * math.cos(randomAngle) + viewCoords.yAxis * math.sin(randomAngle))
    local fireDirection = viewCoords.zAxis + spreadDirection * randomRadius
    fireDirection:Normalize()
    local endPoint = startPoint + fireDirection * PortalGun.kRange 
     
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
   
    local direction = (trace.endPoint - startPoint):GetUnit()
    local impactPoint = trace.endPoint - direction
    if trace.entity then
        impactPoint = trace.entity:GetOrigin()
    end 
    local surfaceName = trace.surface

    if Server then
        if trace.fraction < 1 then
            local empBlast = CreateEntity(EMPBlast.kMapName, impactPoint, player:GetTeamNumber())
            local portal = CreateEntity(PortalGunTeleport.kMapName, impactPoint, player:GetTeamNumber())     
            local portalId = portal:GetId()
            local portalChange = nil
            
            if type == 1 then
                if self.portal1Id then
                    local destroyPortal = Shared.GetEntity(self.portal1Id)
                    if destroyPortal then
                        DestroyEntity(destroyPortal)                
                    end
                end
                self.portal1Id = portalId
                
            elseif type == 2 then
                if self.portal2Id then
                    local destroyPortal = Shared.GetEntity(self.portal2Id)
                    if destroyPortal then
                        DestroyEntity(destroyPortal)                
                    end
                end
                self.portal2Id = portalId
            end            
        
            // only set the destination if we got 2 portals
            if self.portal1Id and self.portal2Id then
                local portal1 = Shared.GetEntity(self.portal1Id)
                local portal2 = Shared.GetEntity(self.portal2Id)
                if portal1 and portal2 then
                    portal1:SetDestination(self.portal2Id)
                    portal1:SetType(1)
                    
                    portal2:SetDestination(self.portal1Id)                
                    portal2:SetType(2)
                end
            end
            
            // instant teleport the entity
            if trace.entity then
                if trace.entity:isa("Player") then
                    // set the timeOfLastPhase here so he doesnt get in a loop
                    portal:TeleportEntity(trace.entity)
                end
            end
        end
    end        
  
    local client = Server and player:GetClient() or Client
    if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
        RegisterHitEvent(player, bullet, startPoint, trace, damage)
    end
    
end

function PortalGun:GetHasSecondary(player)
    return true
end

/*
function PortalGun:OnTag(tagName)

    PROFILE("PortalGun:OnTag")

    if tagName == "shoot" then
    
        local player = self:GetParent()
        
        if self.primaryAttacking then
            self:FirePortal(player, 1)
        elseif self.secondaryAttacking then
            self:FirePortal(player, 2)
        end
        
    elseif tagName == "attack_end" then
        self.blockingPrimary = false
    elseif tagName == "alt_attack_end" then
        self.blockingSecondary = false
    end
    
end
*/

/*
function PortalGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("PortalGun:OnUpdateAnimationInput")
    
    local stunned = false
    local interrupted = false
    local player = self:GetParent()
    if player then
    
        if HasMixin(player, "Stun") and player:GetIsStunned() then
            stunned = true
        end
        
        if player.GetIsInterrupted and player:GetIsInterrupted() then
            interrupted = true
        end
        
    end
    
    local activity = "none"
    if not stunned then
    
        if self.primaryAttacking then
            activity = "primary"
        elseif self.secondaryAttacking then
            activity = "primary"
        end
        
    end
    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("flinch_gore", interrupted)
    modelMixin:SetAnimationInput("empty", false)
    modelMixin:SetAnimationInput("gl", true)

end
*/

Shared.LinkClassToMap("PortalGun", PortalGun.kMapName, networkVars)