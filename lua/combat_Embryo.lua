//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Embryo.lua


if(not CombatEmbryo) then
    CombatEmbryo = {}
end


local HotReload = ClassHooker:Mixin("CombatEmbryo")
    
function CombatEmbryo:OnLoad()
    
    self:PostHookClassFunction("Embryo", "SetGestationData", "SetGestationData_Hook") 
    
end

// Weapons can't be dropped anymore
function CombatEmbryo:SetGestationData_Hook(self, techIds, previousTechId, healthScalar, armorScalar)

	// Override the gestation times...
	self.gestationTime = kSkulkGestateTime

end

if(HotReload) then
    CombatEmbryo:OnLoad()
end