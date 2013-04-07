//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicEmitter.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/Mixins/SignalEmitterMixin.lua")

// changed it to ScriptActor so it can be called from the "mappostload" function 
class 'LogicEmitter' (ScriptActor)

LogicEmitter.kMapName = "logic_emitter"

local networkVars =
{
}


function LogicEmitter:OnCreate()
    Entity.OnCreate(self)    
    InitMixin(self, SignalEmitterMixin)
end

function LogicEmitter:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)

    end
    
end

function LogicEmitter:OnMapPostLoad()
    if self.emitOnStart then
        self:EmitSignal(self.emitChannel, self.emitMessage)
    end
end

function LogicEmitter:SetEmitChannel(setChannel)

    assert(type(setChannel) == "number")
    assert(setChannel >= 0)
    
    self.emitChannel = setChannel
    
end

function LogicEmitter:SetEmitMessage(setMessage)

    assert(type(setMessage) == "string")    
    self.emitMessage = setMessage
    
end

function LogicEmitter:OnDestroy()

    Entity.OnDestroy(self)    
    
end

function LogicEmitter:OnLogicTrigger(player)
    self:EmitSignal(self.emitChannel, self.emitMessage)
end


Shared.LinkClassToMap("LogicEmitter", LogicEmitter.kMapName, networkVars)