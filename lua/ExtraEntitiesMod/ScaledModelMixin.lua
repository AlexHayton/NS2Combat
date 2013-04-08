//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

ScaledModelMixin = CreateMixin( ScaledModelMixin )
ScaledModelMixin.type = "ScaledModel"

ScaledModelMixin.expectedMixins =
{
}

ScaledModelMixin.expectedCallbacks =
{
}


ScaledModelMixin.optionalCallbacks =
{
}


ScaledModelMixin.networkVars =  
{
}

// create a model if theres a model value
function ScaledModelMixin:__initmixin() 
end


function ScaledModelMixin:SetScaledModel(model, animationGraph)
    if model ~= nil then    
        Shared.PrecacheModel(model)    
        //local graphName = string.gsub(model, ".model", ".animation_graph")
        //if graphName then
        //    Shared.PrecacheAnimationGraph(graphName)        
        //end
		if animationGraph then
			self:SetModel(model, animationGraph)  
		else
			self:SetModel(model)
		end
    end
end


// only way to scale the model
function ScaledModelMixin:OnAdjustModelCoords(modelCoords)

    local coords = modelCoords
    if self.scale and self.scale:GetLength() ~= 0 then
        coords.xAxis = coords.xAxis * self.scale.x
        coords.yAxis = coords.yAxis * self.scale.y
        coords.zAxis = coords.zAxis * self.scale.z
    end
    return coords
    
end