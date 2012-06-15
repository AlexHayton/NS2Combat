//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_MarineTeam.lua

if(not CombatMarineTeam) then
  CombatMarineTeam = {}
end

local HotReload = ClassHooker:Mixin("CombatMarineTeam")

function CombatMarineTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("MarineTeam", "lua/MarineTeam.lua") 
	self:ReplaceClassFunction("MarineTeam", "InitTechTree", "InitTechTree_Hook")
	
end

function CombatMarineTeam:InitTechTree_Hook(self)

	PlayingTeam.InitTechTree(self)
    
    // Marine tier 1
    self.techTree:AddBuildNode(kTechId.CommandStation,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Extractor,                 kTechId.None,                kTechId.None)
    // Count recycle like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Recycle, kTechId.None, kTechId.None)
    
    // When adding marine upgrades that morph structures, make sure to add to GetRecycleCost() also
    self.techTree:AddBuildNode(kTechId.InfantryPortal,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Armory,                    kTechId.None,                kTechId.None)    
    
    self.techTree:AddTargetedActivation(kTechId.MedPack,             kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.AmmoPack,            kTechId.None,                kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.CatPack,             kTechId.None,                kTechId.CatPackTech)
    self.techTree:AddBuyNode(kTechId.Axe,                         kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,                       kTechId.None,                kTechId.None)
    
    self.techTree:AddBuildNode(kTechId.PowerPack,                 kTechId.CommandStation,      kTechId.None)      
    
    // Squad tech nodes
    self.techTree:AddOrder(kTechId.SquadMove)
    self.techTree:AddOrder(kTechId.SquadAttack)
    self.techTree:AddOrder(kTechId.SquadDefend)
    self.techTree:AddOrder(kTechId.SquadSeekAndDestroy)
    self.techTree:AddOrder(kTechId.SquadHarass)
    self.techTree:AddOrder(kTechId.SquadRegroup)
    
    // Commander abilities
    self.techTree:AddTargetedActivation(kTechId.NanoShield,       kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.NanoConstruct,    kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.Scan,             kTechId.Observatory,         kTechId.None)
    
    self.techTree:AddMenu(kTechId.CommandStationUpgradesMenu)
    
    // Armory upgrades
    self.techTree:AddResearchNode(kTechId.RifleUpgradeTech,       kTechId.Armory,              kTechId.None)
    self.techTree:AddBuyNode(kTechId.RifleUpgrade, kTechId.RifleUpgradeTech, kTechId.None, kTechId.Rifle)
    
    self.techTree:AddMenu(kTechId.ArmsLabUpgradesMenu)
    self.techTree:AddMenu(kTechId.ArmoryEquipmentMenu)
    
    self.techTree:AddUpgradeNode(kTechId.AdvancedArmoryUpgrade,  kTechId.Armory,        kTechId.InfantryPortal)
    
    self.techTree:AddResearchNode(kTechId.Armor1,                 kTechId.ArmsLab,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons1,               kTechId.ArmsLab,               kTechId.None)
    
    // Marine tier 2
    self.techTree:AddUpgradeNode(kTechId.AdvancedArmory,               kTechId.Armory,        kTechId.None)
    self.techTree:AddResearchNode(kTechId.PhaseTech,                    kTechId.Observatory,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.PhaseGate,                    kTechId.PhaseTech,        kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor2,                 kTechId.Armor1,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons2,               kTechId.Weapons1,            kTechId.None)

    self.techTree:AddBuildNode(kTechId.Observatory,               kTechId.InfantryPortal,       kTechId.None)      
    self.techTree:AddActivation(kTechId.DistressBeacon,           kTechId.Observatory)       
    
    // Door actions
    self.techTree:AddBuildNode(kTechId.Door, kTechId.None, kTechId.None)
    self.techTree:AddActivation(kTechId.DoorOpen)
    self.techTree:AddActivation(kTechId.DoorClose)
    self.techTree:AddActivation(kTechId.DoorLock)
    self.techTree:AddActivation(kTechId.DoorUnlock)
    
    // Weapon-specific
    self.techTree:AddResearchNode(kTechId.ShotgunTech,           kTechId.None,              kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.GrenadeLauncherTech,           kTechId.ShotgunTech,                   kTechId.None)
    self.techTree:AddBuyNode(kTechId.GrenadeLauncher,                    kTechId.GrenadeLauncherTech,             kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.NerveGasTech,                  kTechId.GrenadeLauncherTech,           kTechId.None)
    self.techTree:AddBuyNode(kTechId.NerveGas, kTechId.NerveGasTech, kTechId.None, kTechId.GrenadeLauncher)
    
    self.techTree:AddResearchNode(kTechId.FlamethrowerTech,              kTechId.ShotgunTech,                   kTechId.None)
    self.techTree:AddBuyNode(kTechId.Flamethrower,                       kTechId.FlamethrowerTech,                kTechId.None)
    self.techTree:AddResearchNode(kTechId.FlamethrowerAltTech,           kTechId.FlamethrowerTech,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.FlamethrowerAlt,                    kTechId.FlamethrowerAltTech,                kTechId.None, kTechId.Flamethrower)
    
    self.techTree:AddResearchNode(kTechId.MinesTech,        kTechId.Armory,           kTechId.None)
    self.techTree:AddBuyNode(kTechId.LayMines,               kTechId.MinesTech,        kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.WelderTech,        kTechId.Armory,           kTechId.None)
    self.techTree:AddBuyNode(kTechId.Welder,               kTechId.WelderTech,        kTechId.None)
    
    // ARCs
    self.techTree:AddBuildNode(kTechId.RoboticsFactory,                    kTechId.Armory,              kTechId.None)  
    self.techTree:AddUpgradeNode(kTechId.UpgradeRoboticsFactory,           kTechId.Armory,              kTechId.RoboticsFactory) 
    self.techTree:AddBuildNode(kTechId.ARCRoboticsFactory,                 kTechId.Armory,              kTechId.RoboticsFactory)
    
    self.techTree:AddTechInheritance(kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory)
   
    self.techTree:AddManufactureNode(kTechId.ARC,                          kTechId.ARCRoboticsFactory,                kTechId.None)        
    self.techTree:AddActivation(kTechId.ARCDeploy)
    self.techTree:AddActivation(kTechId.ARCUndeploy)
    
    // Robotics factory menus
    self.techTree:AddMenu(kTechId.RoboticsFactoryARCUpgradesMenu)
    self.techTree:AddMenu(kTechId.RoboticsFactoryMACUpgradesMenu)
    
    // Marine tier 3
    // Armory upgrades
    self.techTree:AddResearchNode(kTechId.Armor3,                 kTechId.Armor2,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons3,               kTechId.Weapons2,            kTechId.None)

    // Jetpack
    self.techTree:AddResearchNode(kTechId.JetpackTech,           kTechId.Armor2, kTechId.None)
    
    // TODO: Make jetpacks depend on ThreeCommandStations
    self.techTree:AddBuyNode(kTechId.Jetpack,                    kTechId.JetpackTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.JetpackFuelTech,       kTechId.JetpackTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.JetpackArmorTech,      kTechId.JetpackTech, kTechId.None)
    
    // Exoskeleton
    self.techTree:AddResearchNode(kTechId.ExoskeletonTech,       kTechId.Armor2, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exoskeleton,                kTechId.ExoskeletonTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualMinigunTech,       kTechId.ExoskeletonTech, kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.ExoskeletonLockdownTech,   kTechId.ExoskeletonTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.ExoskeletonUpgradeTech,    kTechId.ExoskeletonTech, kTechId.None)   
    
    self.techTree:AddActivation(kTechId.SocketPowerNode,    kTechId.None,   kTechId.None)
    
    self.techTree:SetComplete()
	
end

if(HotReload) then
    CombatMarineTeam:OnLoad()
end