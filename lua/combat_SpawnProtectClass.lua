//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// initially, this was for my singlepalyer project, but lets make a cool halloween ai with that


//******************************************
//* Scripts 
//******************************************

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/TeamMixin.lua")

class 'CombatSpawnProtect' (ScriptActor)

//******************************************
//* Class variables
//******************************************

CombatSpawnProtect.kMapName = "combatspawnprotect"
CombatSpawnProtect.materialFile = ("cinematics/vfx_materials/spawnProtect.material")
CombatSpawnProtect.viewMaterialFile = ("cinematics/vfx_materials/spawnProtect_view.material")  



//******************************************
//* Network variables
//******************************************

local networkVars =
{
    playerId = "entityid"
}

AddMixinNetworkVars(TeamMixin, networkVars)


//******************************************
//* Functions
//******************************************


// onCreate and OnInitilized need every class
function CombatSpawnProtect:OnCreate()
    InitMixin(self, TeamMixin)
    self:SetUpdates(true)
end

function CombatSpawnProtect:OnInitialized()
     
    // get the parent player     
    local playersInRange = GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), 1)
    for index, player in ipairs(playersInRange) do
        local distance = (player:GetOrigin() - self:GetOrigin())
        if player:GetOrigin() == self:GetOrigin() then
            self.playerId = player:GetId()
            break
        end
    end
    
    if Client then
        if self.playerId then
            self:_CreateEffect()
        end
    end
    
end

function CombatSpawnProtect:OnUpdate(deltaTime)
    if Client then
        if not self.effectSuccess then
            self:_CreateEffect()
        end
    end
end

function CombatSpawnProtect:OnDestroy()
	if Client then		
        self:_RemoveEffect()
	end
end

if Client then

    function CombatSpawnProtect:CreateSpawnProtectEffect() 
        /*
        self.protectEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        local cinematicName = CombatSpawnProtect.kCinematic 
        
        self.protectEffect:SetCinematic(cinematicName)
        self.protectEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.protectEffect:SetIsVisible(true)
        self:UpdateEffect()
        */
    end
     /** Adds the material effect to the entity and all child entities (hat have a Model mixin) */
    local function AddEffect(player, material, viewMaterial)    
       
        if HasMixin(player, "Model") then
            local model = player._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:AddMaterial(viewMaterial)
                    return true
                else
                    model:AddMaterial(material)
                    return true
                end
            end            
        end
        
        return false
    
    end
    
    local function RemoveEffect(player, material, viewMaterial)

        if player ~= nil and HasMixin(player, "Model") then
            local model = player._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:RemoveMaterial(viewMaterial)
                else
                    model:RemoveMaterial(material)
                end
            end                    
        end 
       
    end

    function CombatSpawnProtect:_CreateEffect()   
        
        self.material = Client.CreateRenderMaterial()
        self.material:SetMaterial(CombatSpawnProtect.materialFile)

        self.viewMaterial = Client.CreateRenderMaterial()
        self.viewMaterial:SetMaterial(CombatSpawnProtect.viewMaterialFile)   
        
        local player = Shared.GetEntity(self.playerId)
        local success = AddEffect(player, self.material, self.viewMaterial)  
        if success then
            self.effectSuccess = true        
        end
        
    end

    function CombatSpawnProtect:_RemoveEffect()

        if self.playerId then  
            local player = Shared.GetEntity(self.playerId)      
            RemoveEffect(player, self.material, self.viewMaterial)
            Client.DestroyRenderMaterial(self.material)
            Client.DestroyRenderMaterial(self.viewMaterial)     
        end
        
    end       

end


Shared.LinkClassToMap("CombatSpawnProtect", CombatSpawnProtect.kMapName, networkVars, true)