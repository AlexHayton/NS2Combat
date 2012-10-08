//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Marine.lua



class 'CombatAlien' (Alien)

CombatAlien.kMapName = "combatalien"


local networkVars =
{
}


function CombatAlien:OnCreate()

    Marine.OnCreate(self)
    
    
end

function CombatAlien:OnInitialized()
    
    Marine.OnInitialized(self)
    
end


Shared.LinkClassToMap("CombatAlien", CombatAlien.kMapName, networkVars)