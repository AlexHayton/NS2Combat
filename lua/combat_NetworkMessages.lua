//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________


// custom NetworkMessages for the combat mod (for telling client if the mode is active or not)
Script.Load("lua/combat_ExperienceEnums.lua")

local kCombatModeActiveMessage =
{
    combatMode = "boolean"
}
Shared.RegisterNetworkMessage("CombatModeActive", kCombatModeActiveMessage)

local kCombatUpgradeCountUpdateMessage =
{
    upgradeId = "enum kCombatUpgrades",
	upgradeCount = "integer"
}
Shared.RegisterNetworkMessage("CombatUpgradeCountUpdate", kCombatUpgradeCountUpdateMessage)

if Server then

    function SendCombatModeActive(client, activeBool)   

        if client then       
            Server.SendNetworkMessage(client:GetControllingPlayer(), "CombatModeActive", { combatMode = activeBool }, true)
        end   
     
    end
	
	function BuildCombatUpgradeCountUpdate(messageUpgradeId, messageUpgradeCount)
	
		return { upgradeId = messageUpgradeId,
				 upgradeCount = messageUpgradeCount }
	
	end
	
	function SendCombatUpgradeCountUpdate(player, upgradeId, upgradeCount)
		
        if player then
			local message = BuildCombatUpgradeCountUpdate(upgradeId, upgradeCount)
            Server.SendNetworkMessage(player, "CombatUpgradeCountUpdate", message, true)
        end
     
    end
    
elseif Client then

    function GetCombatModeActive(messageTable)

        kCombatModActive = messageTable.combatMode
        
        if kCombatModActive == false or kCombatModActive == nil then
            // remove all hooks so we got a classic ns
            if globalHookTable then
                for i,hook in ipairs(globalHookTable) do
                    ClassHooker:RemoveHook(hook)
                end

                globalHookTable = {}
                
            end        
        else    
            // load EXP bar and other functions, variables etc.
            combatLoadClientFunctions()
            GetGUIManager():CreateGUIScriptSingle("Hud/combat_GUIExperienceBar")
        end
        
    end
    
    Client.HookNetworkMessage("CombatModeActive", GetCombatModeActive)
	
	// Upgrade the counts for this upgrade Id.
	function GetUpgradeCountUpdate(messageTable)

		if (kCombatUpgradeCounts == nil) then 
			kCombatUpgradeCounts = {}
		end
		kCombatUpgradeCounts[messageTable.upgradeId] = messageTable.upgradeCount
        
    end
    
    Client.HookNetworkMessage("CombatUpgradeCountUpdate", GetUpgradeCountUpdate)
    
end


// creates a global hook table that we can Remove all hooks, if necessary
function _addHookToTable(hook)

    if not globalHookTable then
        globalHookTable = {}
    end

    table.insert(globalHookTable , hook)

end