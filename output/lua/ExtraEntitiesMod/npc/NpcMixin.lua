//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// Adpeted from them original Ns2 Bot

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")

Script.Load("lua/ExtraEntitiesMod/npc/NpcMarineMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcSkulkMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcLerkMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcFadeMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcGorgeMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcOnosMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcExoMixin.lua")

NpcMixin = CreateMixin( NpcMixin )
NpcMixin.type = "Npc"

NpcMixin.kPlayerFollowDistance = 3
NpcMixin.kMaxOrderDistance = 3
NpcMixin.kAntiStuckDistance = 0.2

NpcMixin.kMinAttackGap = 0.6
NpcMixin.kJumpRange = 2

// update rates to increase performance
NpcMixin.kUpdateRate = 0.01
NpcMixin.kTargetUpdateRate = 1
NpcMixin.kRangeUpdateRate = 0.2
NpcMixin.kStuckingUpdateRate = 4

// random offset for npcs that they will not stay all at one spot
local moveOffset = { 
                    x = {-1, -0.5, 0 ,0.5 ,1}, 
                    z = {-1, -0.5, 0 ,0.5 ,1}, 
                    }


NpcMixin.expectedMixins =
{
}

NpcMixin.expectedCallbacks =
{
}


NpcMixin.optionalCallbacks =
{
}


NpcMixin.networkVars =  
{
}


function NpcMixin:__initmixin() 

    if Server then
        InitMixin(self, PathingMixin) 
        InitMixin(self, TargetCacheMixin) 
        
        self.active = false  
        if self.startsActive then
            self.active = true
        end
    
        if self.name1 then
            self:SetName(self.name1)
        end
        
        if self.team then
            self:SetTeamNumber(self.team)
        end
        
        table.insert(self:GetTeam().playerIds, self:GetId())
        self:DropToFloor()    
                
        // configure how targets are selected and validated
        //attacker, range, visibilityRequired, targetTypeList, filters, prioritizers
        self.targetSelector = TargetSelector():Init(
            self,
            40, 
            false,
            self:GetTargets(),
            //{self.FilterTarget(self)},
            { CloakTargetFilter(), self.FilterTarget(self)},            
            { function(target) return target:isa("Player") end } )


        InitMixin(self, StaticTargetMixin)
        
        // special Mixins
        if self:isa("Marine") then
            InitMixin(self, NpcMarineMixin)   
        elseif self:isa("Skulk") then
            InitMixin(self, NpcSkulkMixin)
        elseif self:isa("Lerk") then
            InitMixin(self, NpcLerkMixin)
        elseif self:isa("Gorge") then
            InitMixin(self, NpcGorgeMixin)
        elseif self:isa("Fade") then
            InitMixin(self, NpcFadeMixin) 
        elseif self:isa("Onos") then
            InitMixin(self, NpcOnosMixin)    
        elseif self:isa("Exo") then
            InitMixin(self, NpcExoMixin)   
        end

    end
    
end


function NpcMixin:GetTargets()

    local targets = {}
    if self:GetTeamNumber() == 1 then
        targets = {    
                kMarineStaticTargets, 
                kMarineMobileTargets}        
    else
        targets = {    
            kAlienStaticTargets, 
            kAlienMobileTargets}  
    end

    return targets
end


function NpcMixin:FilterTarget()
    local attacker = self
    return  function (target, targetPosition)
                // dont attack power points or team members
                return target:GetCanTakeDamage() and not target:isa("PowerPoint") and not GetWallBetween(GetEntityEyePos(attacker), targetPosition, target)
                
                    /*
                    local minePos = self:GetEngagementPoint()
                    local weapon = self:GetActiveWeapon()
                    if weapon then
                        minePos = weapon:GetEngagementPoint()
                    end
                    local targetPos = target:GetEngagementPoint()
                    
                    // Make sure we can see target
                    local filter = EntityFilterAll()
                    local trace = Shared.TraceRay(minePos, targetPos , CollisionRep.Damage, PhysicsMask.Bullets, filter)
                    return ((trace.entity == target) or not GetWallBetween(minePos, targetPos, target) or GetCanSeeEntity(self, target))
                    */
            end
            
end
    

function NpcMixin:Reset() 
    if self.startsActive then
        self.active = true
    else
        self.active = false
    end
end

// that the bot act on allerts like follow me
function NpcMixin:TriggerAlert(techId, entity)
    //Print("alarm")
end

