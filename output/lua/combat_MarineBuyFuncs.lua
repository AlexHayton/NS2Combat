//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_MarineBuyFuncs.lua
      
// helper Functions for the List, text etc  

// headlines for the Buymenu
function CombatMarineBuy_GetHeadlines()

    headlines = {
        "Support",
        "Weapons",        
        "Weapon Ups",
        "Armor Ups",
        "Class Ups",
    }
    
    return headlines
    
end

// costum sort function that the ups to look good
function CombatMarineBuy_GUISortUps(upgradeList)

// max 4 rows per column
    local layoutList = {
        // 0, Support
        "nextRow",
        kTechId.MedPack,
	    kTechId.CatPack,
        kTechId.Scan,
        kTechId.LayMines,
        "nextRow",

        // 1, Weapons
        kTechId.Shotgun,
        kTechId.GrenadeLauncher,
        kTechId.Flamethrower,
        kTechId.MACEMP,
        "nextRow",
        
        // 2, Weapon Upgrades 
        kTechId.Weapons1,
        kTechId.Weapons2,
        kTechId.Weapons3,
	    kTechId.Rifle,
        "nextRow",

        // 3, Armor Upgrades
        kTechId.Armor1,
        kTechId.Armor2,
        kTechId.Armor3,
        kTechId.Welder,
        "nextRow",
		
        // 4, Class Upgrades
        kTechId.Jetpack,     
	    kTechId.DualMinigunExosuit,
	    kTechId.ClawRailgunExosuit,
    }
    
    local sortedList = {}    
    // search the techID in the Uplist and copy it to its correct place
    for i, entry in ipairs(layoutList) do
        if (entry  == "nextRow") then
            table.insert(sortedList, "nextRow")
        else
            for i, upgrade in ipairs(upgradeList) do
                if upgrade:GetTechId() == entry then
                    table.insert(sortedList, upgrade)
                    break
                end
            end
        end
    end
    
    return sortedList
end

function CombatMarineBuy_GetWeaponDescription(techId)

    if not combatWeaponDescription then
    
        combatWeaponDescription = {}
        
        combatWeaponDescription[kTechId.MedPack] = "You get Resupply. Ammo and Medpacks will drop for you every " .. kResupplyTimer .. " seconds."
        combatWeaponDescription[kTechId.Scan] = "You get a Scanner. A scan will appear every " .. kScanTimer .. " seconds, showing all enemies nearby."
        combatWeaponDescription[kTechId.Welder] = "You get a Welder. You can repair your team's buildings or your teammates' Armor."
        combatWeaponDescription[kTechId.LayMines] = "You get 1 Mine to use each time you die."
        combatWeaponDescription[kTechId.MACEMP] =  "Your Taunt key will activate a powerful EMP-Blast that cripples enemies' energy reserves. Can be activated once every " .. kEMPTimer .. " seconds."
		combatWeaponDescription[kTechId.CatPack] =  "You get Catalyst Packs. They make you move faster when time you shoot or taking damage. Activated once every " .. kCatalystTimer .. " seconds."
        
        combatWeaponDescription[kTechId.Axe] = "Here's Johnny!"
        combatWeaponDescription[kTechId.Pistol] = "TSA standard issue pistol. This weapon packs a surprising punch and is good when you run out of ammunition for your main weapon."
        combatWeaponDescription[kTechId.Rifle] = "TSA standard issue rifle. This standby is an all-around versatile weapon at most ranges. While slightly heavier than previous models, it can still be effective in the field when you're low on ammo with a rifle butt."
        combatWeaponDescription[kTechId.Shotgun] = "You get a Shotgun, but you need Weapons 1 first."
        combatWeaponDescription[kTechId.Flamethrower] = "You get a Flamethrower, but you need a Shotgun first."
        combatWeaponDescription[kTechId.GrenadeLauncher] = "You get a Flamethrower, but you need a Shotgun first."
        
        combatWeaponDescription[kTechId.Weapons1] = "Weapons 1 tech Upgrade. Increases the damage of your weapons."
        combatWeaponDescription[kTechId.Weapons2] = "Weapons 2 tech Upgrade. Increases the damage of your weapons. You need Weapons 1 first..."
        combatWeaponDescription[kTechId.Weapons3] = "Weapons 3 tech Upgrade. Increases the damage of your weapons. You need Weapons 2 first..."
		combatWeaponDescription[kTechId.AdvancedWeaponry] = "Doubles the reload speed of all of your weapons."
        
        combatWeaponDescription[kTechId.Armor1] = "Armor 1 tech Upgrade. Substantially increases your armor."
        combatWeaponDescription[kTechId.Armor2] = "Armor 2 tech Upgrade. Substantially increases your armor. You need Armor 1 first..."
        combatWeaponDescription[kTechId.Armor3] = "Armor 3 tech Upgrade. Substantially increases your armor. You need Armor 2 first..."

        combatWeaponDescription[kTechId.Jetpack] = "You get a Jetpack, but you need Armor 2 first..."
        combatWeaponDescription[kTechId.Exosuit] = "Suit up! You will need Armor 2 first..."
		combatWeaponDescription[kTechId.DualMinigunExosuit] = "Dual Miniguns for the Exosuit."
		combatWeaponDescription[kTechId.ClawRailgunExosuit] = "RailGun with a Claw for the Exosuit."
    
    end
    
    local description = combatWeaponDescription[techId]
    if not description then
        description = ""
    end
    
    return description

end