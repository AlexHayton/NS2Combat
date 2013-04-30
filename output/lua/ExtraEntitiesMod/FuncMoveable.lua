//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// FuncMoveable.lua
// Base entity for FuncMoveable things

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
// needed for the MoveToTarget Command
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/ExtraEntitiesMod/TrainMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

class 'FuncMoveable' (ScriptActor)

FuncMoveable.kMapName = "func_moveable"
FuncMoveable.kMaxOpenDistance = 6
local kUpdateAutoOpenRate = 0.3
local kUpdateAutoCloseRate = 4

local networkVars =
{
    scale = "vector",
    model = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TrainMixin, networkVars)


local function UpdateAutoOpen(self, timePassed)

    // If any players are around, have door open if possible, otherwise close it
    
    if self.enabled then
    
        local desiredOpenState = false        
        local entities = Shared.GetEntitiesWithTagInRange("Door", self:GetOrigin(), FuncMoveable.kMaxOpenDistance)
        for index = 1, #entities do
            
            local entity = entities[index]          
            if (not HasMixin(entity, "Live") or entity:GetIsAlive()) and entity:GetIsVisible() then
                desiredOpenState = true
                break            
            end            
           
        end
	        
        if desiredOpenState then 
            if not self.driving and not self:IsOpen() then
                self:OnLogicTrigger()
            end
        else           
            if self:IsOpen() then
                if not self.autoCloseTime then
                    self.autoCloseTime = Shared.GetTime() + kUpdateAutoCloseRate
                end
                if Shared.GetTime() >= self.autoCloseTime then
                    self:OnLogicTrigger()
                    self.autoCloseTime = nil
                end
            else
                self.autoCloseTime = nil
            end
        end
        
    end
    
    return true

end

function FuncMoveable:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, TrainMixin)
    
end

function FuncMoveable:OnInitialized()

    ScriptActor.OnInitialized(self)  
    InitMixin(self, ScaledModelMixin)
	self:SetScaledModel(self.model)
	
    if Server then
        InitMixin(self, LogicMixin)  
        if self.isDoor then
            self:AddTimedCallback(UpdateAutoOpen, kUpdateAutoOpenRate)            
        end
    end
    
end

function FuncMoveable:Reset()
    ScriptActor.Reset(self)
end

function FuncMoveable:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false   
end

// called from OnUpdate when self.driving = true
function FuncMoveable:UpdatePosition(deltaTime)
   
    if self.driving then
        if not self.nextWaypoint then
            self.nextWaypoint = self:GetNextWaypoint()
        end        
        if self.nextWaypoint then
            self:CheckBlocking()
            local done = self:TrainMoveToTarget(PhysicsMask.All, self.nextWaypoint, self:GetSpeed(), deltaTime, false)
            if done then
                //Print("New Position: " .. self:GetOrigin())
                self.driving = false
                self.nextWaypoint = nil
            end
        else
            Print("Error: No waypoint found!")
        end
    end
            
end 


function FuncMoveable:CheckBlocking()
    // kill entities that blocks us
    //local startPoint = self:GetOrigin()    
    local coords = self:GetCoords()
    local middle = coords.origin + (coords.yAxis / 2)
    
    local endPoint = self.nextWaypoint or self:GetNextWaypoint() 
    local extents = self.scale or self:GetExtents()  
    //local trace = self.physicsModel:Trace(CollisionRep.Move, CollisionRep.Move, PhysicsMask.Movement)  
    local trace = Shared.TraceRay(middle, endPoint, CollisionRep.Move, PhysicsMask.All, EntityFilterOne(self))
    if trace.entity then
        if HasMixin(trace.entity, "Live") then
            trace.entity:Kill()
        end
    end
    


end


function FuncMoveable:IsOpen()
    return self:GetOrigin() ~= self.savedOrigin
end

/* will create a path so the train will know the next points
case self.direction:
"Up" value="0"
"Down" value="1"
"Left" value="2"
"Right" value="3"
*/
function FuncMoveable:CreatePath(onUpdate)

    local extents = self.scale or Vector(1,1,1)
    if self.model then
        _, extents = Shared.GetModel(Shared.GetModelIndex(self.model)):GetExtents(self.boneCoords)        
    end

    local origin = self:GetOrigin()
    local wayPointOrigin = nil
    local moveVector = Vector(0,0,0)
    local directionVector = AnglesToVector(self)
    
    if self.direction == 0 then
        moveVector.y = extents.y
    elseif  self.direction == 1 then 
        moveVector.y = -extents.y
    elseif  self.direction == 2 then
        moveVector.x = directionVector.z * -extents.x 
        moveVector.z = directionVector.x * extents.x 
        //directionVector 
    elseif  self.direction == 3 then
        moveVector.x = directionVector.z * extents.x 
        moveVector.z = directionVector.x * -extents.x     
    elseif self.direction == 4 then
        for _, ent in ientitylist(Shared.GetEntitiesWithClassname("FuncTrainWaypoint")) do 
            if ent.trainName == self.name then
                wayPointOrigin = ent:GetOrigin()
                break
            end   
        end
    end
    
    self.waypoint = wayPointOrigin or (origin + moveVector)
    self.savedOrigin = origin
    
    if self.startsOpened and not self.isDoor then  
        self:SetOrigin(self.waypoint)  
        self.waypoint = self.savedOrigin
        self.savedOrigin = self:GetOrigin()
    end
    
end

function FuncMoveable:GetNextWaypoint()
    if self:GetOrigin() == self.waypoint then
        return self.savedOrigin
    else
        return self.waypoint
    end
end

function FuncMoveable:GetPushPlayers()
    return false
end

function FuncMoveable:GetSpeed()
    return self.moveSpeed or 40
end

function FuncMoveable:GetIsFlying()
    return true
end

function FuncMoveable:GetRotationEnabled()
    return false
end

function FuncMoveable:OnLogicTrigger(player)
    self.driving = true
end

Shared.LinkClassToMap("FuncMoveable", FuncMoveable.kMapName, networkVars)