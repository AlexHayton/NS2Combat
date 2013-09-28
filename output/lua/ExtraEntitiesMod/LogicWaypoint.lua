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

function LogicWaypoint:OnOrderComplete(player)
    self:TriggerOutputs(player)
end

function LogicWaypoint:OnLogicTrigger(player)  
  
    if player then  
        local orderId = kTechId.Move  
        local param = self:GetId()
        local origin = self:GetOrigin()
        local target = nil
        
        if self.targetName and self.targetName ~= "" then
		    target = self:GetLogicEntityWithName(self.targetName)
		    if target and self:GetIsTargetCompleted(target, player) then
		        self:TriggerOutputs(player)
		        // if it has still no order, then do just nothing
		        if player:GetCurrentOrder() then
		            return
		        end
		    end
        end
        
        if self.type == 1 then
            // search near targets as paramater 
            // if found no targets, just move there
            
            if not target then
				local targets = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), 2)
                if targets and #targets > 0 then
				    target = targets[1] 
                end
            end
			
            if target then
                orderId = kTechId.Attack
                param = target:GetId()
                origin = target:GetOrigin()
                target.wayPointEntity = self:GetId()
            end
            
        elseif self.type == 2 then

            if not target then
                // search near weldable things as paramater 
                local weldables = GetEntitiesWithinRange("LogicWeldable", self:GetOrigin(), 2)            
                if weldables and #weldables > 0 then
                    target = weldables[1]
                end    
            end    
            
            if target then
                orderId = kTechId.Weld
                param = target:GetId()
                origin = target:GetOrigin()
                target.wayPointEntity = self:GetId()
            end                

        elseif self.type == 3 then
            orderId = kTechId.Build
        end
        
        player.mapWaypoint = param
        player.mapWaypointType = orderId       
        
        local orderId = player:GiveOrder(orderId, param, origin, nil, true, true)         

    end
    
end


function LogicWaypoint:GetIsTargetCompleted(target, player)
    return (self.type == 1 and not target:GetIsAlive()) or (self.type == 2 and target:GetCanBeWelded(player))
end


Shared.LinkClassToMap("LogicWaypoint", LogicWaypoint.kMapName, networkVars)