//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/Door.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

class 'FuncDoor' (Door)

FuncDoor.kMapName = "func_door"

FuncDoor.kState = enum( {'Open', 'Locked'} )
FuncDoor.kStateSound = { [FuncDoor.kState.Open] = FuncDoor.kOpenSound, 
                          [FuncDoor.kState.Locked] = FuncDoor.kLockSound,
                        }

local kModelNameDefault = PrecacheAsset("models/misc/door/door.model")
local kModelNameClean = PrecacheAsset("models/misc/door/door_clean.model")
local kModelNameDestroyed = PrecacheAsset("models/misc/door/door_destroyed.model")

local kDoorAnimationGraph = PrecacheAsset("models/misc/door/door.animation_graph")

local networkVars =
{
    scale = "vector",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)

function FuncDoor:OnCreate()

    Door.OnCreate(self)
    InitMixin(self, ObstacleMixin)

end

local function InitModel(self)

    local modelName = kModelNameDefault
    if self.clean then
        modelName = kModelNameClean
    end
    
    self:SetModel(modelName, kDoorAnimationGraph)
       
end

function FuncDoor:OnInitialized()
    // Don't call Door OnInit, we want to create or own Model
    ScriptActor.OnInitialized(self) 
    InitModel(self)
    
    InitMixin(self, ScaledModelMixin)
	self:SetScaledModel(self.model)
    
    if self.startsOpen then
        self:SetState(Door.kState.Open)
    else
        self:SetState(Door.kState.Welded)
    end
    
    if Server then
        InitMixin(self, LogicMixin) 
        self:SetUpdates(true)
        if self.stayOpen then  
            self.timedCallbacks = {}
        end
        // the ObsticleMixin includes the object automatically to the mesh
        self.AddedToMesh = true
        self:SetPhysicsType(PhysicsType.Kinematic)
        self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    end

end

function FuncDoor:OnUpdate(deltaTime) 
    local state = self:GetState()
    if state and (state == Door.kState.Welded or state == Door.kState.Locked) then
        if not self.AddedToMesh then
            self:AddToMesh()
            self.AddedToMesh = true
        end
    else
        if self.AddedToMesh then
            for obstacle, v in pairs(gAllObstacles) do
                if obstacle == self then
                    obstacle:RemoveFromMesh()
                end
            end                
            self.AddedToMesh = false
        end
    end
end

function FuncDoor:Reset() 
    Door.Reset(self)
    
    if self.startsOpen then
        self:SetState(Door.kState.Open)
    else
        self:SetState(Door.kState.Welded)
    end
  
    InitModel(self)
end

function FuncDoor:OnUse(player, elapsedTime)
end

function FuncDoor:OnWeldOverride(doer, elapsedTime)
end

function FuncDoor:GetWeldPercentageOverride()
end

function FuncDoor:GetCanBeWeldedOverride()
    return false
end

function FuncDoor:GetCanTakeDamageOverride()
    return false
end

function FuncDoor:OnLogicTrigger(player)

    local state = self:GetState()
    if state ~= Door.kState.Welded then
        self:SetState(Door.kState.Welded)
    else
        self:SetState(Door.kState.Open)
    end
    
end

// only way to scale the model
function FuncDoor:OnAdjustModelCoords(modelCoords)

    local coords = modelCoords
    coords.xAxis = coords.xAxis * self.scale.x
    coords.yAxis = coords.yAxis * self.scale.y
    coords.zAxis = coords.zAxis * self.scale.z
      
    return coords
    
end

Shared.LinkClassToMap("FuncDoor", FuncDoor.kMapName, networkVars)