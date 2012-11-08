//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Utility.lua

// Used to send messages to all players.
function SendGlobalChatMessage(message)
	local allPlayers = Shared.GetEntitiesWithClassname("Player")
	for index, player in ientitylist(allPlayers) do
		player:SendDirectMessage(message)
	end
	
	// Also output to the console for admins.
	Shared.Message(message)
end

function GetTimeText(timeInSeconds)

	local timeLeftText = ""
	timeNumericSeconds = tonumber(timeInSeconds)
	ASSERT(timeNumericSeconds >= 0)
	if (timeNumericSeconds > 60) then
		timeLeftText = math.ceil(timeNumericSeconds/60) .." minutes"
	elseif (timeNumericSeconds == 60) then
		timeLeftText = "1 minute"
	elseif (timeNumericSeconds == 1) then
		timeLeftText = "1 second"
	else
		timeLeftText = timeNumericSeconds .." seconds"
	end
	return timeLeftText

end