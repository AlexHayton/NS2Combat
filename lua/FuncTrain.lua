//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// FuncTrain.lua
// Entity for mappers to create drivable trains

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/Mixins/SignalEmitterMixin.lua")
// needed for the MoveToTarget Command
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/TriggerMixin.lua")

class 'FuncTrain' (ScriptActor)

FuncTrain.kMapName = "func_train"
FuncTrain.kMoveSpeed = 3.0
FuncTrain.kHoverHeight = 0.3
FuncTrain.kDrivingState = enum( {'Forward1', 'Forward2', 'Forward3', 'Backwards'} )

local networkVars =
{
    nextWaypointId = "entityid",
    driving = "boolean",
    drivingState = "enum FuncTrain.kDrivingState",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)


function FuncTrain:OnCreate()
 
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, SignalEmitterMixin)
    InitMixin(self, PathingMixin)
  
    self:SetUpdates(true)  
    
end

function FuncTrain:OnInitialized()

    ScriptActor.OnInitialized(self)
    InitMixin(self, TriggerMixin)
       
    if self.model ~= nil then    
        Shared.PrecacheModel(self.model)        
        local graphName = string.gsub(self.model, ".model", ".animation_graph")
        Shared.PrecacheAnimationGraph(graphName)        
        self:SetModel(self.model, graphName)        
    end
    
    if self.autoStart then
        self.driving = true
    else
        self.driving = false
    end
    
    if Server then
        // set a box so it can be triggered
        local extents = self:GetExtents()
        extents = 20 * extents
        self:SetBox(extents)
    end

    self.direction = "fw"
    
end


function FuncTrain:OnUpdate(deltaTime)
    if Server then
        if self.driving then
            self:UpdatePosition(deltaTime)
            self:SetOldAngles(self:GetAngles())
            self:MovePlayersInTrigger()        
            self:MoveTrigger()    
        end
    end
end

function FuncTrain:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = true
end

function FuncTrain:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

    if Server then   
        self:ChangeDrivingStatus()
    elseif Client then
        if self.Used then
            self:DestroyDrivingGui()
        else
            self:ShowDrivingGui()
        end
    end
    
end

//**********************************
// Driving things
//**********************************

function FuncTrain:ChangeDrivingStatus()

    if self.driving then
        self.driving = false
    else
        self.driving = true
    end  
    
    local driveString = "off"
    if self.driving then
        driveString = "on"
    end    
  
end 


function FuncTrain:SetOrigin(origin)
    // locally save the old origin
    local oldOrigin = self:GetOrigin()    
    Entity.SetOrigin(self, origin)
    
    if (oldOrigin.x + oldOrigin.y + oldOrigin.z) ~= 0 then
        self:SetMovementVector(self:GetOrigin() - oldOrigin)        
    end
    
    //if self.oldAngles then
      //  self:SetDeltaAngles(self:GetAngles())
//        self.oldAngles = self:GetAngles()
  //  else
    //    self.oldAngles = self:GetAngles()
    //end
        
end

// set and get Velocity to update the players movement, too
function FuncTrain:SetMovementVector(newVector)
    self.movementVector = newVector   
end

function FuncTrain:GetMovementVector()
    return self.movementVector or Vector(0,0,0)     
end

function FuncTrain:SetOldAngles(newAngles)

    if self.oldAngles then
        self:SetOldAnglesDiff(newAngles)
        self.oldAngles.yaw = math.abs(newAngles.yaw - self.oldAngles.yaw)
        self.oldAngles.pitch = math.abs(newAngles.pitch - self.oldAngles.pitch)
        self.oldAngles.roll = math.abs(newAngles.roll - self.oldAngles.roll)

    else
        self.oldAngles = newAngles
    end
end

function FuncTrain:SetOldAnglesDiff(newAngles)

    if self.oldAnglesDiff then
        self.oldAnglesDiff.yaw = math.abs(newAngles.yaw - self.oldAngles.yaw)
        self.oldAnglesDiff.pitch = math.abs(newAngles.pitch - self.oldAngles.pitch)
        self.oldAnglesDiff.roll = math.abs(newAngles.roll - self.oldAngles.roll)
    else
        self.oldAnglesDiff = Angles(0,0,0)
    end
end


function FuncTrain:GetDeltaAngles()
    if not self.oldAnglesDiff then
        local angles = Angles()
        angles.pitch = 0
        angles.yaw = 0
        angles.roll = 0
        self.oldAnglesDiff = angles   
    end
    return self.oldAnglesDiff   
end

function FuncTrain:GetSpeed()
    return self.moveSpeed or FuncTrain.kMoveSpeed
end

function FuncTrain:GetIsFlying()
    return true
end

function FuncTrain:GetHoverHeight()
    return FuncTrain.kHoverHeight
end

//**********************************
// Viewing things
//**********************************

function FuncTrain:GetViewOffset()
    return self:GetCoords().yAxis * 1.2
end

function FuncTrain:GetEyePos()
    return self:GetOrigin() + self:GetViewOffset()
end

function FuncTrain:GetViewAngles()
    local viewCoords = Coords.GetLookIn(self:GetEyePos(), self:GetOrigin())
    //local viewAngles = Angles()
    //return viewAngles:BuildFromCoords(viewCoords) or self:GetAngles().yaw
    local angles = Angles(0,0,0)
    angles.yaw = GetYawFromVector(viewCoords.zAxis)
    angles.pitch = GetPitchFromVector(viewCoords.xAxis)
    return angles
