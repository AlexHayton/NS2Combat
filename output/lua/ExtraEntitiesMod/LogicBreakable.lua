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
    surface = "integer (0 to 10)",
    cinematic = "string (128)",
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

    if(self.model ~= nil) then
        PrecacheAsset(self.model)
        self:SetModel( self.model )
    end
    
    if self.cinematic then
        PrecacheAsset(self.cinematic)
    else
        self.cinematic = LogicBreakable.kCinematic
    end
    

    if Server then
        InitMixin(self, LogicMixin)
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
            self:SetModel( self.model )
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
    return false
end   

function LogicBreakable:GetCanTakeDamageOverride()
    return true
end

function LogicBreakable:GetShowHitIndicator()
    return true
end

function LogicBreakable:GetSurfaceOverride()
    return kSurfaceName[self.surface + 1]
end   

function LogicBreakable:GetOutputNames()
    return {self.output1}
end


function LogicBreakable:OnLogicTrigger(player) 
end


  
function LogicBreakable:OnKill(damage, attacker, doer, point, direction)

    BaseModelMixin.OnDestroy(self)

    if Server then
        self:TriggerOutputs(player)  
    end
    
    effectEntity = Shared.CreateEffect(nil, self.cinematic, nil, Coords.GetTranslation(self:GetOrigin()))
end
 

if (Client) then

    function LogicBreakable:OnKillClient()
        BaseModelMixin.OnDestroy(self)
    end


    function LogicBreakable:OnTakeDamage(damage, attacker, doer, point)    
    end


end

Shared.LinkClassToMap("LogicBreakable", LogicBreakable.kMapName , networkVars )

