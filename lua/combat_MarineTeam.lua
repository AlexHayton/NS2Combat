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
	self:ReplaceClassFunction("MarineTeam", "InitTechTree", "InitTechTree_Hook")
	self:ReplaceClassFunction("MarineTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
	self:ReplaceClassFunction("MarineTeam", "Update", "Update_Hook")
	
end

function CombatMarineTeam:InitTechTree_Hook(self)

	PlayingTeam.InitTechTree(self)
    
    // Marine tier 1
    // When adding marine upgrades that morph structures, make sure to add to GetRecycleCost() also
    self.techTree:AddTargetedActivation(kTechId.MedPack,             kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.AmmoPack,            kTechId.None,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.CatPackTech,            kTechId.None,              kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.CatPack,             kTechId.None,              kTechId.CatPackTech)
    self.techTree:AddBuyNode(kTechId.Axe,                         kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,                       kTechId.None,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.PowerPack,                 kTechId.None,      kTechId.None)      

    // Commander abilities
    self.techTree:AddTargetedActivation(kTechId.NanoShield,       kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.Scan,             kTechId.None,         	   kTechId.None)
	self.techTree:AddActivation(kTechId.MACEMP,                   kTechId.None,                kTechId.None)      

    // Armory upgrades
    self.techTree:AddResearchNode(kTechId.RifleUpgradeTech,       kTechId.None,              kTechId.None)
    self.techTree:AddBuyNode(kTechId.RifleUpgrade, kTechId.RifleUpgradeTech, kTechId.None, kTechId.Rifle)
    
    self.techTree:AddResearchNode(kTechId.Armor1,                 kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons1,               kTechId.None,               kTechId.None)
    
    // Marine tier 2
    self.techTree:AddResearchNode(kTechId.PhaseTech,              kTechId.None,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.PhaseGate,                 kTechId.PhaseTech,        kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor2,                 kTechId.Armor1,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons2,               kTechId.Weapons1,            kTechId.None)
    
    // Weapon-specific
    self.techTree:AddResearchNode(kTechId.ShotgunTech,           kTechId.None,              kTechId.None)
    self.techTree:AddBuyNode(kTechId.Shotgun,                    kTechId.ShotgunTech,         kTechId.Armory)
    
    self.techTree:AddResearchNode(kTechId.GrenadeLauncherTech,           kTechId.None,                   kTechId.None)
    self.techTree:AddBuyNode(kTechId.GrenadeLauncher,                    kTechId.GrenadeLauncherTech,             kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.NerveGasTech,                  kTechId.GrenadeLauncherTech,           kTechId.None)
    self.techTree:AddBuyNode(kTechId.NerveGas, kTechId.NerveGasTech, kTechId.None, kTechId.GrenadeLauncher)
    
    self.techTree:AddResearchNode(kTechId.FlamethrowerTech,              kTechId.None,                   kTechId.None)
    self.techTree:AddBuyNode(kTechId.Flamethrower,                       kTechId.FlamethrowerTech,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.FlamethrowerAltTech,           kTechId.FlamethrowerTech,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.FlamethrowerAlt,                    kTechId.FlamethrowerAltTech,                kTechId.None, kTechId.Flamethrower)
    
    self.techTree:AddResearchNode(kTechId.MinesTech,        kTechId.None,           kTechId.None)
    self.techTree:AddBuyNode(kTechId.LayMines,               kTechId.MinesTech,        kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.WelderTech,        kTechId.None,           kTechId.None)
    self.techTree:AddBuyNode(kTechId.Welder,               kTechId.WelderTech,        kTechId.None)

    // Armory upgrades
    self.techTree:AddResearchNode(kTechId.Armor3,                 kTechId.Armor2,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons3,               kTechId.Weapons2,            kTechId.None)

    // Jetpack
    self.techTree:AddResearchNode(kTechId.JetpackTech,           kTechId.None, kTechId.None)
    
    self.techTree:AddBuyNode(kTechId.Jetpack,                    kTechId.JetpackTech, kTechId.Armory)
    self.techTree:AddResearchNode(kTechId.JetpackFuelTech,       kTechId.JetpackTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.JetpackArmorTech,      kTechId.JetpackTech, kTechId.None)
    
    // Exosuit
    self.techTree:AddResearchNode(kTechId.ExosuitTech,       kTechId.None, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,                kTechId.ExosuitTech, kTechId.Armory)
    self.techTree:AddResearchNode(kTechId.DualMinigunTech,       kTechId.ExosuitTech, kTechId.Armory)
    
    self.techTree:AddResearchNode(kTechId.ExosuitLockdownTech,   kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.ExosuitUpgradeTech,    kTechId.ExosuitTech, kTechId.None)   
    
    self.techTree:AddActivation(kTechId.SocketPowerNode,    kTechId.None,   kTechId.None)
    
    self.techTree:SetComplete()
	
end

//___________________
// Hooks MarineTeam
//___________________

function CombatMarineTeam:SpawnInitialStructures_Hook(self, techPoint)

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)    

    // Don't Spawn an IP, make an armory instead!
	// spawn initial Armory for marine team
    
    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    for i = 1, 50 do

        if self.ipsToConstruct == 0 then
            break
        end    

        local origin = CalculateRandomSpawn(nil, techPointOrigin, kTechId.Armory, true, kInfantryPortalMinSpawnDistance * 1, kInfantryPortalMinSpawnDistance * 2.5, 3)

        if origin then
        
            origin = origin - Vector(0, 0.1, 0)

            local armory = CreateEntity(Armory.kMapName, origin, self:GetTeamNumber())
            
            SetRandomOrientation(armory)
            
            armory:SetConstructionComplete() 
            
            self.ipsToConstruct = self.ipsToConstruct - 1
            
        end
    
    end
    
    return tower, commandStation
    
end



// Don't Check for IPS
function CombatMarineTeam:Update_Hook(self, timePassed)

    PlayingTeam.Update(self, timePassed)
    
end

if (not HotReload) then
	CombatMarineTeam:OnLoad()
end
