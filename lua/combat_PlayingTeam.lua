//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_PlayingTeam.lua


if(not CombatPlayingTeam) then
  CombatPlayingTeam = {}
end


local HotReload = ClassHooker:Mixin("CombatPlayingTeam")
    
function CombatPlayingTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("PlayingTeam", "lua/PlayingTeam.lua") 
    self:ReplaceClassFunction("PlayingTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
    self:ReplaceClassFunction("PlayingTeam", "SpawnResourceTower", "SpawnResourceTower_Hook")
    self:ReplaceClassFunction("PlayingTeam", "GetHasTeamLost", "GetHasTeamLost_Hook")
    
end

//___________________
// Hooks Playing Team
//___________________

function CombatPlayingTeam:GetHasTeamLost_Hook(self, handle)
    // Don't bother with the original - we just set our own logic here.
	// You can lose with cheats on (testing purposes)
	if(GetGamerules():GetGameStarted()) then
    
        // Team can't respawn or last Command Station or Hive destroyed
        local numCommandStructures = self:GetNumCommandStructures()
        
        if  ( numCommandStructures == 0 ) or
            ( self:GetNumPlayers() == 0 ) then
            
            return true
            
        end
            
    end

    return false

end

function CombatPlayingTeam:SpawnInitialStructures_Hook(self, techPoint)
    // Dont Spawn RTS or Cysts
        
    ASSERT(techPoint ~= nil)

    // Spawn hive/command station at team location
    local commandStructure = self:SpawnCommandStructure(techPoint)
    
    if commandStructure:isa("Hive") then
        commandStructure:SetFirstLogin()
    end
	
	// Set the command station to be occupied.
	if commandStructure:isa("CommandStation") then
		commandStructure.occupied = true
		//commandStructure:UpdateCommanderLogin(true)
	end
    
end

function CombatPlayingTeam:SpawnResourceTower_Hook(self, techPoint)
    // No RTS!!
end

if(hotreload) then
    CombatPlayingTeam:OnLoad()
end