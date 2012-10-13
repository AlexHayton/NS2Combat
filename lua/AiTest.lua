//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// initially, this was for my singlepalyer project, but lets make a cool halloween ai with that


//******************************************
//* Scripts 
//******************************************

Script.Load("lua/Exo.lua")

// needed for the MoveToTarget Command
Script.Load("lua/PathingMixin.lua")
// needed for the Attack Command
Script.Load("lua/AttackOrderMixin.lua")

Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/DamageMixin.lua")


class 'AITEST' (Exo)

//******************************************
//* Class variables
//******************************************

AITEST.kMapName = "aitest"

AITEST.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
AITEST.kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_cm.animation_graph")

AITEST.kFireRange              = kARCRange
AITEST.kArmor = 1500
AITEST.kMoveSpeed = 5
local kMoveParam = "move_speed"


//******************************************
//* Network variables
//******************************************

if Server then
    //Script.Load("lua/ai/aiITest_Server.lua")
end

local networkVars =
{
    targetDirection = "vector",
    moving = "boolean",
    attacking = "boolean",
    attackPitch = "integer (0 to 360)",
}

AddMixinNetworkVars(AttackOrderMixin, networkVars)


//******************************************
//* Functions
//******************************************


// onCreate and OnInitilized need every class
function AITEST:OnCreate()

    Exo.OnCreate(self)
    InitMixin(self, PathingMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, AttackOrderMixin)
  
    if Server then  
    end
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetTeamNumber(kTeam1Index)
    
end

function AITEST:OnInitialized()
    
    // setModel need to be called before the Initialize
    self:SetModel(AITEST.kModelName, AITEST.kAnimationGraph) 
    
    // exo.OnInitialized will give the weapons
    self.layout = "ClawMinigun"   
    Exo.OnInitialized(self)
    
    self.armor = AITEST.kArmor
    self.maxArmor = self.armor
    self.moving = false
    self.attacking  = false
    self.attackPitch = 0
       
    if Server then
    
        self:SetUpdates(true)               
        self:SetPhysicsType(PhysicsType.Kinematic)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    end
    
end

// Buttons for commander
function AITEST:GetTechButtons(techId)

    if techId == kTechId.RootMenu then
        
        return  { kTechId.Attack, kTechId.Stop, kTechId.Move, kTechId.None,
                  kTechId.ARCUndeploy, kTechId.None, kTechId.None, kTechId.None }        

    else
        return nil
    end
    
end


// called all the time from the engine
function AITEST:OnUpdate(deltaTime)

    PROFILE("AITEST:OnUpdate")
    
    Exo.OnUpdate(self, deltaTime)
    self:UpdateMoveYaw(self, deltaTime)
    
    if Server then
        self:UpdateOrders(deltaTime)
    end
   
end


function AITEST:GetCanSleep()
    return false // not self.moving and not self.whackAttack:GetTarget()
end


// for camera
function AITEST:GetViewOffset()
    return self:GetCoords().yAxis * 1.0
end

function AITEST:GetEyePos()
    return self:GetOrigin() + self:GetViewOffset()
end


// needed for the pathing mixin
// TODO: exos can maybe fly later
function AITEST:GetIsFlying()
    return false
end

// TODO: speed maybe not everytime the same?
function AITEST:GetSpeed()
    return AITEST.kMoveSpeed
end

function AITEST:GetCurrentSpeed()

    if self.moving then
        return self.kMoveSpeed
    else
        return 0
    end
        
end


function AITEST:GetCanTakeDamageOverride()
    //return Player.GetCanTakeDamageOverride(self) and not self:GetIsFeinting()
    return true
end

function AITEST:GetCanDieOverride()
    return true
end

//******************************************
//* Animation things
//******************************************

// to update the visual animation effects
// TODO: idle, shooting etc.
function AITEST:OnUpdateAnimationInput(modelMixin)

    PROFILE("AITEST:OnUpdateAnimationInput")
    
    local move = "idle"
    local activity_left = "none"
    local activity_right = "none"
    
    local currentOrder = self:GetCurrentOrder()
    if self.moving then        
        move = "run"
    end
    
    if self.attacking  then    
        activity_left = "primary"
    end
    
    modelMixin:SetAnimationInput("move",  move)
    modelMixin:SetAnimationInput("activity_left",  activity_left)
    modelMixin:SetAnimationInput("activity_right",  activity_right)

    
end