end


//**********************************
// Sever and Client only functions
//**********************************

if Server then
  
    function FuncTrain:UpdatePosition(deltaTime)
       
        local nextWaypoint = Shared.GetEntity(self.nextWaypointId)

        if nextWaypoint then
            local hoverWaypont = GetHoverAt(self, nextWaypoint:GetOrigin())
            //if self:IsTargetReached(hoverWaypont, kAIMoveOrderCompleteDistance) then            
              //  self:GetNextWaypoint()
            //else
                local target = self:MoveToTarget(PhysicsMask.AIMovement, hoverWaypont, self:GetSpeed(), deltaTime)
                if target then
                    self:GetNextWaypoint()
                end
            //end          

        else
            self:GetNextWaypoint()
        end            
    end 
    
    
    function FuncTrain:GetNextWaypoint()
    
        local nearestWaypoint = nil
        local nearestWaypointDistance = 0
        
        local nearestWaypointForward = nil
        local nearestWaypointForwardDistance = 0

        // search all waypoints and search the nearest                
        for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do   
            
            // move to a new waypoint, don't take the acutally one
            if  self.nextWaypointId ~= ent:GetId() then
                
                local dist = (ent:GetOrigin() - self:GetOrigin()):GetLength()
                
                local direction =  GetNormalizedVector(ent:GetOrigin() - self:GetOrigin())
                local yawDiffRadians = GetAnglesDifference(GetYawFromVector(direction) , self:GetAngles().yaw)
                //local yawDegrees = DegreesTo360(math.deg(yawDiffRadians)) 
                
                local angles = self:GetAngles()
                local currentYaw = self:NormalizeYaw(angles.yaw)
                local desiredYaw = self:NormalizeYaw(GetYawFromVector(direction))
                local turnAmount,remainingYaw = self:CalcTurnAmount(desiredYaw, currentYaw, self:GetTurnSpeed(), Shared.GetTime())
                local yawDegrees = DegreesTo360(math.deg(desiredYaw-currentYaw))
            
                if (yawDegrees >= 20) and (yawDegrees <= 160) then
                    if (dist < nearestWaypointForwardDistance) or (nearestWaypointForwardDistance == 0) then
                        nearestWaypointForward = ent
                        nearestWaypointForwardDistance = dist
                    end
                else                                    
                    if (dist < nearestWaypointDistance) or (nearestWaypointDistance == 0) then
                        nearestWaypoint = ent
                        nearestWaypointDistance = dist
                    end
                end   
                
            end
                
        end
        
        if nearestWaypointForward ~= nil then
            self.nextWaypointId = nearestWaypointForward:GetId()
        elseif nearestWaypoint ~= nil then
            self.nextWaypointId = nearestWaypoint:GetId()
        end
        
    end
    
    function FuncTrain:MovePlayersInTrigger()
        for _, entity in ipairs(self:GetEntitiesInTrigger()) do 
            if self.driving then
                // update the position and the angles
                // change position when the train is driging
                local newOrigin = entity:GetOrigin()
                local selfDeltaAngles = self:GetDeltaAngles()
                local degrees = DegreesTo360(math.deg(selfDeltaAngles.yaw))                
                local direction = newOrigin - self:GetOrigin()
                local trainOrigin = self:GetOrigin()
                
                // change the position if he's also rotating                
                //direction.z = (direction.z * math.sin(degrees) - direction.x * math.cos(degrees))
                //direction.x = (direction.x * math.sin(degrees) + direction.z * math.cos(degrees))
                
                //direction.z = trainOrigin.z + (o.x - trainOrigin.x) * math.cos(degrees) - (o.y - trainOrigin.y) * math.sin(degrees);
                //direction.x = trainOrigin.x + (o.z - trainOrigin.z) * math.sin(degrees) + (o.x - trainOrigin.x) * math.cos(degrees);
                

                //newOrigin.z = trainOrigin.z + (math.cos(degrees) * (newOrigin.z - trainOrigin.z) -  math.sin(degrees) * (newOrigin.x - trainOrigin.x))                
                //newOrigin.x = trainOrigin.x + (math.sin(degrees) * (newOrigin.z - trainOrigin.z) +  math.cos(degrees) * (newOrigin.x - trainOrigin.x))

                                
                // change the viewAngles
                local newAngles = Angles()
                local entityAngles = entity:GetAngles()
                newAngles.pitch = entityAngles.pitch +  selfDeltaAngles.pitch             
                newAngles.roll = entityAngles.roll +  selfDeltaAngles.roll
                newAngles.yaw = entityAngles.yaw +  selfDeltaAngles.yaw


                entity:SetOrigin(newOrigin  + self:GetMovementVector())
                //entity:SetViewAngles(newAngles)
                //entity:SetAngles(newAngles)
            end
        end
    end

    // move the position of the trigger box
    function FuncTrain:MoveTrigger()

        // set a box so it can be triggered
        local extents = self:GetExtents()
        extents = 20 * extents
        self:SetBox(extents)
    
    end
    
end


if Client then
    // small UI for driving
    function FuncTrain:ShowDrivingGui()
    
    end
        
    function FuncTrain:DestroyDrivingGui()
    
    end
end

Shared.LinkClassToMap("FuncTrain", FuncTrain.kMapName, networkVars)