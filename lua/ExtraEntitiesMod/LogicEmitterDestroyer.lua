//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicEmitterDestroyer.lua

Script.Load("lua/ExtraEntitiesMod/LogicEmitter.lua")

class 'LogicEmitterDestroyer' (LogicEmitter)

LogicEmitterDestroyer.kMapName = "logic_emitter_destroyer"

local networkVars =
{
}

function LogicEmitterDestroyer:OnLogicTrigger(player)
    // disable all sound effects listening on that channel
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("SoundEffect")) do    
        if ent:GetListenChannel() == self.emitChannel and ent.signalFunctions[self.emitMessage] then
            ent.playing = false            
        end        
    end
    
    // destroy all particle effects
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("ParticleEffect")) do    
        if ent.listenChannel == self.emitChannel and ent.startsOnMessage == self.emitMessage then
            DestroyEntity(ent)  
        end        
    end
    
end


Shared.LinkClassToMap("LogicEmitterDestroyer", LogicEmitterDestroyer.kMapName, networkVars)