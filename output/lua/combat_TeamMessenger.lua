//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_TeamMessenger.lua

local HotReload = CombatTeamMessenger
if(not HotReload) then
  CombatTeamMessenger = {}
  ClassHooker:Mixin("CombatTeamMessenger")
end

function CombatTeamMessenger:OnLoad()

	self:ReplaceFunction("SendTeamMessage", "SendTeamMessage_Hook")
	
end

// Intercept and block any 'No Commander' messages, Hooking caused errors so we replace it
function CombatTeamMessenger:SendTeamMessage_Hook(team, messageType, optionalData)

    local function SendToPlayer(player)
        Server.SendNetworkMessage(player, "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
    end    
    
	// Only intercept NoCommander messages, for now.
    if not ((messageType == kTeamMessageTypes.NoCommander) or
			(messageType == kTeamMessageTypes.CannotSpawn)) then
			
		team:ForEachPlayer(SendToPlayer)
		
	end
	
end

if (not HotReload) then
	CombatTeamMessenger:OnLoad()
end