// to handle animation changes
function AITEST:OnTag(tagName)

    PROFILE("AITEST:OnTag")
    
    if tagName == "deploy_end" then
        self.deployed = true
    end
    
    
end


function AITEST:OnUpdatePoseParameters()
    
    if not Shared.GetIsRunningPrediction() then
        
        local viewModel = self:GetViewModelEntity()
        if viewModel ~= nil then
        
            local activeWeapon = self:GetActiveWeapon()
            if activeWeapon and activeWeapon.UpdateViewModelPoseParameters then
                activeWeapon:UpdateViewModelPoseParameters(viewModel, input)
            end
            
        end

        //SetPlayerPoseParameters(self, viewModel)
        //self:SetPoseParam(kMoveParam, 1)
        
    end

end


// really important function, animation are not getting played without it
function AITEST:UpdateMoveYaw()
 
    local viewCoords = Coords.GetLookIn(self:GetEyePos(), self:GetOrigin())
    local viewAngles = Angles()
    viewAngles:BuildFromCoords(viewCoords)
    
    local pitch = -Math.Wrap(Math.Degrees(viewAngles.pitch), -180, 180)
    
    if self.attackPitch then
        pitch = self.attackPitch    
    end
    
    local landIntensity = self.landIntensity or 0
    
    local bodyYaw = 0
    if self.bodyYaw then
        bodyYaw = Math.Wrap(Math.Degrees(self.bodyYaw), -180, 180)
    end
    
    local bodyYawRun = 0
    if self.bodyYawRun then
        bodyYawRun = Math.Wrap(Math.Degrees(self.bodyYawRun), -180, 180)
    end    
   
    local horizontalVelocity = self:GetVelocityFromPolar()
    // Not all selfs will contrain their movement to the X/Z plane only.
    if self.GetMoveSpeedIs2D and self:GetMoveSpeedIs2D() then
        horizontalVelocity.y = 0
    end
    
    //local x = Math.DotProduct(viewCoords.xAxis, horizontalVelocity)
    //local z = Math.DotProduct(viewCoords.zAxis, horizontalVelocity)
    
    //local moveYaw = Math.Wrap(Math.Degrees( math.atan2(z,x) ), -180, 180)
    local speedScalar = self:GetVelocityLength() / self:GetMaxSpeed(true)
    
    self:SetPoseParam("move_yaw", bodyYaw +90)
    self:SetPoseParam("body_pitch", pitch)
    self:SetPoseParam("body_yaw", bodyYaw)
    self:SetPoseParam("body_yaw_run", bodyYawRun)
    
    self:SetPoseParam(kMoveParam, self:GetCurrentSpeed())
    self:SetPoseParam("crouch", self:GetCrouchAmount())
    self:SetPoseParam("land_intensity", landIntensity)

end    


function AITEST:SetAttackPitch(targetLocation)
    
    if targetLocation then 
        // Update our attackYaw to aim at our current target

        local bodyPitchVec = targetLocation - self:GetModelOrigin()
        bodyPitchVec:Normalize()
        self.attackPitch = GetPitchFromVector(bodyPitchVec)        
        
        if self.attackPitch < 0 then
            self.attackPitch = self.attackPitch + 360                     
                    
            // pitch and roll the body now, before we trace the front tracks
            local angles = self:GetAngles()
            angles.pitch = self.attackPitch
            self:SetAngles(angles)            
            coords = self:GetCoords()
            
            return
        end

    end
    
    self.attackPitch = 0
    
end


//******************************************
//* Orders, KI Things
//******************************************

// called from OnUpdate to handle the different orders
function AITEST:UpdateOrders(deltaTime)

    local order = self:GetCurrentOrder()
    
    if order == nil then   
        self:CheckForTargets()
    else   
    
        // If we have no order or are attacking, acquire possible new target    
        if order:GetType() == kTechId.Attack then
            self:UpdateAttackOrder(deltaTime)
        elseif order:GetType() == kTechId.Move then
            self:UpdateMoveOrder(deltaTime)        
        end

        // If we aren't attacking, try something else    
        if order == nil then
        
            // Move to random tech point or nozzle on map
            self:ChooseRandomDestination()
                
        end
    end

    
end


function AITEST:CheckForTargets()

    // Check for new target every so often, but not every frame
    local time = Shared.GetTime()
    if self.timeOfLastAcquire == nil or (time > self.timeOfLastAcquire + 0.2) then
    
        success = self:AttackVisibleTarget()        
        self.timeOfLastAcquire = time
        
        if success then
            self.attacking = true
        else
            self.attacking = false
        end
        
    end

