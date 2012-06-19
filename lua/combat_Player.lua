//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Player.lua


if(not CombatPlayer) then
    CombatPlayer = {}
end


local HotReload = ClassHooker:Mixin("CombatPlayer")
    
function CombatPlayer:OnLoad()
   
    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
    self:PostHookClassFunction("Player", "Reset", "Reset_Hook")
    self:PostHookClassFunction("Player", "CopyPlayerDataFrom", "CopyPlayerDataFrom_Hook") 
	self:ReplaceClassFunction("Player", "GetTechTree", "GetTechTree_Hook") 

    self:ReplaceFunction("GetIsTechAvailable", "GetIsTechAvailable_Hook")
    
end

// Implement lvl and XP
function CombatPlayer:Reset_Hook(self)
  
	// Initialise the Combat Data.
	self:CheckCombatData()
    
end

// Copy old lvl and XP when respawning 
function CombatPlayer:CopyPlayerDataFrom_Hook(self, player)    

	self.combatTable = player.combatTable
	
	// Give the ups back, but just when respawing
	if player and player.isRespawning then
		  self:GiveUpsBack()
	end
    
end

function CombatPlayer:GetTechTree_Hook(self)

	self:CheckCombatData()
	
    return self.combatTechTree

end

//___________________
// Hooks Alien_Upgrade
//___________________

// Hook GetIsTechAvailable so Aliens can get Ups Like cara, cele etc.
function CombatPlayer:GetIsTechAvailable_Hook(self, teamNumber, techId)

    return true

end


if(hotreload) then
    CombatPlayer:OnLoad()
end