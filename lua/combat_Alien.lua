//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Alien.lua

local HotReload = CombatAlien
if(not HotReload) then
    CombatAlien = {}
	ClassHooker:Mixin("CombatAlien")
end
    
function CombatAlien:OnLoad()
   
    self:ReplaceClassFunction("Alien", "LockTierTwo", function() end)
    self:ReplaceClassFunction("Alien", "UpdateNumHives","UpdateNumHives_Hook")
    self:PostHookClassFunction("Alien", "OnUpdateAnimationInput","OnUpdateAnimationInput_Hook")
	
end

function CombatAlien:UpdateNumHives_Hook(self)

    local time = Shared.GetTime()
	if self.timeOfLastNumHivesUpdate == nil or (time > self.timeOfLastNumHivesUpdate + 0.5) then

		if self.combatTable then
			if self.combatTable.twoHives and self.combatTable.twoHives ~= self.twoHives then
				self.twoHives = true
				self:UnlockTierTwo()
			end
			
			if self.combatTable.threeHives and self.combatTable.threeHives ~= self.threeHives then
				self.threeHives = true
				self:UnlockTierThree()
			end
		end
		
		self.timeOfLastNumHivesUpdate = time
		
	end
end

function CombatAlien:OnUpdateAnimationInput_Hook(self, modelMixin)
  
    if self:GotFocus() then
        modelMixin:SetAnimationInput("attack_speed", kCombatFocusAttackSpeed)        
    else
        // standard attack speed is 1, but the variable is local so we cant use it
        modelMixin:SetAnimationInput("attack_speed", self:GetIsEnzymed() and kEnzymeAttackSpeed or 1.0)
    end
    
end

if (not HotReload) then
	CombatAlien:OnLoad()
end