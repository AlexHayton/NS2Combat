//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
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

    self:ReplaceFunction("GetIsTechAvailable", "GetIsTechAvailable_Hook")
    
end

// Implement lvl and XP
function CombatPlayer:Reset_Hook(self)
  
    self.combatTable = {}  
    self.combatTable.xp = 0
    self.combatTable.lvl = 1
    self.combatTable.lvlfree = 0
    
    // save every Update in the personal techtree
    self.combatTable.techtree = {}
    
end

// Copy old lvl and XP when respawning 
function CombatPlayer:CopyPlayerDataFrom_Hook(self, player)    

	self.combatTable = player.combatTable
	// Give the ups back, but just when respawing
	if player and player.isRespawning then
		  self:GiveUpsBack()
	end
    
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