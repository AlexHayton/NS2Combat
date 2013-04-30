//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcSkulkMixin = CreateMixin( NpcSkulkMixin )
NpcSkulkMixin.type = "NpcSkulk"

NpcSkulkMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcSkulkMixin.expectedCallbacks =
{
}


NpcSkulkMixin.networkVars =  
{
}


function NpcSkulkMixin:__initmixin()   
end


function NpcSkulkMixin:CheckImportantEvents()
end


function NpcSkulkMixin:EngagementPointOverride(target)
    // attack exos at origin
    if target:isa("Exo") then
        return target:GetOrigin()
    end
end



