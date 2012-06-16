//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Marine.lua


if(not CombatMarine) then
    CombatMarine = {}
end


local HotReload = ClassHooker:Mixin("CombatMarine")
    
function CombatMarine:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Marine", "lua/Marine.lua") 
    self:ReplaceClassFunction("Marine", "OnKill", "MarineOnKill_Hook") 
    self:ReplaceClassFunction("Marine", "Drop", "Drop_Hook")
    
end

//___________________
// Hooks Marine
//___________________

// Dont' drop Weapons after getting killed
function CombatMarine:MarineOnKill_Hook(self, damage, attacker, doer, point, direction)

    Player.OnKill(self, damage, attacker, doer, point, direction)
    self:PlaySound(Marine.kDieSoundName)
    
    // Don't play alert if we suicide
    if player ~= self then
        self:GetTeam():TriggerAlert(kTechId.MarineAlertSoldierLost, self)
    end
    
    // Remember our squad and position on death so we can beam back to them
    self.lastSquad = self:GetSquad()
    self.originOnDeath = self:GetOrigin()
	
end

// Weapons can't be dropped anymore
function CombatMarine:Drop_Hook(self, weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)

	// just do nothing

end

if(hotreload) then
    CombatMarine:OnLoad()
end