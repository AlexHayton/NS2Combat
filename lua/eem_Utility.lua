//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________


function AnglesToVector(self)            
    // y -1.57 in game is up in the air
    local angles =  self:GetAngles()
    local origin = self:GetOrigin()
    local directionVector = Vector(0,0,0)
    if angles then
        // get the direction Vector the pushTrigger should push you                
        
        // pitch to vector
        directionVector.z = math.cos(angles.pitch)
        directionVector.y = -math.sin(angles.pitch)
        
        // yaw to vector
        if angles.yaw ~= 0 then
            directionVector.x = directionVector.z * math.sin(angles.yaw)                   
            directionVector.z = directionVector.z * math.cos(angles.yaw)                                
        end  
    end
    return directionVector
end


function CreateEemProp(self)

    if self.test ~= 0 then  

        local coords = self:GetAngles():GetCoords(self:GetOrigin())
        coords.xAxis = coords.xAxis * self.propScale.x
        coords.yAxis = coords.yAxis * self.propScale.y
        coords.zAxis = coords.zAxis * self.propScale.z
         
        self.physicsModel = Shared.CreatePhysicsModel(self.test, false, coords, nil) 
        self.physicsModel:SetPhysicsType(CollisionObject.Static) 
        
        //self:SetModel(self.model) 
        self:SetCoords(coords)  
        
        if Client then
                // Create the visual representation of the prop.
                // All static props can be instanced.
               
            local renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)       
            renderModel:SetModel(self.test)            
            renderModel:SetCoords(coords)
            renderModel:SetIsStatic(true)
            renderModel:SetIsInstanced(true)  
            renderModel.commAlpha = 1        
           
            table.insert(Client.propList, {renderModel, self.physicsModel})
            self.viewModel = {renderModel, self.physicsModel}
        end    
    end

end

