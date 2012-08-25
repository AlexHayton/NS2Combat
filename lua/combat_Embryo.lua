//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Embryo.lua

local HotReload = CombatEmbryo
if(not HotReload) then
  CombatEmbryo = {}
  ClassHooker:Mixin("CombatEmbryo")
end
    
function CombatEmbryo:OnLoad()
    
    self:PostHookClassFunction("Embryo", "SetGestationData", "SetGestationData_Hook") 
    
end

// Weapons can't be dropped anymore
function CombatEmbryo:SetGestationData_Hook(self, techIds, previousTechId, healthScalar, armorScalar)

	// Override the gestation times...
	self.gestationTime = kSkulkGestateTime
	
	if (self.combatTable.classEvolve) then
		local newGestateTime = kGestateTime[previousTechId]
		if newGestateTime ~= nil then
			self.gestationTime = newGestateTime
		end
		
		self.combatTable.classEvolve = nil
	end
		
end

if (not HotReload) then
	CombatEmbryo:OnLoad()
end
