// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIDevourOnos.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Manages the marine buy/purchase menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/combat_Utility.lua")

class 'GUIDevourOnos' (GUIScript)

GUIDevourOnos.kJetpackFuelTexture = "ui/devour_meter.png"
GUIDevourOnos.kFont = Fonts.kAgencyFB_Small
GUIDevourOnos.kBackgroundWidth = GUIScale(172)
GUIDevourOnos.kBackgroundHeight = GUIScale(34)
GUIDevourOnos.kBackgroundOffsetX = -20
GUIDevourOnos.kBackgroundOffsetY = GUIScale(-190)

GUIDevourOnos.kBarWidth = GUIScale(144)
GUIDevourOnos.kBarHeight = GUIScale(20)

GUIDevourOnos.kBgCoords = {0, 0, 144, 32}
GUIDevourOnos.kBarCoords = {10, 40, 10 + 123, 40 + 18}

GUIDevourOnos.kFuelBlueIntensity = .8

GUIDevourOnos.kBackgroundColor = Color(0, 0, 0, 0.5)
GUIDevourOnos.kFuelBarOpacity = 0.8


function GUIDevourOnos:Initialize()    
    
    // devour bar    
    self.devourBar = GUIManager:CreateGraphicItem()
    self.devourBar:SetSize( Vector(GUIDevourOnos.kBackgroundWidth, GUIDevourOnos.kBackgroundHeight, 0) )
    self.devourBar:SetPosition(Vector(GUIDevourOnos.kBackgroundWidth / 2 + GUIDevourOnos.kBackgroundOffsetX, -GUIDevourOnos.kBackgroundHeight / 2 + GUIDevourOnos.kBackgroundOffsetY, 0))
    self.devourBar:SetAnchor(GUIItem.Left, GUIItem.Bottom) 
    self.devourBar:SetLayer(kGUILayerPlayerHUD)
    self.devourBar:SetTexture(GUIDevourOnos.kJetpackFuelTexture)
    self.devourBar:SetTexturePixelCoordinates(unpack(GUIDevourOnos.kBarCoords))
    self.devourBar:SetIsVisible(false)
    
    self:Update(0)

end

function GUIDevourOnos:SetDevourBar(devourValue)

    local fraction = devourValue / 100
    self.devourBar:SetSize( Vector(GUIDevourOnos.kBarWidth * fraction, -GUIDevourOnos.kBarHeight, 0) )
    //self.devourBar:SetColor( Color(1 - fraction * GUIDevourOnos.kFuelBlueIntensity, 
                                 //GUIDevourOnos.kFuelBlueIntensity * fraction * 0.8 , 
                                 //0 ,
                                 //GUIDevourOnos.kFuelBarOpacity) )

end


function GUIDevourOnos:Update(deltaTime)

    local player = Client.GetLocalPlayer()
    local devour = nil

    if player and player:isa("Onos") then
        local abilities = GetChildEntities(player, "Devour")
        if #abilities > 0 then
            devour = abilities[1]
        end
        if devour then
            local devourPercentage = devour:GetDevourPercentage()
            if devourPercentage ~= 0 then
                self.devourBar:SetIsVisible(true)
                self:SetDevourBar(math.ceil(devourPercentage))
            else
                self.devourBar:SetIsVisible(false)
            end
        else
            self.devourBar:SetIsVisible(false)
        end
    else
        self.devourBar:SetIsVisible(false)
        GetGUIManager():DestroyGUIScriptSingle(self)
    end

end


function GUIDevourOnos:Uninitialize()

    GUI.DestroyItem(self.devourBar)
    GUI.DestroyItem(self.background)

end