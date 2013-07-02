//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/Class.lua")

// Overrides the function so its not printing "system" all the time
function Skulk:ConstrainMoveVelocity(moveVelocity)

	// allow acceleration in air for skulks   
	if not self:GetIsOnSurface() then
	
		local speedFraction = Clamp(self:GetVelocity():GetLengthXZ() / self:GetMaxSpeed(), 0, 1)
		speedFraction = 1 - (speedFraction * speedFraction)
		moveVelocity:Scale(speedFraction * Skulk.kAirAccelerationFraction)
		
	end
	
end

// overrides onclampspeed so the force is the same to every class
local originalPlayerOnClampSpeed
originalPlayerOnClampSpeed = Class_ReplaceMethod( "Player", "OnClampSpeed", 
	function(self, input, velocity)

        // when not getting pushed, call the original method
        if self.pushTime ~= -1 or self:isa("Lerk") then
            originalPlayerOnClampSpeed(self, input, velocity)
        end
    end
)


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


