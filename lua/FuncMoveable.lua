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
    propScale = "vector",
    test = "resource",
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
    
    if Server then
        self.propScale = self.scale
    end
  
    if self.model then
        Shared.PrecacheModel(self.model)
        self.test = Shared.GetModelIndex(self.model)
    end 
   
    CreateEemProp(self)
    /*
    if self.model ~= nil then    
        Shared.PrecacheModel(self.model)
        self:SetModel(self.model) 
        
        local coords = self:GetAngles():GetCoords(self:GetOrigin())
        coords.xAxis = coords.xAxis * self.scale.x
        coords.yAxis = coords.yAxis * self.scale.y
        coords.zAxis = coords.zAxis * self.scale.z
        self:SetCoords(coords)   
    end
    */
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
        local done = self:TrainMoveToTarget(PhysicsMask.All, self.nextWaypoint, self:GetSpeed(), deltaTime, false)
        if done then
            self.driving = false
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
            Print("new position")
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