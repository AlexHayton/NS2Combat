//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// LogicWaypoint.lua
// Base entity for LogicWaypoint things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/OrdersMixin.lua")

class 'LogicWaypoint' (Entity)

LogicWaypoint.kMapName = "logic_waypoint"

local networkVars = 
{
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)

function LogicWaypoint:OnCreate()
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
end

function LogicWaypoint:OnInitialized()    
    if Server then
        InitMixin(self, LogicMixin)
    end
end

function LogicWaypoint:GetExtents()
    return Vector(1,1,1)
end

function LogicWaypoint:GetOutputNames()
    return {self.output1}
end

function LogicWaypoint:OnOrderComplete(player)
    self:TriggerOutputs(player)
end

function LogicWaypoint:OnLogicTrigger(player)  
  
    if player then  
        local orderId = kTechId.Move  
        local param = self:GetId()
        
        if self.type == 1 then
            // search near targets as paramater 
            // if found no targets, just move there
            local targets = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), 1)        
            if targets and #targets > 0 then
                orderId = kTechId.Attack
                param = targets[1]:GetId()
            end
        elseif self.type == 2 then
            orderId = kTechId.Weld
            // search near weldable things as paramater 
            local weldables = GetEntitiesWithinRange("LogicWeldable", self:GetOrigin(), 1)            
            if weldables and #weldables > 0 then
                param = weldables[1]:GetId()
            end            
        elseif self.type == 3 then
            orderId = kTechId.Build
        end
        
        player.mapWaypoint = param
        local orderId = player:GiveOrder(orderId, param, self:GetOrigin(), nil, true, true)    

    end
    
end


Shared.LinkClassToMap("LogicWaypoint", LogicWaypoint.kMapName, networkVars)