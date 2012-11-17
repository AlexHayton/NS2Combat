//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Locale.lua

// Replace the normal Locale.ResolveString with our own version!
if Locale then
	if Locale.ResolveString then
		local NS2ResolveFunction = Locale.ResolveString

		function Combat_ResolveString(input)

			local resolvedString = nil
			if (kCombatLocaleMessages) then
				if (kCombatLocaleMessages[input] ~= nil) then
					resolvedString = kCombatLocaleMessages[input]
				end
			end
			
			if (resolvedString == nil) then
				resolvedString = NS2ResolveFunction(input)
			end
			
			return resolvedString

		end

		Locale.ResolveString = Combat_ResolveString
	end
end