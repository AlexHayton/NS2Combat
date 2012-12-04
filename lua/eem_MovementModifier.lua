Script.Load("lua/Class.lua")

// Overrides the function so its not printing "system" all the time
local originalSkulkConstrainMoveVelocity
SkulkConstrainMoveVelocity = Class_ReplaceMethod( "Skulk", "ConstrainMoveVelocity", 
	function(self, moveVelocity)

        // allow acceleration in air for skulks   
        if not self:GetIsOnSurface() then
        
            local speedFraction = Clamp(self:GetVelocity():GetLengthXZ() / self:GetMaxSpeed(), 0, 1)
            speedFraction = 1 - (speedFraction * speedFraction)
            moveVelocity:Scale(speedFraction * Skulk.kAirAccelerationFraction)
            
        end
		
	end
)	

// overrides onclampspeed so the force is the same to every class
local originalPlayerOnClampSpeed
originalPlayerOnClampSpeed = Class_ReplaceMethod( "Player", "OnClampSpeed", 
	function(self, input, velocity)

        // when not getting pushed, call the original method
        if self.pushTime ~= -1 then
            originalPlayerOnClampSpeed(self, input, velocity)
        end
    end
)


// overrides OnJumpLand so the ClampSpeed can work right
local originalPlayerOnJumpLand
originalPlayerOnJumpLand = Class_ReplaceMethod( "Player", "OnJumpLand",
    function (self, landIntensity, slowDown)
        
        if self.pushTime == -1 then
            self.pushTime = 0
        end
        originalPlayerOnJumpLand(self, landIntensity, slowDown)
        
    end
)


