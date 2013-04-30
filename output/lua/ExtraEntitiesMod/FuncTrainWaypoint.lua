//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// FuncTrainWaypoint.lua
// Entity for mappers to create drivable train waypoints

class 'FuncTrainWaypoint' (ScriptActor)

FuncTrainWaypoint.kMapName = "func_train_waypoint"

local networkVars =
{
}

function FuncTrainWaypoint:OnCreate() 

    ScriptActor.OnCreate(self)
    self:SetUpdates(false)
      
end

function FuncTrainWaypoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    
end


function FuncTrainWaypoint:OnUpdate(deltaTime)
end


Shared.LinkClassToMap("FuncTrainWaypoint", FuncTrainWaypoint.kMapName, networkVars)