end

function AITEST:UpdateMoveOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)
    
    
    target = self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), self:GetSpeed(), deltaTime)
    
    if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
    
        self:CompletedCurrentOrder()
        self.moving = false
        
        // If no more orders, we're done
        if self:GetCurrentOrder() == nil then
            //self:SetMode(ARC.kMode.Stationary)
        end
        
    else
        self.moving = true
    end
        
end


function AITEST:ChooseRandomDestination()
    // if it got no orders, walk a bit
    // Go to nearest unbuilt tech point or nozzle
    local className = ConditionalValue(math.random() < .5, "TechPoint", "ResourcePoint")
    local ents = Shared.GetEntitiesWithClassname(className)
    
    if ents:GetSize() > 0 then         
        local index = math.floor(math.random() * ents:GetSize())            
        local destination = ents:GetEntityAtIndex(index)            
        self:GiveOrder(kTechId.Move, 0, destination:GetEngagementPoint(), nil, true, true)            
    end 
end



function AITEST:SetTargetDirection(target)
    self.targetDirection = GetNormalizedVector(target:GetEngagementPoint() - self:GetAttachPointOrigin(kMuzzleNode))
end

function AITEST:ClearTargetDirection()
    self.targetDirection = nil
end


//******************************************
//* Attackorder things
//******************************************

function AITEST:AttackVisibleTarget()

    local player = self

    // Are there any visible enemy players or structures nearby?
    local success = false
    
    if not self.timeLastTargetCheck or (Shared.GetTime() - self.timeLastTargetCheck > 2) then
    
        local nearestTarget = nil
        local nearestTargetDistance = nil
        
        local targets = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(player:GetTeamNumber()), player:GetOrigin(), 20)
        for index, target in pairs(targets) do
        
            if target:GetIsAlive() and target:GetIsVisible() and target:GetCanTakeDamage() and target ~= player then
            
                // Prioritize players over non-players
                local dist = (target:GetEngagementPoint() - player:GetModelOrigin()):GetLength()
                
                local newTarget = (not nearestTarget) or (target:isa("Player") and not nearestTarget:isa("Player"))
                if not newTarget then
                
                    if dist < nearestTargetDistance then
                        newTarget = not nearestTarget:isa("Player") or target:isa("Player")
                    end
                    
                end
                
                if newTarget then
                
                    nearestTarget = target
                    nearestTargetDistance = dist
                    
                end
                
            end
            
        end
        
        if nearestTarget then
        
            local name = SafeClassName(nearestTarget)
            if nearestTarget:isa("Player") then
                name = nearestTarget:GetName()
            end
            
            player:GiveOrder(kTechId.Attack, nearestTarget:GetId(), nearestTarget:GetEngagementPoint(), nil, true, true)
            
            success = true
        end
        
        self.timeLastTargetCheck = Shared.GetTime()
        
    end
    
    return success
    
end


function AITEST:UpdateAttackOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)
    
    // Get target
    local target = Shared.GetEntity(currentOrder:GetParam())
    if target then
        
        if target:GetIsAlive() then
            local targetLocation = target:GetEngagementPoint()     
            // If we are close enough to target, attack it    
            local targetPosition = Vector(target:GetOrigin())
            
            // Different targets can be attacked from different ranges, depending on size
            local attackDistance = kExoEngagementDistance - 0.1     
            local distanceToTarget = (targetPosition - self:GetOrigin()):GetLength()
            
            if distanceToTarget <= attackDistance  then
                //OrderMeleeAttack(self, target)
                self.moving = false
                self.attacking = true
                self:SetAttackPitch(targetPosition)
            else
                self:MoveToTarget(PhysicsMask.AIMovement, targetLocation, self.GetSpeed(), deltaTime)
                self.moving = true
                self.attacking = false
                self:SetAttackPitch(nil)
            end
        else
            self:CompletedCurrentOrder()
            self.moving = false
            self.attacking = false
            self:SetAttackPitch(nil)
        end
        
    end

end


function AITEST:GetMeleeAttackOrigin()
    return self:GetAttachPointOrigin("bone_Claw_Hand")
end

function AITEST:GetMeleeAttackDamage()
    return kMACAttackDamage
end

function AITEST:GetMeleeAttackInterval()
    return kMACAttackFireDelay 
end

//******************************************
//* Client things
//******************************************


Shared.LinkClassToMap("AITEST", AITEST.kMapName, networkVars)