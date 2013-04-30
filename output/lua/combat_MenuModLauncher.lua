//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//  This file kindly contributed by fsfod!
//________________________________

// Loading the Hook classes
NS2CombatMenuMod = {}

if(not NS2CombatMenuMod) then
  NS2CombatMenuMod = {}
end

local HotReload = ClassHooker:Mixin("NS2CombatMenuMod")

function NS2CombatMenuMod:OnLoad()  
  CombatGUIMarineHud:OnLoad()
  CombatPlayerClient:OnLoad()
  
  LoadTracker:SetFileOverride("lua/Hud/Marine/combat_GUIMarineBuyMenu.lua", "mods/NS2Combat/lua/Hud/Marine/combat_GUIMarineBuyMenu.lua")
  LoadTracker:SetFileOverride("lua/Hud/Alien/combat_GUIAlienBuyMenu.lua", "mods/NS2Combat/lua/Hud/Alien/combat_GUIAlienBuyMenu.lua")
  LoadTracker:SetFileOverride("lua/Hud/combat_GUIExperienceBar.lua", "mods/NS2Combat/lua/Hud/combat_GUIExperienceBar.lua")
  LoadTracker:SetFileOverride("lua/Hud/combat_GUIGameTimeCountDown.lua", "mods/NS2Combat/lua/Hud/combat_GUIGameTimeCountDown.lua")
  
  self:PostHookClassFunction("Player", "Buy", "MouseStateFix")
  self:PostHookClassFunction("Alien", "Buy", "MouseStateFix")
end

function NS2CombatMenuMod:MouseStateFix(self)

  if(Client.GetLocalPlayer() == self) then
      
    local stateActive = MouseStateTracker:GetStateIndex("buymenu")
    
    if(self.buyMenu and not stateActive) then
      MouseStateTracker:PushState("buymenu", true, true, "ui/Cursor_MenuDefault.dds")
    elseif(not self.buyMenu and stateActive) then
      MouseStateTracker:TryPopState("buymenu")
    end

  end
end

// new functions, no hooks
// to provide the client also with all Ups (for the GUI)
function NS2CombatMenuMod:OnClientLuaFinished()
	Script.Load("lua/combat_Player_ClientUpgrade.lua")
	Script.Load("lua/combat_CombatUpgrade.lua")
	Script.Load("lua/combat_CombatMarineUpgrade.lua")
	Script.Load("lua/combat_CombatAlienUpgrade.lua")
	Script.Load("lua/combat_ExperienceData.lua")
	Script.Load("lua/combat_ExperienceFuncs.lua")
	Script.Load("lua/combat_Values.lua")
	Script.Load("lua/combat_ConsoleCommands_Client.lua")
	Script.Load("lua/combat_MarineBuyFuncs.lua")
	Script.Load("lua/combat_AlienBuyFuncs.lua")
	Script.Load("lua/Weapons/Marines/combat_ClipWeapon.lua")
end


function NS2CombatMenuMod:OnClientLoadComplete()
  //self:LoadScript("lua/Hud/Alien/combat_GUIAlienBuyMenu.lua")
  //self:LoadScript("lua/Hud/Marine/combat_GUIMarineBuyMenu.lua")
end