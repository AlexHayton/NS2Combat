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
    
end



if(hotreload) then
    CombatPlayer:OnLoad()
end