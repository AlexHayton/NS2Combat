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
    combatMode = "boolean",
    combatCompMode = "boolean",
    combatAllowOvertime = "boolean"
}
Shared.RegisterNetworkMessage("CombatModeActive", kCombatModeActiveMessage)

local kCombatUpgradeCountUpdateMessage =
{
    upgradeId = "enum kCombatUpgrades",
	upgradeCount = "integer"
}
Shared.RegisterNetworkMessage("CombatUpgradeCountUpdate", kCombatUpgradeCountUpdateMessage)

local kCombatGameTimeMessage =
{
    timeSinceGameStart = "float",
	gameTimeLimit = "integer"
}
Shared.RegisterNetworkMessage("CombatGameTimeUpdate", kCombatGameTimeMessage)

local kCombatSetUpgradeMessage =
{
	upgradeId = "integer"
}
Shared.RegisterNetworkMessage("CombatSetUpgrade", kCombatSetUpgradeMessage)

local kCombatSetLvlUpMessage =
{
}
Shared.RegisterNetworkMessage("CombatLvlUp", kCombatSetLvlUpMessage)


if Server then

    function SendCombatModeActive(client, activeBool, compActiveBool, overtimeActiveBool)

        if client then       
            Server.SendNetworkMessage(client:GetControllingPlayer(), "CombatModeActive", { combatMode = activeBool, combatCompMode = compActiveBool, combatAllowOvertime = overtimeActiveBool }, true)
        end   
     
    end
	
	function BuildCombatUpgradeCountMessage(messageUpgradeId, messageUpgradeCount)
	
		return { upgradeId = messageUpgradeId,
				 upgradeCount = messageUpgradeCount }
	
	end
	
	function SendCombatUpgradeCountUpdate(player, upgradeId, upgradeCount)
		
        if player then
			local message = BuildCombatUpgradeCountMessage(upgradeId, upgradeCount)
            Server.SendNetworkMessage(player, "CombatUpgradeCountUpdate", message, true)
        end
     
    end
	
	function BuildCombatGameTimeMessage(timeSinceGameStartFloat, gameTimeLimitInt)
	
		return { timeSinceGameStart = timeSinceGameStartFloat,
				 gameTimeLimit = gameTimeLimitInt }
	
	end
	
	function SendCombatGameTimeUpdate(player)
		
        if player then
			local timeSinceGameStart = GetGamerules():GetGameTimeChanged()
			local message = BuildCombatGameTimeMessage(timeSinceGameStart, tonumber(kCombatTimeLimit))
            Server.SendNetworkMessage(player, "CombatGameTimeUpdate", message, true)
        end
     
    end
	
	function BuildCombatSetUpgradeMessage(messageUpgradeId)
	
		return { upgradeId = messageUpgradeId, }
	
	end
	
	function SendCombatSetUpgrade(player, upgradeId)
		
        if player then
			local message = BuildCombatSetUpgradeMessage(upgradeId)
            Server.SendNetworkMessage(player, "CombatSetUpgrade", message, true)
        end
     
    end
    
    function SendCombatLvlUp(player)
		
        if player then
			local message = {}
            Server.SendNetworkMessage(player, "CombatLvlUp", message, true)
        end
     
    end
    
elseif Client then

    function GetCombatModeActive(messageTable)

        kCombatModActive = messageTable.combatMode
        kCombatCompMode = messageTable.combatCompMode
        kCombatAllowOvertime = messageTable.combatAllowOvertime
        
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
			GetGUIManager():CreateGUIScriptSingle("Hud/combat_GUIGameTimeCountDown")
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
	
	// Upgrade the counts for this upgrade Id.
	function GetCombatGameTimeUpdate(messageTable)

		kCombatTimeSinceGameStart = messageTable.timeSinceGameStart
		kCombatTimeLimit =  messageTable.gameTimeLimit
        
    end
    Client.HookNetworkMessage("CombatGameTimeUpdate", GetCombatGameTimeUpdate)
	
	function GetCombatSetUpgrade(messageTable)

		// insert the ids in the personal player table
		local player = Client.GetLocalPlayer()
		
		if not player.combatUpgrades then
			player.combatUpgrades = {}
		end
		
		table.insert(player.combatUpgrades, messageTable.upgradeId)
        
    end
    Client.HookNetworkMessage("CombatSetUpgrade", GetCombatSetUpgrade)
    
    function GetCombatLvlUp(messageTable)
		local player = Client.GetLocalPlayer()
        player:LevelUpMessage()
    end
    Client.HookNetworkMessage("CombatLvlUp", GetCombatLvlUp)
    
end
