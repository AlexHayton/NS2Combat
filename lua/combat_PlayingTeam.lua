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
    self:ReplaceClassFunction("PlayingTeam", "GetHasTeamLost", "GetHasTeamLost_Hook")
	self:ReplaceClassFunction("PlayingTeam", "UpdateTechTree", "UpdateTechTree_Hook")
    
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
    local commandStructure = techPoint:SpawnCommandStructure(self:GetTeamNumber())
    assert(commandStructure ~= nil)
    commandStructure:SetConstructionComplete()
    
    // Use same align as tech point.
    local techPointCoords = techPoint:GetCoords()
    techPointCoords.origin = commandStructure:GetOrigin()
    commandStructure:SetCoords(techPointCoords)
    
    //if commandStructure:isa("Hive") then
      //  commandStructure:SetFirstLogin()
    //end
	
	// Set the command station to be occupied.
	if commandStructure:isa("CommandStation") then
		commandStructure.occupied = true
		//commandStructure:UpdateCommanderLogin(true)
	end
	
	return tower, commandStructure
    
end

function CombatPlayingTeam:UpdateTechTree_Hook(self)

    PROFILE("PlayingTeam:UpdateTechTree")
    
    // Compute tech tree availability only so often because it's very slooow
    if self.techTree ~= nil then
		if (self.timeOfLastTechTreeUpdate == nil or Shared.GetTime() > self.timeOfLastTechTreeUpdate + PlayingTeam.kTechTreeUpdateTime) then

			local techIds = {}
			
			for index, structure in ipairs(GetEntitiesForTeam("Structure", self:GetTeamNumber())) do
			
				if structure:GetIsBuilt() and structure:GetIsActive(true) then
				
					table.insert(techIds, structure:GetTechId())
					
				end
				
			end
			
			self.techTree:Update(techIds)

			// Send tech tree base line to players that just switched teams or joined the game        
			// Also refresh and update existing players' tech trees.
			local players = self:GetPlayers()
			
			for index, player in ipairs(players) do

				player:UpdateTechTree()
			
				if player:GetSendTechTreeBase() then
				
					if player:GetTechTree() ~= nil then            
						player:GetTechTree():SendTechTreeBase(player)
					end
					
					player:ClearSendTechTreeBase()
					
				end
				
				// Send research, availability, etc. tech node updates to players   
				if player:GetTechTree() ~= nil then            
					player:GetTechTree():SendTechTreeUpdates({ player })
				end
				
			end
			
			self.timeOfLastTechTreeUpdate = Shared.GetTime()
			
			self:OnTechTreeUpdated()
			
		end
	end
    
end

if(hotreload) then
    CombatPlayingTeam:OnLoad()
end