//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_AlienTeam.lua

if(not CombatAlienTeam) then
  CombatAlienTeam = {}
end

local HotReload = ClassHooker:Mixin("CombatAlienTeam")

function CombatAlienTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("AlienTeam", "lua/AlienTeam.lua") 
	self:ReplaceClassFunction("AlienTeam", "InitTechTree", "InitTechTree_Hook")
	
end

function CombatAlienTeam:InitTechTree_Hook(self)

	PlayingTeam.InitTechTree(self)
	
	// Baseline 
	self.techTree:AddBuildNode(kTechId.Hive,                      kTechId.None,                kTechId.None)
	self.techTree:AddBuyNode(kTechId.Skulk,                     kTechId.None,                kTechId.None)
	
	// Add special alien menus
    self.techTree:AddMenu(kTechId.MarkersMenu)
    self.techTree:AddMenu(kTechId.UpgradesMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomStructuresMenu)
    self.techTree:AddMenu(kTechId.ShiftEcho)
    self.techTree:AddMenu(kTechId.BasicLifeFormMenu)
    self.techTree:AddMenu(kTechId.AdvancedLifeFormMenu)
    
    self.techTree:AddPassive(kTechId.Infestation)
    
    // Add markers (orders)
    self.techTree:AddSpecial(kTechId.ThreatMarker, true)
    self.techTree:AddSpecial(kTechId.LargeThreatMarker, true)
    self.techTree:AddSpecial(kTechId.NeedHealingMarker, true)
    self.techTree:AddSpecial(kTechId.WeakMarker, true)
    self.techTree:AddSpecial(kTechId.ExpandingMarker, true)
    
    // Gorge specific orders
    self.techTree:AddOrder(kTechId.AlienMove)
    self.techTree:AddOrder(kTechId.AlienAttack)
    //self.techTree:AddOrder(kTechId.AlienDefend)
    self.techTree:AddOrder(kTechId.AlienConstruct)
    self.techTree:AddOrder(kTechId.Heal)
    self.techTree:AddOrder(kTechId.SetTeleport)
	
	// infestation upgrades
    self.techTree:AddResearchNode(kTechId.HealingBed,            kTechId.CragHive,            kTechId.None)
    self.techTree:AddResearchNode(kTechId.MucousMembrane,        kTechId.ShiftHive,           kTechId.None)
    self.techTree:AddResearchNode(kTechId.BacterialReceptors,    kTechId.ShadeHive,           kTechId.None)
	
	// Tier 1 lifeforms
    self.techTree:AddAction(kTechId.Skulk,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Gorge,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Lerk,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Fade,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Onos,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Egg,                      kTechId.None,                kTechId.None)
    
    self.techTree:AddPlasmaManufactureNode(kTechId.GorgeEgg,          kTechId.None,                kTechId.None)
    self.techTree:AddPlasmaManufactureNode(kTechId.LerkEgg,          kTechId.None,                kTechId.None)
    self.techTree:AddPlasmaManufactureNode(kTechId.FadeEgg,          kTechId.None,                kTechId.None)
    self.techTree:AddPlasmaManufactureNode(kTechId.OnosEgg,          kTechId.None,                kTechId.None)
    
    // Special alien structures. These tech nodes are modified at run-time, depending when they are built, so don't modify prereqs.
    self.techTree:AddBuildNode(kTechId.Crag,                      kTechId.CragHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shift,                     kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shade,                     kTechId.ShadeHive,          kTechId.None)
    
    // Alien upgrade structure
    self.techTree:AddBuildNode(kTechId.Shell, kTechId.CragHive, kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeRegenerationShell, kTechId.CragHive, kTechId.None)
    self.techTree:AddBuildNode(kTechId.RegenerationShell, kTechId.CragHive, kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeCarapaceShell, kTechId.CragHive, kTechId.None)
    self.techTree:AddBuildNode(kTechId.CarapaceShell, kTechId.CragHive, kTechId.None)
    
    self.techTree:AddBuildNode(kTechId.Spur,                     kTechId.ShiftHive,          kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeCeleritySpur,    kTechId.ShiftHive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.CeleritySpur,             kTechId.ShiftHive,          kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeHyperMutationSpur, kTechId.ShiftHive,        kTechId.None) 
    self.techTree:AddBuildNode(kTechId.HyperMutationSpur,          kTechId.ShiftHive,        kTechId.None)     
    
    self.techTree:AddBuildNode(kTechId.Veil,                     kTechId.ShadeHive,        kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeSilenceVeil,     kTechId.ShadeHive,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.SilenceVeil,              kTechId.ShadeHive,        kTechId.None)    
    self.techTree:AddUpgradeNode(kTechId.UpgradeCamouflageVeil,  kTechId.ShadeHive,        kTechId.None) 
    self.techTree:AddBuildNode(kTechId.CamouflageVeil,           kTechId.ShadeHive,        kTechId.None) 
    
    // Crag
    self.techTree:AddUpgradeNode(kTechId.EvolveBabblers,          kTechId.Crag,          kTechId.None)
    self.techTree:AddPassive(kTechId.CragHeal)
    self.techTree:AddActivation(kTechId.CragUmbra,                kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.CragBabblers,             kTechId.None,          kTechId.None)

    // Shift    
    self.techTree:AddUpgradeNode(kTechId.EvolveEcho,              kTechId.None,         kTechId.None)
    self.techTree:AddActivation(kTechId.ShiftHatch,              kTechId.None,         kTechId.None)
    self.techTree:AddResearchNode(kTechId.EchoTech,               kTechId.None,         kTechId.None)  
    self.techTree:AddPassive(kTechId.ShiftEnergize,               kTechId.None,         kTechId.None)
    
    self.techTree:AddTargetedActivation(kTechId.TeleportHydra,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportWhip,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportCrag,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportShade,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportShift,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportVeil,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportSpur,        kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportShell,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportHive,       kTechId.None,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportEgg,       kTechId.None,         kTechId.None)

    // Shade
    self.techTree:AddUpgradeNode(kTechId.EvolveHallucinations,    kTechId.Shade,        kTechId.None)
    self.techTree:AddPassive(kTechId.ShadeDisorient)
    self.techTree:AddPassive(kTechId.ShadeCloak)
    self.techTree:AddActivation(kTechId.ShadeInk,                 kTechId.None,         kTechId.None) 

    // Hallucinations
    self.techTree:AddEnergyManufactureNode(kTechId.HallucinateDrifter,  kTechId.None,   kTechId.None)
    self.techTree:AddEnergyManufactureNode(kTechId.HallucinateSkulk,    kTechId.None,   kTechId.None)
    self.techTree:AddEnergyManufactureNode(kTechId.HallucinateGorge,    kTechId.None,   kTechId.None)
    self.techTree:AddEnergyManufactureNode(kTechId.HallucinateLerk,     kTechId.None,   kTechId.None)
    self.techTree:AddEnergyManufactureNode(kTechId.HallucinateFade,     kTechId.None,   kTechId.None)
    self.techTree:AddEnergyManufactureNode(kTechId.HallucinateOnos,     kTechId.None,   kTechId.None)
    
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateHive,           kTechId.None,           kTechId.None)
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateWhip,           kTechId.None,           kTechId.None)
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateShade,          kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateCrag,           kTechId.CragHive,       kTechId.None)
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateShift,          kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateHarvester,      kTechId.None,           kTechId.None)
    self.techTree:AddEnergyBuildNode(kTechId.HallucinateHydra,          kTechId.None,           kTechId.None)
    
    // Tier 2
    self.techTree:AddResearchNode(kTechId.Leap,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Spikes,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.BileBomb,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Blink,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Stomp,            kTechId.None,              kTechId.None)
    
    self.techTree:AddSpecial(kTechId.TwoHives)
    self.techTree:AddResearchNode(kTechId.AlienArmor2,           kTechId.TwoHives,             kTechId.None)
    
    // Tier 3
    self.techTree:AddResearchNode(kTechId.Xenocide,            kTechId.Leap,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Umbra,            kTechId.Spikes,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.WebStalk,            kTechId.BileBomb,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Vortex,            kTechId.Blink,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.PrimalScream,            kTechId.Stomp,        kTechId.None)
    
    self.techTree:AddSpecial(kTechId.ThreeHives)    
    self.techTree:AddResearchNode(kTechId.AlienArmor3,           kTechId.ThreeHives,           kTechId.None)
    
    // Global alien upgrades. Make sure the first prerequisite is the main tech required for it, as this is 
    // what is used to display research % in the alien evolve menu.
    // The second prerequisite is needed to determine the buy node unlocked when the upgrade is actually researched.
    self.techTree:AddBuyNode(kTechId.Carapace, kTechId.CarapaceShell, kTechId.None, kTechId.AllAliens)    
    self.techTree:AddBuyNode(kTechId.Regeneration, kTechId.RegenerationShell, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Silence, kTechId.SilenceVeil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Camouflage, kTechId.CamouflageVeil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Celerity, kTechId.CeleritySpur, kTechId.None, kTechId.AllAliens)    
    self.techTree:AddBuyNode(kTechId.HyperMutation, kTechId.HyperMutationSpur, kTechId.None, kTechId.AllAliens)
    
    // Specific alien upgrades
    self.techTree:AddBuildNode(kTechId.Hydra,               kTechId.None,               kTechId.None)
    
    self.techTree:SetComplete()
	
end

if(HotReload) then
    CombatAlienTeam:OnLoad()
end