function NpcMixin:OnKill()
end


function NpcMixin:OnLogicTrigger(player) 
    self.active = not self.active
end

// Brain of the npc
// 1. generate move
// 2. check special logic
// 3. check important events like health is low, getting attacked etc.
// 4. if no waypoint check if we get one
// 5. process the order, generate a forward move, shoot etc.Accept
// 6. send the move to OnProcessMove(move)
function NpcMixin:OnUpdate(deltaTime)
  
    if self.isaNpc then
        if Server then    
        
            // this will generate an input like a normal client so the bot can move
            //local updateOK = not self.timeLastUpdate or ((Shared.GetTime() - self.timeLastUpdate) > NpcMixin.kUpdateRate) 
            local updateOK = true
            self:GenerateMove(deltaTime)
            if self.active and updateOK and self:GetIsAlive() then
                self:AiSpecialLogic()
                self:CheckImportantEvents() 
                self:ChooseOrder()
                self:ProcessOrder()         
                // Update order values for client
                self:UpdateOrderVariables()                                 
                //self.timeLastUpdate = Shared.GetTime()
            end
            
            assert(self.move ~= nil)
            self:OnProcessMove(self.move)
        end
    else
        // controlled by a client, do nothing
    end

end

////////////////////////////////////////////////////////
//      Movement-Things
////////////////////////////////////////////////////////

function NpcMixin:GenerateMove(deltaTime)

    self.move = Move()    
    // keep the current yaw/pitch as default
    self.move.yaw = self:GetAngles().yaw
    self.move.pitch = self:GetAngles().pitch    
    self.move.time = deltaTime

end

function NpcMixin:AiSpecialLogic()
end

function NpcMixin:CheckImportantEvents()
end

function NpcMixin:ChooseOrder()

    if (not self.timeLastTargetCheck or (Shared.GetTime() - self.timeLastTargetCheck > NpcMixin.kTargetUpdateRate)) then
    
        local order = self:GetCurrentOrder()   

        if not order or self.orderType ~= kTechId.Attack then    
            // don't search for targets if neutral
            if self:GetTeam() ~= 0 then
                self:FindVisibleTarget()
            end    
            if self.mapWaypoint then
                // try to reach the mapWaypoint
                local waypoint = Shared.GetEntity(self.mapWaypoint)
                if waypoint then
                    self:GiveOrder(kTechId.Move , waypoint:GetId(), waypoint:GetOrigin(), nil, true, true)
                end
            end
        end           
                    
        self.timeLastTargetCheck = Shared.GetTime() 
        
    end    
    
end


function NpcMixin:ProcessOrder()

    local order = self:GetCurrentOrder() 
    if order then 
        self:UpdateOrderLogic()
        local orderLocation = order:GetLocation()
        if self.target then
            local target = self:GetTarget()
            if target then
                orderLocation = self:GetTargetEngagementPoint(target)
            end
        end
        if orderLocation then
            self:MoveToPoint(orderLocation)
        end
    end

end


function NpcMixin:UpdateOrderVariables()
    local order = self:GetCurrentOrder() 
    if order and (not oldOrder or order ~= oldOrder) then 
        self.orderPosition = Vector(order:GetLocation())
        self.orderType = order:GetType()   
        oldOrder = order
    end
end

function NpcMixin:GoToNearbyEntity()
    return false
end


function NpcMixin:MoveRandomly()

    assert(self.move ~= nil)
    // Jump up and down crazily!
    if self.active and Shared.GetRandomInt(0, 100) <= 5 then
        self:PressButton(Move.Jump)
    end
    
    return true
    
end

function NpcMixin:ChooseRandomDestination()

    assert(self.move ~= nil)
    // Go to nearest unbuilt tech point or nozzle
    local className = ConditionalValue(math.random() < .5, "TechPoint", "ResourcePoint")

    local ents = Shared.GetEntitiesWithClassname(className)
    
    if ents:GetSize() > 0 then 
    
        local index = math.floor(math.random() * ents:GetSize())
        
        local destination = ents:GetEntityAtIndex(index)
        
        self:GiveOrder(kTechId.Move, 0, destination:GetEngagementPoint(), nil, true, true)
        
        return true
        
    end
    
    return false
    
end

function NpcMixin:CheckCrouch(targetPosition)
end

