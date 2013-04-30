//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_SoundEffect.lua

local HotReload = CombatSoundEffect
if(not HotReload) then
  CombatSoundEffect = {}
  ClassHooker:Mixin("CombatSoundEffect")
end
    
function CombatSoundEffect:OnLoad()
    self:PostHookFunction("StartSoundEffectOnEntity", "StartSoundEffectOnEntity_Hook")    
end

local kTauntSounds =
{
    "sound/NS2.fev/alien/skulk/taunt",
    "sound/NS2.fev/alien/gorge/taunt",
    "sound/NS2.fev/alien/lerk/taunt",
    "sound/NS2.fev/alien/fade/taunt",
    "sound/NS2.fev/alien/onos/taunt",
    "sound/NS2.fev/alien/common/swarm",
	"sound/NS2.fev/marine/voiceovers/taunt",
}

// Hooks for Ink and EMP are in here.
function CombatSoundEffect:StartSoundEffectOnEntity_Hook(soundEffectName, onEntity)

	if onEntity:isa("Player") then
		onEntity:CheckCombatData()
		
		// Check whether the sound is a taunt sound
		for index, tauntSoundName in ipairs(kTauntSounds) do
			if (soundEffectName == tauntSoundName) then
				
				// Now check whether the player has taunted recently and fire taunt abilities.
				if (Shared.GetTime() - onEntity.combatTable.lastTauntTime > kCombatTauntCheckInterval) then
					onEntity:ProcessTauntAbilities()
					onEntity.combatTable.lastTauntTime = Shared.GetTime()
				end
				
				break
			end
		end
	end

end

if (not HotReload) then
	CombatSoundEffect:OnLoad()
end