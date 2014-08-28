//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcFadeMixin = CreateMixin( NpcFadeMixin )
NpcFadeMixin.type = "NpcFade"

NpcFadeMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcFadeMixin.expectedCallbacks =
{
}


NpcFadeMixin.networkVars =  
{
}


function NpcFadeMixin:__initmixin()   
end

function NpcFadeMixin:GetAttackDistanceOverride()
    return SwipeBlink.kRange
end

function NpcFadeMixin:CheckImportantEvents()
end





