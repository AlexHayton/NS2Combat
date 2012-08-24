//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Utility.lua

if(not CombatUtility) then
    CombatUtility = {}
end

ClassHooker:Mixin("CombatUtility")

// Leave this to false unless we're trying to fix something
kDebugPrecache = true

function CombatUtility:OnLoad()

	ClassHooker:SetClassCreatedIn("EffectManager", "lua/EffectManager.lua")
	self:RawHookClassFunction("EffectManager", "PrecacheEffects", "PrecacheEffects_Hook")
   
    self:RawHookFunction("PrecacheAsset", "PrecacheAsset_Hook"):SetPassHandle(true)
	
end

// Big list of allowed assets goes here...
// Worst case scenario, we are eliminating unneeded resources here.
// The code should allow non-precached resources to be played, 
// but it may slow down the game on first play if they are not listed here.
local allowedAssets = {}

local function ProcessEffectsList(effectList) 

	for i, assetClass in pairs(effectList) do
		for j, assetName in pairs(assetClass) do
			for k, assetValue in pairs(assetName) do
				if type(assetValue) == "string" then
					allowedAssets[assetValue] = false
				end
			end
		end
	end
	
end

function CombatUtility:PrecacheEffects_Hook(self)

	// Process the effect lists...
	ProcessEffectsList(kAlienStructureEffects)
	ProcessEffectsList(kAlienWeaponEffects)
	ProcessEffectsList(kClientEffectData)
	ProcessEffectsList(kDamageEffects)
	ProcessEffectsList(kGeneralEffectData)

end

