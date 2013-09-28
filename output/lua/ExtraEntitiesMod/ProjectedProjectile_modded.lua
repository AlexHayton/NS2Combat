//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/Class.lua")
Script.Load("lua/Team.lua")

// fix gorge spit
if Server then
    local originalPredictedProjectileOnUpdate
     originalPredictedProjectileOnUpdate = Class_ReplaceMethod( "PredictedProjectile", "OnUpdate", 
        function (self, deltaTime)    
            local owner = Shared.GetEntity(self.ownerId)
            if owner and owner.isaNpc then           
                if self.projectileController then        
                    self.projectileController:Update(deltaTime, self, false)                 
                end
            end        
            originalPredictedProjectileOnUpdate(self, deltaTime)        

        end
    )
end