function NpcMixin:MoveToPoint(toPoint)

    assert(self.move ~= nil)
    assert(toPoint ~= nil)
    
    local order = self:GetCurrentOrder()
    toPoint = self:GetNextPoint(order, toPoint) or toPoint

    // Fill in move to get to specified point
    local diff = (toPoint - self:GetEyePos())
    local direction = GetNormalizedVector(diff)
        
    // Look at target (needed for moving and attacking)
    self.move.yaw   = GetYawFromVector(direction) - self:GetBaseViewAngles().yaw
    self.move.pitch = GetPitchFromVector(direction)
    
    if self:GetIsButtonPressed(Move.PrimaryAttack) or self:GetIsButtonPressed(Move.SecondaryAttack) then
        // sometimes, don't hit the target (would be unfair if bots would hit everything all the time)
        local random = math.random(1, 100)
        if random < 10 then
            self.move.yaw = self.move.yaw + 0.1
        elseif random < 20 then
            self.move.pitch = self.move.pitch + 0.1
        end
    end
   
    local moved = false
    
    // Generate naive move towards point
    if not self.toClose and not self.inTargetRange then
        self.move.move.z = 1  
        moved = true
    elseif self.toClose then
        // test wheres place to go
        local startPoint = self:GetEyePos()
        local viewAngles = self:GetViewAngles() 
        local fowardCoords = viewAngles:GetCoords()
        local trace = Shared.TraceRay(startPoint, startPoint + (fowardCoords.zAxis * -5), CollisionRep.LOS, PhysicsMask.AllButPCs, EntityFilterOne(self))        
        if (trace.endPoint - startPoint):GetLength() >= 1 then
            // enough space, move back
            self.move.move.z = -1     
        else
            // move left or right (random)
            if math.random(1,2) == 1 then
                self.move.move.x = -1
            else
                self.move.move.x = 1
            end
        end
        
        if self:GetCanJump() and (self:GetOrigin() - toPoint):GetLengthXZ() < NpcMixin.kJumpRange then
            // sometimes jump (real players do that, too)
            if Shared.GetRandomInt(0, 80) <= 5 then
                self:PressButton(Move.Jump)
            end
        end
        moved = true       
        self.toClose = false
    else
        self:CheckCrouch(toPoint)
    end
    
    // check if we need to unstuck
    if self.unstuckXMove then
        self.move.move.x = self.unstuckXMove
    end
    
    if moved and not self.target then
        self.targetSelector:AttackerMoved()
    end

end


function NpcMixin:PressButton(button)
    assert(self.move ~= nil)
    assert(button ~= nil)
    self.move.commands = bit.bor(self.move.commands, button)
end

function NpcMixin:GetIsButtonPressed(button)
    assert(self.move ~= nil)
    assert(button ~= nil)
    return (bit.band(self.move.commands, button) ~= 0)
end



////////////////////////////////////////////////////////
//      Order-Things
////////////////////////////////////////////////////////

