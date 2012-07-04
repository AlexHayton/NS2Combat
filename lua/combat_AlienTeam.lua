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
	self:ReplaceClassFunction("AlienTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
	self:ReplaceClassFunction("AlienTeam", "GetNumHives","GetNumHives_Hook")
	
end

function CombatAlienTeam:InitTechTree_Hook(self)

	PlayingTeam.InitTechTree(self)
    
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
    self.techTree:AddOrder(kTechId.AlienConstruct)
    self.techTree:AddOrder(kTechId.Heal)
    
    // Commander abilities
    self.techTree:AddBuildNode(kTechId.Cyst,                kTechId.None,           kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.NutrientMist,     kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.InfestationSpike,    kTechId.None,           kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.EnzymeCloud,      kTechId.None,           kTechId.None)
    self.techTree:AddAction(kTechId.Rupture,                      kTechId.None,           kTechId.None)
           
    // Hive types
    self.techTree:AddBuildNode(kTechId.Hive,                    kTechId.None,           kTechId.None)
    self.techTree:AddPassive(kTechId.HiveHeal)
    
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

    // Hallucinations
    self.techTree:AddManufactureNode(kTechId.HallucinateDrifter,  kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateSkulk,    kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateGorge,    kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateLerk,     kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateFade,     kTechId.None,   kTechId.None)
    self.techTree:AddManufactureNode(kTechId.HallucinateOnos,     kTechId.None,   kTechId.None)
    
    self.techTree:AddBuildNode(kTechId.HallucinateHive,           kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateWhip,           kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateShade,          kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateCrag,           kTechId.CragHive,       kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateShift,          kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateHarvester,      kTechId.None,           kTechId.None)
    self.techTree:AddBuildNode(kTechId.HallucinateHydra,          kTechId.None,           kTechId.None)
    
    // Tier 2
    self.techTree:AddResearchNode(kTechId.Leap,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Spikes,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.BileBomb,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Blink,            kTechId.None,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Stomp,            kTechId.None,              kTechId.None)

    // Tier 3
     
    self.techTree:AddResearchNode(kTechId.Xenocide,            kTechId.Leap,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Umbra,            kTechId.Spikes,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.WebStalk,            kTechId.BileBomb,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.Vortex,            kTechId.Blink,              kTechId.None)
    self.techTree:AddResearchNode(kTechId.PrimalScream,            kTechId.Stomp,        kTechId.None)   

    // Global alien upgrades. Make sure the first prerequisite is the main tech required for it, as this is 
    // what is used to display research % in the alien evolve menu.
    // The second prerequisite is needed to determine the buy node unlocked when the upgrade is actually researched.
    self.techTree:AddResearchNode(kTechId.Carapace, kTechId.None, kTechId.None, kTechId.None)    
    self.techTree:AddResearchNode(kTechId.Regeneration, kTechId.None, kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Silence, kTechId.None, kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Aura, kTechId.None, kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Celerity, kTechId.None, kTechId.None, kTechId.None)    
    self.techTree:AddResearchNode(kTechId.HyperMutation, kTechId.None, kTechId.None, kTechId.None)
	self.techTree:AddResearchNode(kTechId.Shade, kTechId.None, kTechId.None, kTechId.None)
    
    // Specific alien upgrades
    self.techTree:AddBuildNode(kTechId.Hydra,               kTechId.None,               kTechId.None)
    
    
    //self.techTree:AddBuyNode(kTechId.Sap, kTechId.SapTech, kTechId.TwoHives, kTechId.Fade)
    
    //self.techTree:AddResearchNode(kTechId.BoneShieldTech, kTechId.Crag, kTechId.TwoHives)
    //self.techTree:AddBuyNode(kTechId.BoneShield, kTechId.BoneShieldTech, kTechId.None, kTechId.Onos)
    
    self.techTree:SetComplete()
	
end

// No cysts
function CombatAlienTeam:SpawnInitialStructures_Hook(self, techPoint)

    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()    
   
    return tower, hive
    
end


function CombatAlienTeam:GetNumHives_Hook()

    return 6
    
end

if(HotReload) then
    CombatAlienTeam:OnLoad()
end