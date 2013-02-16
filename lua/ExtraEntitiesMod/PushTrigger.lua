//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// PushTrigger.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'PushTrigger' (Trigger)

PushTrigger.kMapName = "push_trigger"

local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

local function PushEntity(self, entity)
    
    if self.enabled then
        local force = self.pushForce
        if self.pushDirection then      
            
            // get him in the air a bit
            if entity:GetIsOnGround() then
                local extents = GetExtents(entity:GetTechId())            
                if GetHasRoomForCapsule(extents, entity:GetOrigin() + Vector(0, extents.y + 0.2, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterTwo(self, entity)) then                
                    entity:SetOrigin(entity:GetOrigin() + Vector(0,0.2,0)) 
                end
                entity.jumping = true                 
            end 
            
            entity.pushTime = -1
            
            velocity = self.pushDirection * force 
            entity:SetVelocity(velocity)

        end 
    end
    
end

local function PushAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        PushEntity(self, entity)
    end
    
end

function PushTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
end

function PushTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)   
        self.pushDirection = AnglesToVector(self)
        self:SetUpdates(true)  
    end
    self:SetTriggerCollisionEnabled(true) 
    
end

function PushTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         PushEntity(self, enterEnt)
    end
    
end


//Addtimedcallback had not worked, so lets search it this way
function PushTrigger:OnUpdate(deltaTime)

    if self.enabled then
        PushAllInTrigger(self)
    end
    
end


function PushTrigger:OnLogicTrigger()
    if self.enabled then
        self.enabled = false
    else
        self.enabled = true
    end
end


Shared.LinkClassToMap("PushTrigger", PushTrigger.kMapName, networkVars)