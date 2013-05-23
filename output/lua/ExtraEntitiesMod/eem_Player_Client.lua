//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

local overrideOnClientDisconnected = OnClientDisconnected
function OnClientDisconnected(reason)    
    if self.gEemToolTipScript then
        GetGUIManager():DestroyGUIScriptSingle(self.gEemToolTipScript)
        self.gEemToolTipScript  = nil
    end
    
    overrideOnClientDisconnected(reason)
end


local overridePlayerOnInitLocalClient
overridePlayerOnInitLocalClient = Class_ReplaceMethod( "Player", "OnInitLocalClient", 
	function(self)
        overridePlayerOnInitLocalClient(self) 

	end
)


local overridePlayerUpdateClientEffects
overridePlayerUpdateClientEffects = Class_ReplaceMethod( "Player", "UpdateClientEffects",
   function(self, deltaTime, isLocal)  
        overridePlayerUpdateClientEffects(self, deltaTime, isLocal)
        local player = Client.GetLocalPlayer()
        if player then
            if not player.gEemToolTipScript then
                player.gEemToolTipScript = GetGUIManager():CreateGUIScript("ExtraEntitiesMod/GUIEemHint")
            end

            local target = GetEntitiesWithinRangeInView("LogicWorldTooltip", 2, player)

            if target and target[1] and target[1].GetTooltipText then
                info = target[1]:GetTooltipText(player)
                if info then
                    player.gEemToolTipScript:UpdateData("", "", 0, "", "", info, 0)                
                end
            end

        end
    end

)

// no noname for bots
local originalPlayerGetName
originalPlayerGetName = Class_ReplaceMethod( "Player", "GetName",

   function(self, forEntity) 
    
        local name = originalPlayerGetName(self, forEntity)

        if name == "No Name" then
            name = " "
        end

        return name
        
    end
)