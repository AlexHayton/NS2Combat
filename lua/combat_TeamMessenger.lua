//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_TeamMessenger.lua

if(not CombatTeamMessenger) then
  CombatTeamMessenger = {}
end

local HotReload = ClassHooker:Mixin("CombatTeamMessenger")

function CombatTeamMessenger:OnLoad()

	self:RawHookFunction("SendTeamMessage", "SendTeamMessage_Hook", PassHookHandle)
	
end

// Intercept and block any 'No Commander' messages.
function CombatTeamMessenger:SendTeamMessage_Hook(hookHandle, team, messageType, optionalData)

	// Only intercept NoCommander messages, for now.
    if (messageType == kTeamMessageTypes.NoCommander) then
		return team, nil, optionalData
	end
	
	return team, messageType, optionalData
	
end

if(HotReload) then
    CombatTeamMessenger:OnLoad()
end