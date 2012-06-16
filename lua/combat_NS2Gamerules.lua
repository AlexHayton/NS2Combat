//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_NS2Gamerules.lua

if(not CombatNS2Gamerules) then
  CombatNS2Gamerules = {}
end

local HotReload = ClassHooker:Mixin("CombatNS2Gamerules")

function CombatNS2Gamerules:OnLoad()

    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua")
    self:PostHookClassFunction("NS2Gamerules", "JoinTeam", "JoinTeam_Hook")
	
end

// Free the lvl when changing Teams
function CombatNS2Gamerules:JoinTeam_Hook(self, player, newTeamNumber, force)

    if player.combatTable then
        if player.combatTable.techtree[1] then
             // give the Lvl back
            player.combatTable.lvlfree = player.combatTable.lvlfree +  player.combatTable.lvl - 1
            // clear the techtree
            player.combatTable.techtree = {}
			player.resources = 999
		end
    else
        player.combatTable = {}  
        player.combatTable.xp = 0
        player.combatTable.lvl = 1
        player.combatTable.lvlfree = 0
        
        // save every Update in the personal techtree
        player.combatTable.techtree = {}
        
       if GetGamerules():GetGameStarted() then
            // get AvgXp                  
            player:AddXp(player:GetAvgXp(table.maxn(GetGamerules().team1.playerIds)))
            // Priting the avg xp to the Server Console for testing
            Print(player:GetAvgXp(table.maxn(GetGamerules().team1.playerIds)))
        end    
    end

end

if(HotReload) then
    CombatNS2Gamerules:OnLoad()
end