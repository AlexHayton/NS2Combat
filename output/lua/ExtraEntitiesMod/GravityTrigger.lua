//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// GravityTrigger.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'GravityTrigger' (Trigger)

GravityTrigger.kMapName = "gravity_trigger"

local networkVars =
{
    gravityForce = "integer (-100 to 100)",
    enabled = "boolean",
}

AddMixinNetworkVars(LogicMixin, networkVars)


function GravityTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
end

function GravityTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)   
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
    
end

function GravityTrigger:GetGravityOverride(gravity) 
    if self.enabled then
        return self.gravityForce
    else
        return gravity
    end
end

function GravityTrigger:OnUpdate(deltaTime)
end

function GravityTrigger:OnTriggerEntered(enterEnt, triggerEnt) 
    if self.enabled then
        enterEnt.gravityTrigger = self:GetId()
        
        enterEnt.timeOfLastJump = Shared.GetTime()
        enterEnt.onGroundNeedsUpdate = true
        enterEnt.jumping = true
    end
end
    
function GravityTrigger:OnTriggerExited(exitEnt, triggerEnt)
    if self.enabled then
        exitEnt.gravityTrigger = 0
        
        exitEnt.onGroundNeedsUpdate = true
        exitEnt.jumping = false
    end
end


function GravityTrigger:OnLogicTrigger()
	self:OnTriggerAction()
end


Shared.LinkClassToMap("GravityTrigger", GravityTrigger.kMapName, networkVars)