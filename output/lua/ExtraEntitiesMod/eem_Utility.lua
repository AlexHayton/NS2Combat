//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
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

if not Prediction then
    if self.model and self.model ~= "" then  

        local coords = self:GetAngles():GetCoords(self:GetOrigin())
        coords.xAxis = coords.xAxis * self.scale.x
        coords.yAxis = coords.yAxis * self.scale.y
        coords.zAxis = coords.zAxis * self.scale.z
         
        self.physicsModel = Shared.CreatePhysicsModel(self.model, true, coords, self) 
        self.physicsModel:SetPhysicsType(PhysicsType.DynamicServer)
        //self:SetModel(self.model) 
        //self:SetCoords(coords or Coords())  
        
        if Client then
                // Create the visual representation of the prop.
                // All static props can be instanced.
               
            self.renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)       
            self.renderModel:SetModel(self.model)            
            self.renderModel:SetCoords(coords)
            self.renderModel:SetIsStatic(false)
            //self.renderModel:SetIsInstanced(true)  
            self.renderModel.commAlpha = 1        
           
            //table.insert(Client.propList, {self.renderModel, self.physicsModel})
            self.viewModel = {self.renderModel, self.physicsModel}
        end    
    end
end
end


function Player:CanTakeFallDamage()

    if self:isa("Marine") or self:isa("Gorge") or self:isa("Onos") then
        return true
    else
        return false
    end

end

