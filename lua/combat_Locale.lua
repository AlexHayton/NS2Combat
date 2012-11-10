//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Locale.lua

function Combat_ResolveString(input)

	local resolvedString = nil
	if (kCombatLocaleMessages) then
		if (kCombatLocaleMessages[input] ~= nil) then
			resolvedString = kCombatLocaleMessages[input]
		end
	end
	
	if (resolvedString == nil) then
		resolvedString = Locale.ResolveString(input)
	end
	
	return resolvedString

end
