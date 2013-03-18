//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")
Script.Load("lua/PathingMixin.lua")

TrainMixin = CreateMixin( TrainMixin )
TrainMixin.type = "Train"

local pi2 = math.pi * 2

kDefaultTurnSpeed = math.pi // 180 degrees per second
kDefaultMaxSpeedAngle = math.pi / 18 // 10 degrees
kDefaultNoSpeedAngle = math.pi / 4 // 45 degrees

TrainMixin.expectedMixins =
{
    Pathing = "Needed for calls to MoveToTarget().",
}

TrainMixin.expectedCallbacks =
{
    GetPushPlayers = "Only train and elevators should push players",
    CreatePath = "Creates the path the train will move on, called by PathingUtility_Modded",
    GetRotationEnabled = "Enables rotation of the moveable",
}



TrainMixin.networkVars =  
{
    driving = "boolean",
    waiting = "boolean",
	savedOrigin = "vector",
}


local function TransformPlayerCoordsForTrain(player, srcCoords, dstCoords)

    local viewCoords = player:GetViewCoords()
    
    // If we're going through the backside of the phase gate, orient us
    // so we go out of the front side of the other gate.
    if Math.DotProduct(viewCoords.zAxis, srcCoords.zAxis) < 0 then
    
        srcCoords.zAxis = -srcCoords.zAxis
        srcCoords.xAxis = -srcCoords.xAxis
        
    end
    
    // Redirect player velocity relative to gates
    local invSrcCoords = srcCoords:GetInverse()   
    local viewCoords = dstCoords * (invSrcCoords * viewCoords)
    local viewAngles = Angles()
    viewAngles:BuildFromCoords(viewCoords)
    
    player:SetBaseViewAngles(viewAngles)       
    player:SetViewAngles(Angles(0, 0, 0))
    player:SetAngles(Angles(0, viewAngles.yaw, 0))
    
end


function TrainMixin:__initmixin() 
    self.driving = false
    self.waiting = false
end


function TrainMixin:OnInitialized()

    // Save origin, angles, etc. so we can restore on reset
    self.savedOrigin = Vector(self:GetOrigin())
    self.savedAngles = Angles(self:GetAngles())
        
    if Server then
        // set a box so it can be triggered, use the trigger scale from the mapEditor
        if self:GetPushPlayers() then
            self:MoveTrigger()        
        end        
    end
    
end

function TrainMixin:OnUpdate(deltaTime)   
    
    if Server then 
        if self.driving then
            self:UpdatePosition(deltaTime)
            self:MoveTrigger()
            if not self.waiting  and self:GetPushPlayers() then
                self:SetOldOrigin(self:GetOrigin())
                self:SetOldAngles(self:GetAngles())
                self:MovePlayersInTrigger(deltaTime)

            end
        end  
    end
    
end



function TrainMixin:Reset()

    // Restore original origin, angles, etc. as it could have been rag-dolled
    self:SetOrigin(self.savedOrigin)
    self:SetAngles(self.savedAngles)
    
end

function TrainMixin:SetOldOrigin(origin)
    // locally save the old origin   
    //Entity.SetOrigin(self, origin)
    if not self.oldOrigin then
        self.oldOrigin = self:GetOrigin()  
    end

    local movementVector = origin - self.oldOrigin
    if (movementVector.x + movementVector.y + movementVector.z) ~= 0 then
        self:SetMovementVector(movementVector)  
    end   
    self.oldOrigin = self:GetOrigin()  
end


// set and get Velocity to update the players movement, too
function TrainMixin:SetMovementVector(newVector)
    self.movementVector = newVector   
end

function TrainMixin:GetMovementVector()
    return self.movementVector or Vector(0,0,0)     
end

function TrainMixin:SetOldAngles(newAngles)

    if self.oldAngles then
        self:SetOldAnglesDiff(newAngles)
        self.oldAngles.yaw = newAngles.yaw
        self.oldAngles.pitch = newAngles.pitch
        self.oldAngles.roll = newAngles.roll

    else
        self.oldAngles = newAngles
    end
end

function TrainMixin:SetOldAnglesDiff(newAngles)

    if self.oldAnglesDiff then
        local newYaw = (newAngles.yaw - self.oldAngles.yaw)
        self.oldAnglesDiff.yaw = newYaw
        self.oldAnglesDiff.pitch = (newAngles.pitch - self.oldAngles.pitch)
        self.oldAnglesDiff.roll = (newAngles.roll - self.oldAngles.roll)        
        
    else
        self.oldAnglesDiff = Angles(0,0,0)
    end
end


function TrainMixin:GetDeltaAngles()
    if not self.oldAnglesDiff then
        local angles = Angles()
        angles.pitch = 0
        angles.yaw = 0
        angles.roll = 0
        self.oldAnglesDiff = angles   
    end
    return self.oldAnglesDiff   
end

function TrainMixin:MovePlayersInTrigger(deltaTime)
    for _, entity in ipairs(self:GetEntitiesInTrigger()) do 
        if self.driving then
            if not entity:GetIsJumping() then
                // change position when the train is driving
                local entOrigin = entity:GetOrigin()
                local trainOrigin = self:GetOrigin()
                local newOrigin = entOrigin
                
                local selfDeltaAngles = self:GetDeltaAngles()              
                local entityAngles = entity:GetAngles() 
                local degrees = selfDeltaAngles.yaw
                
                // 2d rotation , I don't think I need 3d here, will get the correct position after rotating the train
                newOrigin.z = trainOrigin.z + (math.cos(degrees) * (entOrigin.z - trainOrigin.z) -  math.sin(degrees) * (entOrigin.x - trainOrigin.x))                
                newOrigin.x = trainOrigin.x + (math.sin(degrees) * (entOrigin.z - trainOrigin.z) +  math.cos(degrees) * (entOrigin.x - trainOrigin.x))

                entityAngles.yaw = entityAngles.yaw + selfDeltaAngles.yaw
                local coords = Coords.GetLookIn(newOrigin, self:GetAngles():GetCoords().zAxis)
                //TransformPlayerCoordsForTrain(entity, entity:GetCoords(), coords)               
                entity:SetOrigin(newOrigin  + self:GetMovementVector())          
                    
            end
        end
    end
