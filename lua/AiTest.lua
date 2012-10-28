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

Script.Load("lua/Onos.lua")

// needed for the MoveToTarget Command
Script.Load("lua/PathingMixin.lua")
// needed for the Attack Command
Script.Load("lua/AttackOrderMixin.lua")
Script.Load("lua/OrdersMixin.lua")

Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/DamageMixin.lua")


class 'AITEST' (Onos)

//******************************************
//* Class variables
//******************************************

AITEST.kMapName = "aitest"

AITEST.kModelName = PrecacheAsset("models/alien/onos/onos.model")
AITEST.kViewModelName = PrecacheAsset("models/alien/onos/onos_view.model")
AITEST.AnimationGraph = PrecacheAsset("models/alien/onos/onos.animation_graph")

AITEST.kFireRange              = kARCRange
AITEST.kArmor = 2045
AITEST.kMoveSpeed = 7.5
AITEST.kFireEffect         = PrecacheAsset("cinematics/environment/fire_small.cinematic")
AITEST.MaxDistance = 25
// gore is 95
AITEST.Damage = 85

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
AddMixinNetworkVars(OrdersMixin, networkVars)


//******************************************
//* Functions
//******************************************


// onCreate and OnInitilized need every class
function AITEST:OnCreate()

    Exo.OnCreate(self)
    InitMixin(self, PathingMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, AttackOrderMixin)
  
    if Server then  
    end
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetTeamNumber(kTeam1Index)
    
end

function AITEST:OnInitialized()
    
    Onos.OnInitialized(self)
    // setModel need to be called before the Initialize
    //self:SetModel(AITEST.kModelName, AITEST.AnimationGraph) 

    self.armor = AITEST.kArmor
    self.maxArmor = self.armor
    self.moving = false
    self.attacking  = false
    self.attackPitch = 0
       
    if Server then          
        //self:GiveItem(Gore.kMapName)
        //self:SetActiveWeapon(Gore.kMapName)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
        // create the fire cinematic
        self:SetUpdates(true)  
        self.fireEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        local cinematicName = AITEST.kFireEffect
        
        self.fireEffect:SetCinematic(cinematicName)
        self.fireEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.fireEffect:SetIsVisible(true)

        self:SetFirePosition()
    
    end
    
end


function AITEST:OnDestroy()
	if Client then		
		 Client.DestroyCinematic(self.fireEffect)
         self.fireEffect = nil	
	end
end

function AITEST:OnKill(attacker, doer, point, direction)
    combatHalloween_SendKilledMessage(attacker:GetName())
    combatHalloween_RemoveAi()
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
    
    Onos.OnUpdate(self, deltaTime)
    self:UpdateMoveYaw(self, deltaTime)
    
    if Server then
        self:UpdateOrders(deltaTime)
    elseif Client then
        // update fire position
        self:SetFirePosition()
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
    local activity = "none"
    local ability = "none"
    
    local currentOrder = self:GetCurrentOrder()
    if self.moving then        
        move = "run"
    end
    
    if self.attacking  then    
        activity = "primary"
        ability = "gore"
    end
    
    modelMixin:SetAnimationInput("move",  move)
    modelMixin:SetAnimationInput("ability",  move)
    modelMixin:SetAnimationInput("activity",  activity)

    
end


// to handle animation changes
function AITEST:OnTag(tagName)

    PROFILE("AITEST:OnTag")
    
    if tagName == "deploy_end" then
        self.deployed = true
    end   
    
end


function AITEST:OnUpdatePoseParameters()
    
    if self.movementModiferState then
        
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
    
    //if self.attackPitch then
      //  pitch = self.attackPitch    
    //end
    
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
        // if order still nill, do something else  
        if order == nil then
            // Move to random tech point or nozzle on map
            self:ChooseRandomDestination()                    
        end
    else   
    
        // If we have no order or are attacking, acquire possible new target    
        if order:GetType() == kTechId.Attack then
            self:UpdateAttackOrder(deltaTime)
        elseif order:GetType() == kTechId.Move then
            self:UpdateMoveOrder(deltaTime)        
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
        // even if were walking, check for targets
        self:CheckForTargets()
    end
        
