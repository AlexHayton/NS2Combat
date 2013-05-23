//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// modifed from the original target.lua created by  Max McGuire 

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'LogicTarget' (ScriptActor)

LogicTarget.kMapName = "logic_target"

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function LogicTarget:OnCreate()
    ScriptActor.OnCreate(self)
        
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
end

function LogicTarget:OnInitialized()

    ScriptActor.OnInitialized(self)

    if(self.model ~= nil) then
        Shared.PrecacheModel(self.model)
        self:SetModel( self.model )
    end

    // Team number set by ScriptActor:OnLoad

    self.health = tonumber(self.health)    
    self.initialHealth = self.health

    if(self.deathSoundName ~= nil) then
        Shared.PrecacheSound(self.deathSoundName)
    end
    
    if Server then
        InitMixin(self, LogicMixin)
    end

    self.popupAnimation = tostring(self.popupAnimation)
    if self.popupAnimation == "" or self.popupAnimation == nil then
        self.popupAnimation = "popup"
    end
    
    if(self.popupSoundName ~= nil) then
        Shared.PrecacheSound(self.popupSoundName)
    end

    self.popupRadius = tonumber(self.popupRadius)    
    self.popupDelay = tonumber(self.popupDelay)        
    self:SetPhysicsType(PhysicsType.Kinematic)    
        
end

function LogicTarget:GetCanIdle()
    return false
end

function LogicTarget:GetSendDeathMessageOverride()
    return false
end


if (Server) then
  
    function LogicTarget:OnKill(damage, attacker, doer, point, direction)
    
        // Create a rag doll.
        self:SetPhysicsType(PhysicsType.Dynamic)
        self:SetPhysicsGroup(PhysicsGroup.RagdollGroup)
        self:TriggerOutputs(player)  

    end
 
end


if (Client) then

    function LogicTarget:OnTakeDamage(damage, attacker, doer, point)     
       
        // Push the physics model around on the client when we shoot it.
        // This won't affect the model on other clients, but it's just for
        // show anyway (doesn't affect player movement).
        if (self.physicsModel ~= nil) then
            local direction = Vector(0, 1, 0)
            if doer and point then
                direction = doer:GetOrigin() - point
            end
            self.physicsModel:AddImpulse(point, direction * 0.01)
        end
        
    end

end

Shared.LinkClassToMap("LogicTarget", LogicTarget.kMapName , networkVars )

