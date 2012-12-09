//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

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
        if self.pushTime ~= -1 or self:isa("Lerk") then
            originalPlayerOnClampSpeed(self, input, velocity)
        end
    end
)


// overrides OnJumpLand so the ClampSpeed can work right
local originalPlayerOnJumpLand
originalPlayerOnJumpLand = Class_ReplaceMethod( "Player", "OnJumpLand",
    function (self, landIntensity, slowDown)
        
        if Server then
        
            if self.pushTime == -1 then
                self.pushTime = 0
            elseif kFallDamage then
                if landIntensity >= 1 then
                    if self:CanTakeFallDamage() then
                        damage = landIntensity * 2 * 10                    
                        if not self:GetCanTakeDamage() then
                            damage = 0
                        end
                        self:DeductHealth(damage, self, self)
                    end
                end
            end
   
        end     
        originalPlayerOnJumpLand(self, landIntensity, slowDown)
        
    end
)


// overrides PlayerOnUpdate so we can set jumping=true when falling 
local originalPlayerOnUpdatePlayer
originalPlayerOnUpdatePlayer = Class_ReplaceMethod( "Player", "OnUpdatePlayer",
    function (self, deltaTime)
                
        if not self:GetIsOnGround() and self:CanTakeFallDamage() then
            if not self.jumping then
                self.jumping = true
            end
        end 
        originalPlayerOnUpdatePlayer(self, deltaTime)           
        
    end
)


