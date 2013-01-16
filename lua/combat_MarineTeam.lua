//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_MarineTeam.lua

local HotReload = CombatMarineTeam
if(not HotReload) then
  CombatMarineTeam = {}
  ClassHooker:Mixin("CombatMarineTeam")
end

function CombatMarineTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("MarineTeam", "lua/MarineTeam.lua") 
	self:ReplaceClassFunction("MarineTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
	self:ReplaceClassFunction("MarineTeam", "Update", "Update_Hook")
	
end

//___________________
// Hooks MarineTeam
//___________________

function CombatMarineTeam:SpawnInitialStructures_Hook(self, techPoint)

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)

	//Check if there is already an Armory
	if #GetEntitiesForTeam(Armory.kMapName, self:GetTeamNumber()) == 0 then	
		// Don't Spawn an IP, make an armory instead!
		// spawn initial Armory for marine team    
		local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
		
		for i = 1, kSpawnArmoryMaxRetries do
			// Increase the spawn distance on a gradual basis.
			local origin = CalculateRandomSpawn(nil, techPointOrigin, kTechId.Armory, true, kArmorySpawnMinDistance, (kArmorySpawnMaxDistance * i / kSpawnArmoryMaxRetries), nil)

			if origin then			
				local armory = CreateEntity(Armory.kMapName, origin - Vector(0, 0.1, 0), self:GetTeamNumber())
				
				SetRandomOrientation(armory)
				armory:SetConstructionComplete()
				
				break				
			end		
		end
	end
	
	self.ipsToConstruct = 0
    
    return tower, commandStation    
end



// Don't Check for IPS
function CombatMarineTeam:Update_Hook(self, timePassed)

    PlayingTeam.Update(self, timePassed)
    
end

if (not HotReload) then
	CombatMarineTeam:OnLoad()
end
