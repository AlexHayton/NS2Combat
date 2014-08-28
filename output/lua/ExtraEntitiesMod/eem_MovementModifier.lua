//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/Class.lua")

if Server then

    // overrides OnJumpLand so the ClampSpeed can work right
    local originalPlayerOnGroundChanged = Player.OnGroundChanged
	function Player:OnGroundChanged(onGround, landIntensity, normal, velocity)        
		if onGround then
			if self.pushTime == -1 then
				self.pushTime = 0
			elseif kFallDamage then
				if landIntensity >= 1 and self:CanTakeFallDamage() then
					damage = landIntensity * 2 * 10                    
					if not self:GetCanTakeDamage() then
						damage = 0
					end
					self:DeductHealth(damage, self, self)
				end
			end
		else
			if self:CanTakeFallDamage() then
                if not self.jumping then
                    self.jumping = true
                end
			end
		end
			
		originalPlayerOnGroundChanged(self, onGround, landIntensity, normal, velocity)
	end   
    
end


