//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________


// tell the LogicWaypoint entity that the order is done
local originalOrdersMixinCompletedCurrentOrder = OrdersMixin.CompletedCurrentOrder
function OrdersMixin:CompletedCurrentOrder()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder then    
        local orderTarget = Shared.GetEntity(currentOrder:GetParam())
        // call original function here, so the old waypoint is gonna be destroyed
        originalOrdersMixinCompletedCurrentOrder(self)
        if orderTarget then
            local entity = nil
            if (orderTarget.wayPointEntity) then
                entity = Shared.GetEntity(orderTarget.wayPointEntity)
                if entity then
                    orderTarget = entity
                end
            end
            if orderTarget:isa("LogicWaypoint") and orderTarget.OnOrderComplete then
                orderTarget:OnOrderComplete(self)           
            end
        end
    end 
end
