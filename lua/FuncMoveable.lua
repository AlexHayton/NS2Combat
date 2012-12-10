//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// FuncMoveable.lua
// Base entity for FuncMoveable things

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/LogicMixin.lua")
// needed for the MoveToTarget Command
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/TrainMixin.lua")



class 'FuncMoveable' (ScriptActor)

FuncMoveable.kMapName = "func_moveable"


local networkVars =
{
    scale = "vector",
    model = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TrainMixin, networkVars)


function FuncMoveable:OnCreate()
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, TrainMixin)
end

function FuncMoveable:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    if self.model then
        Shared.PrecacheModel(self.model)
    end 
    
    CreateEemProp(self)

    if Server then
        InitMixin(self, LogicMixin) 
    end
    
end

function FuncMoveable:Reset()
    ScriptActor.Reset(self)
end

// called from OnUpdate when self.driving = true
function FuncMoveable:UpdatePosition(deltaTime)
   
    if self.driving and self.nextWaypoint then
        self:CheckBlocking()
        local done = self:TrainMoveToTarget(PhysicsMask.All, self.nextWaypoint, self:GetSpeed(), deltaTime, false)
        if done then
            self.driving = false
        end
    end
            
end 


function FuncMoveable:CheckBlocking()
    // kill entities that blocks us
    //local startPoint = self:GetOrigin()    
    local coords = self:GetCoords()
    local middle = coords.origin + (coords.yAxis / 2)
    
    local endPoint = self.nextWaypoint 
    local extents = self.scale or self:GetExtents()    
    local trace = Shared.TraceRay(middle, endPoint, CollisionRep.Move, PhysicsMask.All, EntityFilterOne(self))
    if trace.entity then
        if HasMixin(trace.entity, "Live") then
            trace.entity:Kill()
        end
    end

end


/* will create a path so the train will know the next points
case self.direction:
"Up" value="0"
"Down" value="1"
"Left" value="2"
"Right" value="3"
*/
function FuncMoveable:CreatePath(onUpdate)

    local extents = Vector(1,1,1)
    if self.model then
        _, extents = Shared.GetModel(Shared.GetModelIndex(self.model)):GetExtents(self.boneCoords)        
    end
    if self.propScale then
        extents.x = extents.x * self.propScale.x
        extents.y = extents.y * self.propScale.y
        extents.z = extents.z * self.propScale.z
    end
    local origin = self:GetOrigin()
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
    end
    
    self.nextWaypoint = origin + moveVector
    
    if self.startsOpened then  
        self:SetOrigin(self.nextWaypoint)  
        self.nextWaypoint = self.savedOrigin
        self.savedOrigin = self:GetOrigin()
    end
    
end


function FuncMoveable:GetPushPlayers()
    return false
end

function FuncMoveable:GetSpeed()
    return 40
end

function FuncMoveable:GetIsFlying()
    return true
end

function FuncMoveable:OnLogicTrigger()
    self.driving = true
end

function FuncMoveable:OnUpdateRender()
    PROFILE("FuncMoveable:OnUpdateRender")    

    if self.viewModel then
        local origin = self:GetOrigin()
        if not self.lastPosition then
            self.lastPosition = origin 
        end
        
        if self.lastPosition ~= origin  then
            local viewModel =  self.viewModel[1]
            local physicsModel =  self.viewModel[2]
            local viewCoords = viewModel:GetCoords()
            
            viewCoords.origin = self:GetCoords().origin
            viewModel:SetCoords(viewCoords)
            physicsModel:SetBoneCoords(viewCoords, self.boneCoords)
            self.lastPosition = origin
        end
    end

end


Shared.LinkClassToMap("FuncMoveable", FuncMoveable.kMapName, networkVars)