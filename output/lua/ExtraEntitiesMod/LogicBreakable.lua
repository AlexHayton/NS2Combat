//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2013
//
//________________________________

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")

class 'LogicBreakable' (ScriptActor)

LogicBreakable.kMapName = "logic_breakable"

LogicBreakable.kCinematic = PrecacheAsset("cinematics/breakable/breakable_debris.cinematic")

local kSurfaceName = {
                        "metal",
                        "rock",
                        "organic",
                        "infestation",
                        "thin_metal",
                        "electronic",
                        "armor",
                        "flesh",
                        "membrane",
                    }

local networkVars =
{
    scale = "vector",
    surface = "integer (0 to 10)",
    cinematicName = "string (128)",
    team = "integer (0 to 2)",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)


function LogicBreakable:OnCreate()
    ScriptActor.OnCreate(self)
        
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
end

function LogicBreakable:OnInitialized()

    ScriptActor.OnInitialized(self)
    InitMixin(self, ScaledModelMixin)
	
    if not Predict and (self.model ~= nil) then
        PrecacheAsset(self.model)
        self:SetScaledModel(self.model)
    end
    
    if not self.cinematicName then
        self.cinematicName = LogicBreakable.kCinematic
    end
    
    PrecacheAsset(self.cinematicName)

    if Server then
        InitMixin(self, LogicMixin)
        InitMixin(self, StaticTargetMixin)
        if (self.team and self.team > 0) then
            self:SetTeamNumber(self.team)
        end
        
    end
    
    self.health = tonumber(self.health)    
    self.initialHealth = self.health
    
    if not self.surface then
        self.surface = 0
    end
    
    self:SetPhysicsType(PhysicsType.Kinematic)    
        
end

function LogicBreakable:Reset()
    self.health = self.initialHealth
    
    if not self:GetRenderModel() then
        if(self.model ~= nil) then
            self:SetScaledModel(self.model)
        end
    end
    
end

function LogicBreakable:GetCanIdle()
    return false
end

function LogicBreakable:GetSendDeathMessageOverride()
    return false
end

function LogicBreakable:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false
end   

function LogicBreakable:GetCanTakeDamageOverride()
    return true
end

function LogicBreakable:OnTakeDamage(damage, attacker, doer, point)
end

function LogicBreakable:GetShowHitIndicator()
    return true
end

function LogicBreakable:GetSurfaceOverride()
    return kSurfaceName[self.surface + 1]
end   
 
function LogicBreakable:OnKill(damage, attacker, doer, point, direction)

    ScriptActor.OnKill(self, damage, attacker, doer, point, direction)
    BaseModelMixin.OnDestroy(self)
   
    self:SetPhysicsGroup(PhysicsGroup.DroppedWeaponGroup)
    self:SetPhysicsGroupFilterMask(PhysicsMask.None)
    
    if Server then
        self:TriggerOutputs(attacker)  
        Print("Trigger ouputs")
    end
    
    effectEntity = Shared.CreateEffect(nil, self.cinematicName, nil, Coords.GetTranslation(self:GetOrigin()))
end
 

if (Client) then

    function LogicBreakable:OnKillClient()
        BaseModelMixin.OnDestroy(self)
        self:SetPhysicsType(PhysicsType.None) 
        // TODO: delete phys model from Client.propList
    end


    function LogicBreakable:OnTakeDamage(damage, attacker, doer, point)    
    end


end

Shared.LinkClassToMap("LogicBreakable", LogicBreakable.kMapName , networkVars )