function NpcMixin:OnOrderGiven()
    // delete old values
    self:ResetOrderParamters()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder:GetType() == kTechId.Attack then        
        self.target = currentOrder:GetParam()
    else
        // apply an offset for waypoints so not staying at one spot
        if self.mapWaypoint == currentOrder:GetParam()  then
        
            local randomOffset = math.random(1, #moveOffset.x)
            local offsetVector = Vector(0,0,0)
            
            if math.random(1, 2) == 1 then
                offsetVector.x = moveOffset.x[randomOffset]
            else
                offsetVector.z = moveOffset.z[randomOffset] 
            end

            currentOrder:SetLocation(currentOrder:GetLocation() + offsetVector)
            
        end
    end
end

function NpcMixin:DeleteCurrentOrder()
    self:CompletedCurrentOrder()
end

function NpcMixin:OnOrderComplete(currentOrder)
    self:ResetOrderParamters()
    // delete mapWaypoint if we really reached it
    if self.mapWaypoint == currentOrder:GetParam() then
        self.mapWaypoint = nil
    end
end

function NpcMixin:ResetOrderParamters()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder then        
        if currentOrder:GetParam() ~= self.target then
            self.target = nil
        end
    else
        self.target = nil
    end
    
    self:ResetPath()

    self.toClose = false
    self.inTargetRange = false
    self.unstuckXMove = nil
    self.timeLastOrder = nil
    
end


////////////////////////////////////////////////////////
//      Attack-Things
////////////////////////////////////////////////////////

function NpcMixin:GetAttackDistance()

    if self.GetAttackDistanceOverride then
        return self:GetAttackDistanceOverride()
    else
        local activeWeapon = self:GetActiveWeapon()
        
        if activeWeapon then
            return math.min(activeWeapon:GetRange(), 40)
        end
    end
    
    return NpcMixin.kMinAttackGap
    
end


function NpcMixin:GetTargetEngagementPoint(target)
    assert(target~=nil)
    local engagementPoint = target:GetEngagementPoint()
    if self.EngagementPointOverride then
        engagementPoint = self:EngagementPointOverride(target) or engagementPoint
    end
    return engagementPoint 
end


function NpcMixin:FindVisibleTarget()

    // Are there any visible enemy players or structures nearby?
    local success = false

    if not self.target then
        self.targetSelector:AttackerMoved()
        success = NpcUtility_AcquireTarget(self)
    else
        self.target = nil
        self:DeleteCurrentOrder()
    end
    
    return success
    
end


function NpcMixin:GetMinAttackGap() 

    if not self.minAttackGap then
        self.minAttackGap = NpcMixin.kMinAttackGap
    end 

    if (self:GetAttackDistance() > NpcMixin.kMinAttackGap) then
  
        // make it a bit random   
        if self:GetAttackDistance() > 10 then
            self.minAttackGap = math.random(4, 25)
        else
            self.minAttackGap = math.max(NpcMixin.kMinAttackGap, math.random(NpcMixin.kMinAttackGap, math.min(self:GetAttackDistance(), 8)))
        end

    end   

    return self.minAttackGap 
    
end


function NpcMixin:CanAttackTarget(targetOrigin)
    return GetCanSeeEntity(self, targetOrigin) and (targetOrigin - self:GetModelOrigin()):GetLength() < (self:GetAttackDistance() or 0)
end

function NpcMixin:UpdateOrderLogic()

    assert(self.move ~= nil)
    local order = self:GetCurrentOrder()  

    if order ~= nil then
        if (self.orderType == kTechId.Attack) and self.target then

            local activeWeapon = self:GetActiveWeapon()
            local target = Shared.GetEntity(self.target)
            
            if target then            
                    
                // if were in range, only updated it after some time
                if not self.timeLastRangeUpdate or not self.inTargetRange or (self.inTargetRange and ((Shared.GetTime() -  self.timeLastRangeUpdate ) > NpcMixin.kRangeUpdateRate)) then
                
                    local engagementPoint = self:GetTargetEngagementPoint(target)                   
                    local distToTarget = (engagementPoint - self:GetModelOrigin()):GetLength()
                    local attackDist = self:GetAttackDistance()
                    
                    self.inTargetRange = false
                    self.toClose = false
                    
                    if activeWeapon and attackDist and (distToTarget <= attackDist) then        
                        // Make sure we can see target
                        local filter = EntityFilterTwo(self, activeWeapon)

                        local trace = Shared.TraceRay(self:GetEyePos(), engagementPoint , CollisionRep.Damage, PhysicsMask.Bullets, filter)
                        if trace.entity == target or (engagementPoint - trace.endPoint):GetLengthXZ() <= 2  then                                        
                            self.inTargetRange = true   
                                                                            
                             // if its not a structure, dont come to close
                            if HasMixin(target,"MobileTarget") and (distToTarget < self:GetMinAttackGap()) then
                                self.toClose = true
                            end  
                        end
                        
                    end
                                
                    self.timeLastRangeUpdate = Shared.GetTime() 
                   
                end                
                
                if self.inTargetRange then
                    self:Attack(activeWeapon)  
                end

            
            else
                // target isnt valid anymore
                self.target = nil
                self:DeleteCurrentOrder()
            end
            


        end
    else
        // if were a marine a have currently the pistol selected, switch back to rifle

    end
    
    return nil
    
end

function NpcMixin:Attack(activeWeapon)
    assert(self.move ~= nil)
    if self.AttackOverride then
        self:AttackOverride(activeWeapon)
    else
        self:PressButton(Move.PrimaryAttack)
    end        
end


function NpcMixin:OnTakeDamage(damage, attacker, doer, point)
    if Server then
        self.lastAttacker = attacker 
        local order = self:GetCurrentOrder()
        // if were getting attacked, attack back
        if attacker and (not order or (order and (self.orderType ~= kTechId.Attack or not Shared.GetEntity(order:GetParam()):isa("Player")) )) then
            self:GiveOrder(kTechId.Attack, attacker:GetId(), self:GetTargetEngagementPoint(attacker), nil, true, true)
            NpcUtility_InformTeam(self, attacker)       
        end
    end
end

// cheap trick, function is from LOS Mixin, will warn us if somebody sees us
function NpcMixin:SetIsSighted(sighted, viewer)
    if sighted and viewer and viewer:isa("Player") then
        // when enemy sees us and we have no target, attack him
        local order = self:GetCurrentOrder()
        if not order or (order and (self.orderType ~= kTechId.Attack or not Shared.GetEntity(order:GetParam()):isa("Player")) ) then
            self:GiveOrder(kTechId.Attack, viewer:GetId(), self:GetTargetEngagementPoint(viewer), nil, true, true)
            NpcUtility_InformTeam(self, viewer)       
        end
    end
end

////////////////////////////////////////////////////////
//      Pathing-Things
////////////////////////////////////////////////////////


function NpcMixin:GetNextPoint(order, toPoint)
    if (order and self.orderType ~= kTechId.Attack) or (not self.toClose and not self.inTargetRange) then
        if self.oldPoint and self.oldOrigin and self.oldPoint == toPoint then
            // if its the same point, lets look if we can still move there
            if (self.points and not self:CheckTargetReached(self.points[#self.points])) and (not self.timeLastStuckingCheck or (Shared.GetTime() - self.timeLastStuckingCheck > NpcMixin.kStuckingUpdateRate)) then
                if math.abs((self:GetOrigin() - self.oldOrigin):GetLengthXZ()) < NpcMixin.kAntiStuckDistance then
                
                    // we're still in the same spot
                    // if we already tried to unstuck, maybe jump
                    if self.unstuckXMove and self:GetCanJump() then   
                        if math.random(1, 4) == 1 then
                            self:PressButton(Move.Jump)
                        end
                    end
                    
                    if math.random(1,2) == 1 then
                        self.unstuckXMove = -1
                    else
                        self.unstuckXMove = 1
                    end

                else
                    self.unstuckXMove = nil
                end
                self.timeLastStuckingCheck = Shared.GetTime()
            // no points? create new one
            elseif not self.points and self.orderPosition then            
                self:GeneratePath(self.orderPosition)
            end
        else

            // check if its still the same target, maybe the target has just moved
            // then calculate how far are we away, maybe we can keep the path at the moment
            // will improve performance a bit ( I hope)

            if self.oldPoint and self.points and self.points[self.index] and (toPoint - self.oldPoint):GetLength() < 3 then
                // just change last path point th the target point 
                self.points[table.maxn(self.points)] = toPoint
            else
                // OK its rly something new, generate a Path
                local location = GetGroundAt(self, toPoint, PhysicsMask.Movement)
                if self:GetIsFlying() then
                    location = GetHoverAt(self, toPoint, EntityFilterOne(self))
                end
                if not self:GeneratePath(location) then
                    // thers no path
                    self:DeleteCurrentOrder()
                end  
            end
            
            self.oldPoint =  toPoint
            
        end                    

        self.oldOrigin = self:GetOrigin()
            
        if self.points and #self.points ~= 0 then            

            if not self.index then
                self.index = 1
            end
            
            if self.index <= #self.points then
                toPoint = self.points[self.index]
                if self:CheckTargetReached(toPoint) then
                    // next point
                    self.index = self.index + 1
                    self.unstuckXMove = nil
                end
            else
                if self.orderType ~= kTechId.Attack and (order:GetType() ~= kTechId.Build and order:GetType() ~= kTechId.Construct)  then
                    // end point is reached
                    self:DeleteCurrentOrder()
                end
            end
        end
        
    end
    return toPoint
end


function NpcMixin:CheckTargetReached(endPoint)
    return (self:GetOrigin() - endPoint):GetLengthXZ() <= NpcMixin.kMaxOrderDistance 
end


function NpcMixin:GeneratePath(endPoint)
    self:ResetPath()
    self.points = GeneratePath(self:GetOrigin(), endPoint, false, 2, 2, self:GetIsFlying())
    if self.points and #self.points > 0 then
        return true
    else
        return false
    end
end

function NpcMixin:ResetPath()
    self.index = nil
    self.points = nil
    self.cursor = nil
end


if Server then

    function OnConsoleNpcActive(client)
        for i, npc in ipairs(GetEntitiesWithMixin("Npc")) do
            npc.active = true
        end
    end

    Event.Hook("Console_npc_active",  OnConsoleNpcActive)

end



