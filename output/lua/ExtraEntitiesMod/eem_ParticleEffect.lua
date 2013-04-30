//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________


local networkVars =
{
    repeatStyle = "integer (0 to 2)",
}

if Server then

    local function EmitParticleEffect(self)
        // dont kill it if its endless or loop
        local effect = Shared.CreateEffect(nil, self.cinematicName, nil, self:GetCoords())
        effect.repeatStyle = self.repeatStyle
        effect.startsOnMessage = self.startsOnMessage
        effect.listenChannel = self:GetListenChannel()
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

if Client then

    local overrideParticleEffecOnInitialized = ParticleEffect.OnInitialized
    function ParticleEffect:OnInitialized()
        overrideParticleEffecOnInitialized(self)
        if self.cinematic then
            self.cinematic:SetRepeatStyle(self.repeatStyle or Cinematic.Repeat_Endless)
        end
    end

end

Class_Reload("ParticleEffect", networkVars)