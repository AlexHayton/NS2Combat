//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

if Server then

    local function EmitParticleEffect(self)
        // dont kill it if its endless or loop
        local effect = Shared.CreateEffect(nil, self.cinematicName, nil, self:GetCoords())
        if self.repeatStyle == 1 or self.repeatStyle == 2 then
            effect.lifeTime = -1
        end
    end

    local overrideServerParticleEmitterOnInitialized = ServerParticleEmitter.OnInitialized
    function ServerParticleEmitter:OnInitialized()
        self:RegisterSignalListener(function() EmitParticleEffect(self) end, self.startsOnMessage)
    end
    
    local overrideParticleEffectOnUpdate = ParticleEffect.OnUpdate
    function ParticleEffect:OnUpdate(deltaTime)
        if self.lifeTime ~= -1 then
            overrideParticleEffectOnUpdate(self, deltaTime)
        end        
    end
    
end

