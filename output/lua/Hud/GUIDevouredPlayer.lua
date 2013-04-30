// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIDevouredPlayer.lua
//
// Created by: Jon 'Huze' Hughes (jon@jhuze.com)
//
// Spectator: Loads all the insight GUI elements
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

 Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIDevouredPlayer' (GUIAnimatedScript)

GUIDevouredPlayer.kBackgroundTexture = "ui/devour.dds"
GUIDevouredPlayer.kMaskTexture = PrecacheAsset("ui/white.png")

GUIDevouredPlayer.kBackgroundWidth = GUIScale(1500)
GUIDevouredPlayer.kBackgroundHeight = GUIScale(1500)
GUIDevouredPlayer.kBackgroundOffsetX = GUIScale(0)
GUIDevouredPlayer.kBackgroundOffsetY = GUIScale(0)

GUIDevouredPlayer.kTimeOffset = Vector(0, GUIScale(-10), 0)
GUIDevouredPlayer.kTimeFontName = "fonts/AgencyFB_large.fnt"
GUIDevouredPlayer.kTimeFontSize = 25
GUIDevouredPlayer.kTimeBold = true

GUIDevouredPlayer.kBgCoords = {14, 0, 112, 34}

GUIDevouredPlayer.kBackgroundColor = Color(1, 1, 1, 0.7)
GUIDevouredPlayer.kMarineTextColor = kMarineFontColor
GUIDevouredPlayer.kAlienTextColor = kAlienFontColor


function GUIDevouredPlayer:Initialize()

	GUIAnimatedScript.Initialize(self)
    
	// Used for Global Offset
	self.background = self:CreateAnimatedGraphicItem()
    self.background:SetIsScaling(false)
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetAnchor(GUIItem.Top, GUIItem.Top)
    self.background:SetPosition( Vector(0, 0, 0) ) 
    self.background:SetTexture(GUIDevouredPlayer.kBackgroundTexture)
    //self.background:SetLayer(kGUILayerDebugText)    
    self.background:SetShader("shaders/GUIWavy.surface_shader")
    self.background:SetAdditionalTexture("wavyMask", GUIDevouredPlayer.kMaskTexture)
    self.background:SetIsVisible(true)

	// Text
    self.devourText = self:CreateAnimatedTextItem()
    self.devourText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.devourText:SetPosition(GUIDevouredPlayer.kTimeOffset)
	//self.devourText:SetLayer(kGUILayerPlayerHUDForeground1)
	self.devourText:SetTextAlignmentX(GUIItem.Align_Center)
    self.devourText:SetTextAlignmentY(GUIItem.Align_Center)
	self.devourText:SetText("Getting devoured")
	self.devourText:SetColor(Color(1,1,1,1))
	self.devourText:SetFontSize(GUIDevouredPlayer.kTimeFontSize)
    self.devourText:SetFontName(GUIDevouredPlayer.kTimeFontName)
	self.devourText:SetFontIsBold(GUIDevouredPlayer.kTimeBold)
	self.devourText:SetIsVisible(true)
	
    // devour bar    
    self.devourBar = GUIManager:CreateGraphicItem()
    self.devourBar:SetSize( Vector(GUIDevourOnos.kBackgroundWidth, GUIDevourOnos.kBackgroundHeight, 0) )
    self.devourBar:SetPosition(Vector(GUIDevourOnos.kBackgroundWidth / 2 + GUIDevourOnos.kBackgroundOffsetX, -GUIDevourOnos.kBackgroundHeight / 2 + GUIDevourOnos.kBackgroundOffsetY, 0))
    self.devourBar:SetAnchor(GUIItem.Left, GUIItem.Bottom) 
    self.devourBar:SetTexture(GUIDevourOnos.kJetpackFuelTexture)
    self.devourBar:SetTexturePixelCoordinates(unpack(GUIDevourOnos.kBarCoords))
    //self.devourBar:SetLayer(kGUILayerPlayerHUDBackground)
    self.devourBar:SetIsVisible(false)
 
	self.background:AddChild(self.devourText)
	self.background:AddChild(self.devourBar)
    self:Update(0)
	
end

function GUIDevouredPlayer:SetDevourBar(devourValue)

    local fraction = devourValue / 100
    self.devourBar:SetSize( Vector(GUIDevourOnos.kBarWidth * fraction, -GUIDevourOnos.kBarHeight, 0) )
    //self.devourBar:SetColor( Color(1 - fraction * GUIDevourOnos.kFuelBlueIntensity, 
                                 //GUIDevourOnos.kFuelBlueIntensity * fraction * 0.8 , 
                                 //0 ,
                                 //GUIDevourOnos.kFuelBarOpacity) )

end
	
function GUIDevouredPlayer:Uninitialize()    
	GUI.DestroyItem(self.devourText)
    GUI.DestroyItem(self.background)
    GUI.DestroyItem(self.devourBar)
end

function GUIDevouredPlayer:Update(deltaTime)

    local player = Client.GetLocalPlayer()    
    if player and player:isa("DevouredPlayer") and player:GetTeamNumber() == 1 then
        self.background:SetIsVisible(true)
        local devourPercentage = player:GetDevourPercentage()
        if devourPercentage ~= 0 then
            self.devourBar:SetIsVisible(true)
            self:SetDevourBar(math.ceil(devourPercentage))
        end
    else
        self.background:SetIsVisible(false)
        GetGUIManager():DestroyGUIScript(self)
    end

end