end

    
function TrainMixin:MoveTrigger()
    /*
    local scale = Vector(1,1,1)
    if self.scaleTrigger then
        scale = self.scaleTrigger
    // scale1 was the old name for this, dunno why but sometimes its still in there
    elseif self.scale1 then
         scale = self.scale1
    else
        scale = self:GetExtents()
    end
    self:SetBox(scale)
    self:SetTriggerCollisionEnabled(true)
    */
    
    // make it a bit bigger so were inside the trigger
    local coords = self:GetCoords()
    coords.yAxis = coords.yAxis  * 5
    
    if self.triggerModel then
        //Shared.DestroyCollisionObject(self.triggerModel)
        //self.triggerModel = nil
        self.triggerModel:SetCoords(coords)
        self.triggerModel:SetBoneCoords(coords, CoordsArray())
    else    
        if self.modelIndex then    

            self.triggerModel = Shared.CreatePhysicsModel(self.modelIndex, false, coords , self)
            
            if self.triggerModel ~= nil then
                self.triggerModel:SetTriggerEnabled(true)
                self.triggerModel:SetCollisionEnabled(false)
                self.triggerModel:SetEntity(self)         
            end

        end        
    end
    
end


function TrainMixin:OnTriggerEntered(enterEnt, triggerEnt)    
end

function TrainMixin:OnTriggerExited(exitEnt, triggerEnt)
    //DebugCircle(self:GetOrigin(), 2, Vector(1, 0, 0), 1, 1, 1, 1, 1)
end


//**********************************
// Driving things
//**********************************

// TODO:Accept
// 1. Generate Path
// 2. Move
function TrainMixin:TrainMoveToTarget(physicsGroupMask, endPoint, movespeed, time)

    // check if we'Ve already reached the point
    
    PROFILE("TrainMixin:MoveToTarget")
    if not self:CheckTrainTarget(endPoint) then
        return true
    end
   
    // save the cursor in case we need to slow down
    local origCursor = PathCursor():Clone(self.cursor)    
    
    self.cursor:Advance(movespeed, time)    
    local maxSpeed = moveSpeed 
    local rotate = self:GetRotationEnabled()
    maxSpeed = self:TrainSmoothTurn(time, self.cursor:GetDirection(), movespeed, rotate)

    // Don't move during repositioning
    if HasMixin(self, "Repositioning") and self:GetIsRepositioning() then
    
        maxSpeed = 0
        return false
        
    end
    
    if maxSpeed < movespeed then
        // use the copied cursor and discard the current cursor
        self.cursor = origCursor
        self.cursor:Advance(maxSpeed, time)
    
    end
    
    // update our position to the cursors position, after adjusting for ground or hover
    local newLocation = self.cursor:GetPosition()          
    self:SetOrigin(newLocation)
         
    // we are done if we have reached the last point in the path or we have a close-enough condition
    local done = self.cursor:TargetReached()

    if done then
        self.points = nil
        self.cursor = nil
    end
    return done
    
end

function TrainMixin:TrainSmoothTurn(time, direction, moveSpeed, rotate)
// TODO: make train not turnable (platform)
    assert(time)
    assert(direction)
    assert(moveSpeed)
    
    // smooth turning
    local angles = self:GetAngles()
    local currentYaw = self:NormalizeYaw(angles.yaw)
    local desiredYaw = self:NormalizeYaw(GetYawFromVector(direction))
    local turnAmount,remainingYaw = self:CalcTurnAmount(desiredYaw, currentYaw, self:GetTurnSpeed(), time)
    
    if rotate then
        angles.yaw = self:NormalizeYaw(currentYaw + turnAmount)
        self:SetAngles(angles)    
        // speed is maximum inside the maxSpeedAngle, and zero at noSpeedAngle, and vary constantly between them
        local maxSpeedAngle,minSpeedAngle = unpack(self:GetSpeedLimitAngles())
        moveSpeed = moveSpeed * self:CalcYawSpeedFraction(remainingYaw, maxSpeedAngle, minSpeedAngle)
        if self.SmoothTurnOverride then
            moveSpeed = self:SmoothTurnOverride(time, direction, moveSpeed)
        end
    end 
    // a turn limit may never limit the speed below 10% of speed, as speed zero would just stop us completly...
    return moveSpeed
    
end

//
// make sure we have a path to the target
// returns false if no path found.
//
function TrainMixin:CheckTrainTarget(endPoint)

    // if we don't have a cursor, or the targetPoint differs, create a new path
    if self.cursor == nil or (self.targetPoint - endPoint):GetLengthXZ() > 0.001 then

        self.targetPoint = endPoint
        self.points = {}
        table.insert(self.points, 1, self:GetOrigin())        
        table.insert(self.points, endPoint)  
        SmoothPathPoints( self.points, 0.5 , 6) 
        
        self.cursor = PathCursor():Init(self.points)
        
    end
    
    return true
    
end
