//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_SpawnProtectClass

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
CombatSpawnProtect.materialFile = "cinematics/vfx_materials/spawnProtect.material"
CombatSpawnProtect.viewMaterialFile = "cinematics/vfx_materials/spawnProtect_view.material"  
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/spawnProtect.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/spawnProtect_view.surface_shader")


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
    
    if Client and not Shared.GetIsRunningPrediction() then
        if self.playerId then
            self:_CreateEffect()
        end
    end
    
end

function CombatSpawnProtect:OnUpdate(deltaTime)
    if Client and not Shared.GetIsRunningPrediction() then
        if not self.effectSuccess then
            self:_CreateEffect()
        end
    end
end

function CombatSpawnProtect:OnDestroy()
	if Client and not Shared.GetIsRunningPrediction() then	
        self:_RemoveEffect()
	end
end

if Client then
	/** Adds the material effect to the entity and all child entities (that have a Model mixin) */
    local function AddEffect(entity, material, viewMaterial, entities)
    
        local numChildren = entity:GetNumChildren()
        
        if HasMixin(entity, "Model") then
            local model = entity._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:AddMaterial(viewMaterial)
                else
                    model:AddMaterial(material)
                end
                table.insert(entities, entity:GetId())
            end
        end
        
        for i = 1, entity:GetNumChildren() do
            local child = entity:GetChildAtIndex(i - 1)
            AddEffect(child, material, viewMaterial, entities)
        end
    
    end
    
    local function RemoveEffect(entities, material, viewMaterial)
    
        for i =1, #entities do
            local entity = Shared.GetEntity( entities[i] )
            if entity ~= nil and HasMixin(entity, "Model") then
                local model = entity._renderModel
                if model ~= nil then
                    if model:GetZone() == RenderScene.Zone_ViewModel then
                        model:RemoveMaterial(viewMaterial)
                    else
                        model:RemoveMaterial(material)
                    end
                end                    
            end
        end
        
    end

    function CombatSpawnProtect:_CreateEffect()
   
        if not self.nanoShieldMaterial then
        
            local material = Client.CreateRenderMaterial()
            material:SetMaterial(CombatSpawnProtect.materialFile)

            local viewMaterial = Client.CreateRenderMaterial()
            viewMaterial:SetMaterial(CombatSpawnProtect.viewMaterialFile)
            
            self.nanoShieldEntities = {}
            self.nanoShieldMaterial = material
            self.nanoShieldViewMaterial = viewMaterial
			local player = Shared.GetEntity(self.playerId)
            AddEffect(player, material, viewMaterial, self.nanoShieldEntities)
            
        end    
        
    end

    function CombatSpawnProtect:_RemoveEffect()

        if self.nanoShieldMaterial then
            RemoveEffect(self.nanoShieldEntities, self.nanoShieldMaterial, self.nanoShieldViewMaterial)
            Client.DestroyRenderMaterial(self.nanoShieldMaterial)
            Client.DestroyRenderMaterial(self.nanoShieldViewMaterial)
            self.nanoShieldMaterial = nil
            self.nanoShieldViewMaterial = nil
            self.nanoShieldEntities = nil
        end            

    end    

end

Shared.LinkClassToMap("CombatSpawnProtect", CombatSpawnProtect.kMapName, networkVars, true)