end


function AITEST:ChooseRandomDestination()
    // if it got no orders, walk a bit
    // Go to nearest unbuilt tech point or nozzle
    local randomInt = math.random(1,2)
    teamStart = {
                GetGamerules():GetTeam1():GetInitialTechPoint(),
                GetGamerules():GetTeam2():GetInitialTechPoint()
                }
    
    if table.maxn(teamStart) > 0 then  
        local destination = teamStart[randomInt]            
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
        
        // find enemys from both teams
        local targets = {}
        local targets1 = GetEntitiesWithMixinForTeamWithinRange("Live", kTeam1Index, player:GetOrigin(), 20)
        local targets2 = GetEntitiesWithMixinForTeamWithinRange("Live", kTeam2Index, player:GetOrigin(), 20)
        
        for i, entry in ipairs (targets1) do table.insert(targets, entry) end
        for i, entry in ipairs (targets2) do table.insert(targets, entry) end   

        targets1 = nil
        targets2 = nil
        
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
                    // can we reach it?
                    nearestTarget = target
                    nearestTargetDistance = dist
                end
                
            end
            
        end
        
        if nearestTarget and nearestTargetDistance <= AITEST.MaxDistance then
        
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
            local attackDistance = 2.7     
            // if the enemy is to far away, search a new one
            local maxDistance =  AITEST.MaxDistance
            local distanceToTarget = (targetPosition - self:GetOrigin()):GetLength()
            
            if distanceToTarget <= attackDistance  then
                //OrderMeleeAttack(self, target)
                self.moving = false
                self.attacking = true
                //self:SetAttackPitch(targetPosition)
                self:AttackVictim(target)
                return
            elseif distanceToTarget <= maxDistance then
                success = self:MoveToTarget(PhysicsMask.Movement, targetLocation, self.GetSpeed(), deltaTime)
                if not success then
                    self.moving = true
                    self.attacking = false
                    //self:SetAttackPitch(nil)
                    return
                end
            end
        end
        
        self:CompletedCurrentOrder()
        self.moving = false
        self.attacking = false
        //self:SetAttackPitch(nil)
        
    end

end

function AITEST:AttackVictim(target)

    local weapon = self:GetActiveWeapon()
    local meleeAttackInterval = self:GetMeleeAttackInterval()
    
    if Shared.GetTime() > (self.timeOfLastAttackOrder + meleeAttackInterval) then         
        if weapon then
            weapon:Attack(self)
        else
            self:MeleeAttack(self, target)
        end
        
        self.timeOfLastAttackOrder = Shared.GetTime()            
    end

end

function AITEST:MeleeAttack(self, target)

    // Traceline from us to them
    local trace = Shared.TraceRay(self:GetMeleeAttackOrigin(), target:GetOrigin(), CollisionRep.Damage, PhysicsMask.AllButPCs, EntityFilterTwo(self, target))

    local direction = target:GetOrigin() - self:GetOrigin()
    direction:Normalize()
    
    // Use player or owner (in the case of MACs, Drifters, etc.)
    local attacker = self:GetOwner()
    if self:isa("Player") then
        attacker = self
    end
    
    if HasMixin(self, "Cloakable") then
        self:TriggerUncloak()
    end
    
    self:DoDamage(AITEST.Damage, target, trace.endPoint, direction, trace.surface)

end

function AITEST:GetIsFeinting()
    return false
end

function AITEST:GetEnergy()
    return self:GetMaxEnergy()
end

function AITEST:GetMeleeAttackOrigin()
    return self:GetAttachPointOrigin("Onos_tounge02")
end

function AITEST:GetMeleeAttackDamage()
    return kMACAttackDamage
end

function AITEST:GetMeleeAttackInterval()
    return 0.9
end

//******************************************
//* Client things
//******************************************


function AITEST:SetFirePosition()    
    if Client then  
        local coords = Coords.GetIdentity()
        coords.origin = self:GetAttachPointOrigin("Onos_Head")     
        self.fireEffect:SetCoords(coords)
    end
end

Shared.LinkClassToMap("AITEST", AITEST.kMapName, networkVars, true)