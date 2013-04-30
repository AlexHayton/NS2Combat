//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________


// cause exo, lerk etc have their own AdjustForce function need to call this
local originalBaseMoveMixinGetGravityForce = BaseMoveMixin.GetGravityForce
function BaseMoveMixin:GetGravityForce(input)

    local gravity = originalBaseMoveMixinGetGravityForce(self, input)
    gravity = self:AdjustGravityForceOverride(gravity)
    
    return gravity
    
end