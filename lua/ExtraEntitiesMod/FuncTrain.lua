//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
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
Script.Load("lua/ExtraEntitiesMod/TrainMixin.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

class 'FuncTrain' (ScriptActor)

FuncTrain.kMapName = "func_train"
FuncTrain.kMoveSpeed = 15.0
FuncTrain.kHoverHeight = 0.8
FuncTrain.kDrivingState = enum( {'Stop', 'Forward1', 'Forward2', 'Forward3', 'Backwards'} )

local networkVars =
{    
    drivingState = "enum FuncTrain.kDrivingState",
    scale = "vector",
    model = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TrainMixin, networkVars)


function FuncTrain:OnCreate()
 
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, SignalEmitterMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, TrainMixin)
    
    self:SetUpdates(true)  
    
end

function FuncTrain:OnInitialized()

    ScriptActor.OnInitialized(self)
    InitMixin(self, TriggerMixin)
    InitMixin(self, ScaledModelMixin)
    
    if Server then
        InitMixin(self, LogicMixin)
    end

    if self.autoStart then
        self.driving = true
        self.kDrivingState = FuncTrain.kDrivingState.Forward1
    else
        self.driving = false
        self.kDrivingState = FuncTrain.kDrivingState.Stop
    end
   
end

function FuncTrain:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = true
end

function FuncTrain:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

    if Server then   
        self:ChangeDrivingStatus()
    elseif Client then
        //player:OnTrainUse(self) 
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

function FuncTrain:GetSpeed()
    return self.moveSpeed or FuncTrain.kMoveSpeed
end

function FuncTrain:GetIsFlying()
    return true
end

function FuncTrain:GetHoverHeight()
    return FuncTrain.kHoverHeight
end

function FuncTrain:GetPushPlayers()
    return true
end

function FuncTrain:GetRotationEnabled()
    return true
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

// will create a path so the train will know the next points
function FuncTrain:CreatePath(onUpdate)
    local origin = self:GetOrigin()
    local tempList = {}
    self.waypointList = {}
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do 
        // only search the waypoints for that train
        if ent.trainName == self.name then
            if ent.number > 0 then
                self.waypointList[ent.number] = {}
                self.waypointList[ent.number].origin = ent:GetOrigin()
                self.waypointList[ent.number].delay = ent.waitDelay
            end
        end        
    end
    
    // then copy the wayPointList into a new List so its 1-n
    
    for i, wayPoint in ipairs(self.waypointList) do
        table.insert(tempList, wayPoint)
    end
    
    // create a smooth path
    //self.waypointList = self:CreateSmoothPath(tempList, 1)      
    self.waypointList = tempList  

    tempList = nil
    
    if onUpdate then
        if (#self.waypointList  == 0) then
            self:SetUpdates(false)
            Print("Error: Train " .. self.name .. " found no waypoints!")
        end
    end
end

function FuncTrain:OnLogicTrigger()
    self:ChangeDrivingStatus()
end

//**********************************
// Sever and Client only functions
//**********************************

if Server then
  
    function FuncTrain:UpdatePosition(deltaTime)
       
        if self.nextWaypoint then
            // check if the waypoint got a delay
                local done = self:TrainMoveToTarget(PhysicsMask.All, self.nextWaypoint, self:GetSpeed(), deltaTime)                
                //if self:IsTargetReached(hoverWaypont, kAIMoveOrderCompleteDistance) then
                if done then
                    self.nextWaypoint = nil
                    self:GetNextWaypoint()
                end
            //end          

        else
            self:GetNextWaypoint()
        end            
    end 
    
    
    function FuncTrain:GetNextWaypoint()

        if #self.waypointList > 0 then
        
            if not self.nextWaypointNr then
                self.nextWaypointNr = 1
                self.nextWaypoint = self.waypointList[self.nextWaypointNr].origin               
            else
                // check if the waypoint got a delay
                local delay = self.waypointList[self.nextWaypointNr].delay 
                local time = Shared.GetTime()
    
                if not self.nextWaypointCheck then
                    self.nextWaypointCheck =  time + delay
                end
                
                if (self.waypointList[self.nextWaypointNr].delay == 0) or time >= self.nextWaypointCheck then 
                    self.waiting = false
                    self.nextWaypointNr = self.nextWaypointNr + 1
                    // TODO: Dont start at one if last Waypoint
                    if self.nextWaypointNr > #self.waypointList then
                        // end of track
                        //self.driving = false
                        //TODO : what happens then?
                        self.nextWaypointNr = 1
                    end
                    
                    self.nextWaypoint = self.waypointList[self.nextWaypointNr].origin
                    self.nextWaypointCheck = nil 
                else
                    self.waiting = true
                end 
              
            end   

        else
            Print("Error: Train " .. self.name .. " found no waypoints!")
            self.driving = false
        end
    end
    
    function FuncTrain:OnTriggerEntered(entity, triggerEnt)
    end    

    function FuncTrain:OnTriggerExited(entity, triggerEnt)
        // destroy the GUI and let the player mov again
    end       
end



Shared.LinkClassToMap("FuncTrain", FuncTrain.kMapName, networkVars)