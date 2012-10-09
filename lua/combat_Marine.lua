//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Marine.lua



class 'CombatMarine' (Marine)

CombatMarine.kMapName = "combatmarine"


local networkVars =
{
}


function CombatMarine:OnCreate()

    Marine.OnCreate(self)
    
    
end

function CombatMarine:OnInitialized()
    
    Marine.OnInitialized(self)

end


Shared.LinkClassToMap("CombatMarine", CombatMarine.kMapName, networkVars)