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
  ClassHooker:Mixin("CombatPlayerClient")
end

function CombatPlayerClient:OnLoad()

    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
	_addHookToTable(self:ReplaceClassFunction("Player", "Buy", "Buy_Hook_Marine"))
	_addHookToTable(self:ReplaceClassFunction("Alien", "Buy", "Buy_Hook_Alien"))
	_addHookToTable(self:HookClassFunction("Player", "OnInitLocalClient", "OnInitLocalClient_Hook"))
	_addHookToTable(self:HookClassFunction("Player", "AddTakeDamageIndicator", "AddTakeDamageIndicator_Hook"))
	_addHookToTable(self:ReplaceClassFunction("Marine", "CloseMenu", "CloseMenu_Hook"))
	// To allow exosuits to use the menu.
    _addHookToTable(self:ReplaceClassFunction("Player", "CloseMenu", "CloseMenu_Hook"))
	_addHookToTable(self:PostHookClassFunction("Marine", "UpdateClientEffects", "UpdateClientEffects_Hook"))
   
    _addHookToTable(self:ReplaceFunction("PlayerUI_GetArmorLevel", "PlayerUI_GetArmorLevel_Hook"))
    _addHookToTable(self:ReplaceFunction("PlayerUI_GetWeaponLevel", "PlayerUI_GetWeaponLevel_Hook"))
	_addHookToTable(self:PostHookClassFunction("Player", "UpdateMisc", "UpdateMisc_Hook"))
end

// Terrible Terrible hack. Yuck.
local g_AlienBuyMenu = nil

// starting the custom buy menu for aliens
function CombatPlayerClient:Buy_Hook_Alien(self)

   // Don't allow display in the ready room, or as phantom
   // Don't allow display in the ready room, or as phantom
    if Client.GetLocalPlayer() == self then
    
        // The Embryo cannot use the buy menu in any case.
        if self:GetTeamNumber() ~= 0 and not self:isa("Embryo") then
        
            if not self.buyMenu then
            
				self.combatBuy = true
                self.buyMenu = GetGUIManager():CreateGUIScript("GUIAlienBuyMenu")
				g_AlienBuyMenu = self.buyMenu
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)	
                
            else
			
				self.combatBuy = false
                self:CloseMenu(true)
				
            end
            
        else
            self:PlayEvolveErrorSound()
        end
        
    end
	
	if not self.buyMenu then
		self.combatBuy = true
	else
		self.combatBuy = false
	end			

end

// Terrible Terrible hack. Yuck.
local g_MarineBuyMenu = nil

// starting the custom buy menu for marines
function CombatPlayerClient:Buy_Hook_Marine(self)

   // Don't allow display in the ready room, or as phantom
    if Client.GetLocalPlayer() == self then
        if self:GetTeamNumber() ~= 0 then
        
            if not self.buyMenu and not self:isa("DevouredPlayer") then
                // open the buy menu
                self.combatBuy = true
                self.buyMenu = GetGUIManager():CreateGUIScript("Hud/Marine/combat_GUIMarineBuyMenu")
				g_MarineBuyMenu = self.buyMenu
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
            else
                self.combatBuy = false
                self:CloseMenu()
            end
            

        end
        
    end

end

function CombatPlayerClient:OnInitLocalClient_Hook(self)

	// get the ups from the server (only worked that way)
    Shared.ConsoleCommand("co_sendupgrades")
	
	// Also initialise counters
	if (kCombatTimeSinceGameStart == nil) then
		kCombatTimeSinceGameStart = 0
	end

end

// Close the menu properly when a player dies.
// Note: This does not trigger when players are killed via the console as that calls 'Kill' directly.
function CombatPlayerClient:AddTakeDamageIndicator_Hook(self, damagePosition)    
    if not self:GetIsAlive() and not self.deathTriggered then    
		self:CloseMenu(true)        
    end
end


// costum CloseMenu that our buy menu will not be closed all the time (cause no structure is nearby)
function CombatPlayerClient:CloseMenu_Hook(self, closeCombatBuy)

	if self:GetIsLocalPlayer() then
		if self.buyMenu and g_AlienBuyMenu then
			// Handle closing the alien buy menu.
			if closeCombatBuy or not self.combatBuy then
				GetGUIManager():DestroyGUIScript(g_AlienBuyMenu)
				g_AlienBuyMenu = nil
				self.buyMenu = nil
				MouseTracker_SetIsVisible(false)
				return true
			end
		end
	
		if self.buyMenu and g_MarineBuyMenu then
			// only close it if its not the combatBuy
			if closeCombatBuy or not self.combatBuy then    
				GetGUIManager():DestroyGUIScript(g_MarineBuyMenu)
				g_MarineBuyMenu = nil
				self.buyMenu = nil
				MouseTracker_SetIsVisible(false)
				return true
			end        
		end
	end
   
    return false
end

function CombatPlayerClient:UpdateClientEffects_Hook(self, deltaTime, isLocal)

	// Stop the regular buy menu from staying open.
	if self.buyMenu then
        self:CloseMenu()
    end    
	
end

// to show the correct Armor and Weapon Lvl
function CombatPlayerClient:PlayerUI_GetArmorLevel_Hook(self)
    local armorLevel = 0
    local self = Client.GetLocalPlayer()
    if self.gameStarted then
    
        local techTree = self:GetUpgrades()    
        if techTree then
            if table.maxn(techTree) > 0 then
                for i, upgradeTechId in ipairs(techTree) do
               
                    if upgradeTechId == kTechId.Armor3 then
                        armorLevel = 3
                    elseif upgradeTechId == kTechId.Armor2 then
                        armorLevel = 2
                    elseif upgradeTechId == kTechId.Armor1 then
                        armorLevel = 1
                    end
                    
                end   
            end
        end
    
    end

    return armorLevel
end

function CombatPlayerClient:PlayerUI_GetWeaponLevel_Hook()
    local weaponLevel = 0    
    local self = Client.GetLocalPlayer()
    if self.gameStarted then
    
        local techTree = self:GetUpgrades()    
        if techTree then
            if table.maxn(techTree) > 0 then
                for i, upgradeTechId in ipairs(techTree) do
               
                    if upgradeTechId == kTechId.Weapons3 then
                        weaponLevel = 3
                    elseif upgradeTechId == kTechId.Weapons2 then
                        weaponLevel = 2
                    elseif upgradeTechId == kTechId.Weapons1 then
                        weaponLevel = 1
                    end
                    
                end   
            end
        end
    
    end
    
    return weaponLevel
end

function CombatPlayerClient:UpdateMisc_Hook(self, input)

    if not Shared.GetIsRunningPrediction() then

        // Close the buy menu if it is visible when the Player moves.
        if input.move.x ~= 0 or input.move.z ~= 0 then
            self:CloseMenu(true)
        end
        
    end

end


if (not HotReload) then
	CombatPlayerClient:OnLoad()
end