function CombatUtility:LoadAssetList()
	
	// Alien
	for i, asset in pairs(Alien) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	allowedAssets["sound/NS2.fev/alien/common/celerity_loop"] = false

	// Alien_Client
	allowedAssets["cinematics/alien/hit_1p.cinematic"] = false

	// AlienBuy_Client
	// These sounds are processed with PrecacheLocalSound so no need to add here.

	// AlienCommander
	// Bare minimum here.
	allowedAssets[AlienCommander.kStructureUnderAttackSound] = false
	allowedAssets[AlienCommander.kLifeformUnderAttackSound] = false
	allowedAssets[AlienCommander.kHealTarget] = false

	// AmmoPack
	for i, asset in pairs(AmmoPack) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end

	// Armory
	for i, asset in pairs(Armory) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	allowedAssets["models/marine/armory/armory.animation_graph"] = false

	// Babbler
	for i, asset in pairs(Babbler) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	
	// Badge
	allowedAssets["ui/badge_pax2012.dds"] = false

	// CatPacks
	for i, asset in pairs(CatPack) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	
	// Clog
	for i, asset in pairs(Clog) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	
	// CommandStation
	for i, asset in pairs(CommandStation) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	allowedAssets["models/marine/command_station/command_station.animation_graph"] = false
	
	// Skipped Crag
	// Skipped Cyst
	
	// Door
	for i, asset in pairs(Door) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	allowedAssets["models/misc/door/door.model"] = false
	allowedAssets["models/misc/door/door_clean.model"] = false
	allowedAssets["models/misc/door/door_destroyed.model"] = false
	allowedAssets["models/misc/door/door.animation_graph"] = false
	
	// Egg
	for i, asset in pairs(Egg) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	
	// Embryo
	for i, asset in pairs(Embryo) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	
	// Exo
	for i, asset in pairs(Exo) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	
	// Fade
	for i, asset in pairs(Fade) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	allowedAssets["models/alien/fade/fade.animation_graph"] = false
	
	// Fire
	allowedAssets["cinematics/marine/flamethrower/burn_big.cinematic"] = false
	allowedAssets["cinematics/marine/flamethrower/burn_huge.cinematic"] = false
	allowedAssets["cinematics/marine/flamethrower/burn_med.cinematic"] = false
	allowedAssets["cinematics/marine/flamethrower/burn_small.cinematic"] = false
	allowedAssets["cinematics/marine/flamethrower/burn_1p.cinematic"] = false
	
	// Fonts (located in multiple files)
	allowedAssets["fonts/AgencyFB_small.fnt"] = false
	allowedAssets["fonts/AgencyFB_medium.fnt"] = false
	allowedAssets["fonts/AgencyFB_large.fnt"] = false
	allowedAssets["fonts/AgencyFB_huge.fnt"] = false
	allowedAssets["fonts/Kartika_small.fnt"] = false
	allowedAssets["fonts/Kartika_medium.fnt"] = false
	allowedAssets["fonts/Kartika_large.fnt"] = false
	allowedAssets["fonts/Kartika_huge.fnt"] = false
	allowedAssets["fonts/MicrogrammaDMedExt_small.fnt"] = false
	allowedAssets["fonts/MicrogrammaDMedExt_medium.fnt"] = false
	allowedAssets["fonts/MicrogrammaDMedExt_large.fnt"] = false
	allowedAssets["fonts/MicrogrammaDMedExt_huge.fnt"] = false
	allowedAssets["fonts/Stamp_small.fnt"] = false
	allowedAssets["fonts/Stamp_medium.fnt"] = false
	allowedAssets["fonts/Stamp_large.fnt"] = false
	allowedAssets["fonts/Stamp_huge.fnt"] = false

	// Gorge
	for i, asset in pairs(Gorge) do
		if type(asset) == "string" then
			allowedAssets[asset] = false
		end
	end
	allowedAssets["models/alien/gorge/gorge_view.model"] = false
	allowedAssets["models/alien/gorge/gorge.animation_graph"] = false
	
	// GUI (used in multiple files)
	allowedAssets["ui/hud_elements.dds"] = false
	
	// GUIActionIcon
	allowedAssets["ui/pickup_icons.dds"] = false
	allowedAssets["ui/key_mouse_marine.dds"] = false
	
	// GUIAlienBuyMenu
	/*if (Client) then
		for i, asset in pairs(GUIAlienBuyMenu) do
			if type(asset) == "string" then
				allowedAssets[asset] = false
			end
		end
	end*/
	
	// GUIAlienHUD
	allowedAssets["ui/alien_hud_health.dds"] = false
	allowedAssets["ui/alien_abilities.dds"] = false
	allowedAssets["ui/ui_smoke_tile.dds"] = false
	
	// GUIAlienTeamMessage
	allowedAssets["ui/objective_banner_alien.dds"] = false
	allowedAssets["ui/ui_smoke_tile.dds"] = false
	
	// GUIBulletDisplay
	allowedAssets["ui/RifleDisplay.dds"] = false
	
	// GUICountDownDisplay
	/*if (Client) then
		for i, asset in pairs(GUICountDownDisplay) do
			if type(asset) == "string" then
				allowedAssets[asset] = false
			end
		end
	end*/

	// GUICrosshair
	allowedAssets["ui/crosshairicons.dds"] = false
	allowedAssets["ui/crosshairs-hit.dds"] = false
	
	// GUIDeathMessages
	allowedAssets["ui/marine_messages_icons.dds"] = false
	
	// GUIDeathScreen
	allowedAssets["ui/messages_icons.dds"] = false
	
	// GUIEggDisplay
	allowedAssets["ui/Skulk.dds"] = false
	allowedAssets["ui/Gorge.dds"] = false
	allowedAssets["ui/Lerk.dds"] = false
	allowedAssets["ui/Fade.dds"] = false
	allowedAssets["ui/Onos.dds"] = false
	
	// GUIEvolveHelp
	allowedAssets["ui/map-icon-evolution.dds"] = false
	
	// GUIExoArmorDisplay
	allowedAssets["models/marine/exosuit/exosuit_view_panel_armor.dds"] = false
	
	// GUIFlamethrowerDisplay
	allowedAssets["ui/FlamethrowerDisplay.dds"] = false
	
	// GUIGameEnd
	allowedAssets["ui/alien_victory.dds"] = false
	allowedAssets["ui/marine_victory.dds"] = false
	allowedAssets["ui/alien_defeat.dds"] = false
	allowedAssets["ui/marine_defeat.dds"] = false
	
	// GUIGorgeBuildMenu
	allowedAssets["sound/NS2.fev/alien/common/alien_menu/hover"] = false
	allowedAssets["sound/NS2.fev/alien/common/alien_menu/evolve"] = false
	allowedAssets["sound/NS2.fev/alien/common/alien_menu/sell_upgrade"] = false

	// GUIHealthCircle
	allowedAssets["ui/health_circle.dds"] = false
	allowedAssets["ui/health_circle_alien.dds"] = false
	
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	allowedAssets[AmmoPack.kModelName] = false
	
	if kDebugPrecache then
		RawPrint("Outputting Precached files for Debug...")
		for asset, value in pairs(allowedAssets) do
			local assetName = asset
			RawPrint("	allowedAssets[\"" .. assetName .. "\"] = false")
		end
	end
end

// Only precache a certain subset of assets
function CombatUtility:PrecacheAsset_Hook(handle, effectName)

	if allowedAssets[effectName] == nil then
		if kDebugPrecache then
			RawPrint("\"" .. effectName .. "\" tried to precache but blocked by NS2Combat asset management code.")
		end
		
		handle:SetReturn("")
	else
		// Flag the asset as having been accessed so we can prune the irrelevant ones.
		allowedAssets[effectName] = true
	end

end