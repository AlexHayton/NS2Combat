//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/Class.lua")
Script.Load("lua/Team.lua")

// modded to stop the "Couldnt find ..." print
// Overrides the function so its not printing "system" all the time

local overrideTeamForEachPlayer 
overrideTeamForEachPlayer  = Class_ReplaceMethod( "Team", "ForEachPlayer", 
    function (self, functor)
        for i, playerIndex in ipairs(self.playerIds) do
        
            local player = Shared.GetEntity(playerIndex)
            if player ~= nil and player:isa("Player") then
                functor(player)
            else
                table.remove(self.playerIds, i)
            end
            
        end
    end
)