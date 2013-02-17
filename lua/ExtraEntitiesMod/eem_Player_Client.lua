//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________


local overrideOnClientDisconnected = OnClientDisconnected
function OnClientDisconnected(reason)    
    GetGUIManager():DestroyGUIScriptSingle("ExtraEntitiesMod/GUIEemHint")
    overrideOnClientDisconnected(reason)
end


local overridePlayerOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    overridePlayerOnInitLocalClient(self) 
    gEemToolTipScript = GetGUIManager():CreateGUIScript("ExtraEntitiesMod/GUIEemHint")
end


local overridePlayerUpdateClientEffects = Player.UpdateClientEffects
function Player:UpdateClientEffects(deltaTime, isLocal)  
   
    overridePlayerUpdateClientEffects(self, deltaTime, isLocal)
    local player = Client.GetLocalPlayer()
    if player and gEemToolTipScript then
    
        // Hide in ready room
        if player:GetIsOnPlayingTeam() then
    
            local target = GetEntitiesWithinRangeInView("LogicWorldTooltip", 2, player)

            if target and target[1] and target[1].GetTooltipText then
                info = target[1]:GetTooltipText()
                if info then
                    gEemToolTipScript:UpdateData("", "", 0, "", "", info, 0)                
                end
            end
            
        else
            // Don't show tooltip in ready room
            gEemToolTipScript:FadeOut()
        end
    
    end

end