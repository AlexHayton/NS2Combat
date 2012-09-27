//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_TeamMixin.lua

// Draw rising damage indicator if we damaged someone
function TeamMixin:OnTakeDamageClient(damage, doer, point)

    if Client and Client.GetLocalPlayer() and not Shared.GetIsRunningPrediction() then
    
        local player = Client.GetLocalPlayer()
		
		// Damage scalar for focus.
		if player:GotItemAlready(GetUpgradeFromId(kCombatUpgrades.Focus)) and damage ~= nil then
			damage = damage * kCombatFocusDamageScalar
		end
        
        if doer and (doer == player or doer:GetParent() == player) and GetAreEnemies(doer,self) then
            Client.AddWorldMessage(kWorldTextMessageType.Damage, ToString(math.round(damage)), point, self:GetId())
        end
        
    end
    
end