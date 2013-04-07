//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcOnosMixin = CreateMixin( NpcOnos )
NpcOnosMixin.type = "NpcMarine"

NpcOnosMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcOnosMixin.expectedCallbacks =
{
}


NpcOnosMixin.networkVars =  
{
}


function NpcOnosMixin:__initmixin()   
end

function NpcOnosMixin:GetAttackDistanceOverride()
    return 2.2
end

function NpcOnosMixin:CheckImportantEvents()
end





