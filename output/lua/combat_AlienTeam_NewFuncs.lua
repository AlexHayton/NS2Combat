//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_AlienTeam_NewFuncs.lua

function AlienTeam:OnResetComplete()
	
	// Try to destroy the local powernode, if we can find one.
	local initialTechPoint = self:GetInitialTechPoint()
	for index, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
    
        if powerPoint:GetLocationName() == initialTechPoint:GetLocationName() then
			powerPoint:SetConstructionComplete()
	        powerPoint:Kill(nil, nil, powerPoint:GetOrigin())
        end
        
    end
    
end