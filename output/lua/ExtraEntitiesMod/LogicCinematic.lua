//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// LogicCinematic.lua
// Base entity for LogicCinematic things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")


class 'LogicCinematic' (Entity)

LogicCinematic.kMapName = "logic_cinematic"


local networkVars =
{
    cinematicName = "string (128)",
    everyPlayer = "boolean",
    effectEntityId = "entityid",
    hasCamera = "boolean",
}

AddMixinNetworkVars(LogicMixin, networkVars)


local function RetreiveInput(self)
    SetMoveInputBlocked(false)
    return false    
end


function LogicCinematic:OnCreate()
end

function LogicCinematic:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
    end   
   
    if self.cinematicName then
        PrecacheAsset(self.cinematicName)
    end
    
end

function LogicCinematic:Reset()
    if Client then
        if self.cinematicCamActive then   
            self:ResetClientThings() 
        end
    end
end

function LogicCinematic:OnLogicTrigger(player)
    if self.cinematicName then
        local effectEntity = Shared.CreateEffect(nil, self.cinematicName, nil, self:GetCoords())
        self.effectEntityId = effectEntity:GetId()
    end
end


if Client then

    function LogicCinematic:DestroyScripts()
    
        if ClientUI.GetScript("Hud/Marine/GUIMarineHUD") or ClientUI.GetScript("GUIAlienHUD") then
            local guis = { GUIFeedback = true, GUIScoreboard = true, GUIDeathMessages = true, GUIChat = true,
                           GUIVoiceChat = true, GUIMinimapFrame = true, GUIMapAnnotations = true,
                           GUICommunicationStatusIcons = true, GUIUnitStatus = true, GUIDeathScreen = true,
                           GUITipVideo = true}
                           
            ClientUI.DestroyUIScripts()
            for name, exists in pairs(guis) do
                if exists then
                    GetGUIManager():CreateGUIScript(name)
                end
            end        
        end
        
    end

    function LogicCinematic:OnUpdateRender()

        local unlockMovement = true
        if self.effectEntityId and self.effectEntityId ~= 0 then
            local effect = Shared.GetEntity(self.effectEntityId)
            if effect and effect.cinematic then

                local cullingMode = RenderCamera.CullingMode_Occlusion
                local camera = effect.cinematic:GetCamera()
                
                if camera and self.hasCamera then
                
                    local player = Client.GetLocalPlayer() 
                    self:DestroyScripts()  
                    
                    if player then
                        if player:GetViewModelEntity() then
                            self.oldPlayerModel = player:GetViewModelEntity():GetModelName()
                            player:GetViewModelEntity():SetModel("")
                            player:GetViewModelEntity():SetIsVisible(false)
                        end       
                        player.countingDown = true
                        // Clear game effects on player
                        player:ClearGameEffects() 
                   end
                   
                    gRenderCamera:SetCoords(camera:GetCoords())
                    gRenderCamera:SetFov(camera:GetFov())
                    gRenderCamera:SetNearPlane(0.01)
                    gRenderCamera:SetFarPlane(10000.0)
                    gRenderCamera:SetCullingMode(cullingMode)
                    Client.SetRenderCamera(gRenderCamera)
                    self.cinematicCamActive = true
                    SetMoveInputBlocked(true)
                    unlockMovement  = false                   

                end
            end
        end
        
        if unlockMovement and self.cinematicCamActive then        
            self:ResetClientThings() 
        end

    end
    
    
    function LogicCinematic:ResetClientThings()    
        local player = Client.GetLocalPlayer()
        
        if player then
            if self.oldPlayerModel then
                player:GetViewModelEntity():SetModel(self.oldPlayerModel)
                player:GetViewModelEntity():SetIsVisible(true)
                self.oldPlayerModel = nil
            end 
            SetMoveInputBlocked(false)
            player.countingDown = false
            
            // copied from OnLocalPlayerChanged(), only way I found to do this
            ClientUI.EvaluateUIVisibility(player)
            ClientResources.EvaluateResourceVisibility(player)

            player:OnInitLocalClient()
        end
        self.cinematicCamActive = false
        self.effectEntityId = 0
    end
    
end

Shared.LinkClassToMap("LogicCinematic", LogicCinematic.kMapName, networkVars)