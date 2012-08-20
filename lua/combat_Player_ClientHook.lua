//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Player_ClientHook.lua

local HotReload = CombatPlayerClient
if(not HotReload) then
  CombatPlayerClient = {}
end

ClassHooker:Mixin("CombatPlayerClient")

function CombatPlayerClient:OnLoad()

    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
	self:ReplaceClassFunction("Player", "Buy", "Buy_Hook_Marine")
	self:PostHookClassFunction("Alien", "Buy", "Buy_Hook")
	self:HookClassFunction("Player", "OnInitLocalClient", "OnInitLocalClient_Hook")
    self:ReplaceClassFunction("Marine", "CloseMenu", "CloseMenu_Hook")
    
    self:PostHookFunction("InitTechTreeMaterialOffsets", "InitTechTreeMaterialOffsets_Hook")
end

// starting the costum buy menu for marines
function CombatPlayerClient:Buy_Hook(self)

   // Don't allow display in the ready room, or as phantom
    if Client.GetLocalPlayer() == self then
        if self:GetTeamNumber() ~= 0 then
            if not self.buyMenu then
                self.combatBuy = true
            else
                self.combatBuy = false
            end
            

        end
        
    end

end

// starting the costum buy menu for marines
function CombatPlayerClient:Buy_Hook_Marine(self)

   // Don't allow display in the ready room, or as phantom
    if Client.GetLocalPlayer() == self then
        if self:GetTeamNumber() ~= 0 then
        
            if not self.buyMenu then
                // open the buy menu
                self.combatBuy = true
                self.buyMenu = GetGUIManager():CreateGUIScript("Hud/Marine/combat_GUIMarineBuyMenu")
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
            else
                self.combatBuy = false
                self:CloseMenu()
            end
            

        end
        
    end

end



// get the ups from the server (only worked that way)
function CombatPlayerClient:OnInitLocalClient_Hook(self)

    Shared.ConsoleCommand("co_sendupgrades") 

end

// costum CloseMenu that our buy menu will not be closed all the time (cause no structure is nearby)
function CombatPlayerClient:CloseMenu_Hook(self)

    if self.buyMenu then
        // only close it if its not the combatBuy
        if not self.combatBuy then    
            GetGUIManager():DestroyGUIScript(self.buyMenu)
            self.buyMenu = nil
            MouseTracker_SetIsVisible(false)
            return true
        end        
    end
   
    return false
end

// that tier2 and tier3 have the right icons
function CombatPlayerClient:InitTechTreeMaterialOffsets_Hook()

    // Icons for tier2 and 3
    kAlienTechIdToMaterialOffset[kTechId.TwoHives] = 95
    kAlienTechIdToMaterialOffset[kTechId.ThreeHives] = 77
end

CombatPlayerClient:OnLoad()
