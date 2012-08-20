//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Alien.lua

if(not CombatAlien) then
    CombatAlien = {}
end


local HotReload = ClassHooker:Mixin("CombatAlien")
    
function CombatAlien:OnLoad()
   
    self:ReplaceClassFunction("Alien", "LockTierTwo", function() end)
    self:ReplaceClassFunction("Alien", "UpdateNumHives","UpdateNumHives_Hook")
	
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