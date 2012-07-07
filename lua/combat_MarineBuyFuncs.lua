//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_MarineBuyFuncs.lua
      
// helper Functions for the List, text etc  

// costum sort function that the ups to look good
function CombatMarineBuy_GUISortUps(upgradeList)

// max 4 rows per column
    local layoutList = {
        // 0
        kTechId.MedPack,
        kTechId.Scan,
        kTechId.LayMines,
        kTechId.Welder,
        "nextRow",

        // 1
        kTechId.Shotgun,
        kTechId.GrenadeLauncher,
        kTechId.Flamethrower,
        "nextRow",
        
        // 2 
        kTechId.Weapons1,
        kTechId.Weapons2,
        kTechId.Weapons3,
        "nextRow",

        // 3
        kTechId.Armor1,
        kTechId.Armor2,
        kTechId.Armor3,
        "nextRow",
        // 4
        kTechId.Jetpack,     
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


function CombatMarineBuy_GetDisplayName(techId)

    if techId ~= nil then
        // special String for Medpack ( to show "Resupply")
        if techId == kTechId.MedPack then
            return "Resupply"
        else
            return Locale.ResolveString(LookupTechData(techId, kTechDataDisplayName, ""))
        end
    else
        return ""
    end
    
end


function CombatMarineBuy_GetWeaponDescription(techId)

    if not combatWeaponDescription then
    
        combatWeaponDescription = {}
        
        combatWeaponDescription[kTechId.MedPack] = "You get Resupply. Ammo and Medpacks will drop for you after some time."
        combatWeaponDescription[kTechId.Scan] = "You get Scansupply. A scan will appear after some time and shows all enemys nearby"
        combatWeaponDescription[kTechId.Welder] = "You get a Welder. You can repair buildings or the Armor from Teammates"
        combatWeaponDescription[kTechId.LayMines] = "You get 1 Mine."
        
        combatWeaponDescription[kTechId.Axe] = "Axe description."
        combatWeaponDescription[kTechId.Pistol] = "Pistol description."
        combatWeaponDescription[kTechId.Rifle] = "TSA standard issue rifle. This standby is an all-around versatile weapon at most ranges. While slightly heavier than previous models, it can still be effective in the field when you're low on ammo with a rifle butt."
        combatWeaponDescription[kTechId.Shotgun] = "You get a Shotgun, but you need Weapons 1 first"
        combatWeaponDescription[kTechId.Flamethrower] = "You get a Flamethrower, but you need a Shotgun first"
        combatWeaponDescription[kTechId.GrenadeLauncher] = "You get a Flamethrower, but you need a Shotgun first"
        
        combatWeaponDescription[kTechId.Weapons1] = "Weapons 1 tech Upgrade."
        combatWeaponDescription[kTechId.Weapons2] = "Weapons 2 tech Upgrade. You need Weapons 1 first"
        combatWeaponDescription[kTechId.Weapons3] = "Weapons 3 tech Upgrade. You need Weapons 2 first"
        
        combatWeaponDescription[kTechId.Armor1] = "Armor 1 tech Upgrade."
        combatWeaponDescription[kTechId.Armor2] = "Armor 2 tech Upgrade. You need Armor 1 first"
        combatWeaponDescription[kTechId.Armor3] = "Armor 3 tech Upgrade. You need Armor 2 first"

        combatWeaponDescription[kTechId.Jetpack] = "You get a Jetpack, but you need Armor 2 first."
        combatWeaponDescription[kTechId.Exosuit] = "Exosuit description."
    
    end
    
    local description = combatWeaponDescription[techId]
    if not description then
        description = ""
    end
    
    return description

end