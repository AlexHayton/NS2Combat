//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________


Script.Load("lua/Class.lua")

local originalSpitProcessHit
originalSpitProcessHit = Class_ReplaceMethod( "Spit", "ProcessHit", 
	function(self, targetHit, surface, normal)
	    // for npcs, somethings not working so DoDamager here
        if targetHit and self:GetOwner() ~= targetHit and self:GetOwner().isaNpc then
                    
            local weapon = self:GetOwner():GetActiveWeapon()
            
            weapon.spitted = true            
            self:DoDamage(kSpitDamage, targetHit, self:GetOrigin(), self:GetOwner():GetOrigin(), surface)
            weapon.spitted = false
            
            if targetHit:isa("Marine") then
            
                local direction = self:GetOwner():GetOrigin() - targetHit:GetEyePos()
                direction:Normalize()
                targetHit:OnSpitHit(direction)
                
            end


        end
		originalSpitProcessHit(self, targetHit, surface, normal)
	end
)


