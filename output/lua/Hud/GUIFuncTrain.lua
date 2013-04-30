//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// GUIFuncTrain.lua

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIFuncTrain' (GUIAnimatedScript)

GUIFuncTrain.kTexture = "ui/train_buttons.png"


function GUIFuncTrain:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.player = Client.GetLocalPlayer()   

    
    self:_InitializeBackground()
    self:_InitializeContent()

    
end

function GUIFuncTrain:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)
    self:_UpdateBackground(deltaTime)

    
end

function GUIFuncTrain:Uninitialize()

end

function GUIFuncTrain:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(Color(0.05, 0.05, 0.1, 0.7))
    self.background:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.repeatingBGTexture = GUIManager:CreateGraphicItem()
    self.repeatingBGTexture:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.repeatingBGTexture:SetTexture(GUIFuncTrain.kRepeatingBackground)
    self.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, Client.GetScreenWidth(), Client.GetScreenHeight())
    self.background:AddChild(self.repeatingBGTexture)
    
    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(Vector(GUIFuncTrain.kBackgroundWidth, GUIFuncTrain.kBackgroundHeight, 0))
    self.content:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.content:SetPosition(Vector((-GUIFuncTrain.kBackgroundWidth / 2) + GUIFuncTrain.kBackgroundXOffset, -GUIFuncTrain.kBackgroundHeight / 2, 0))
    self.content:SetTexture(GUIFuncTrain.kContentBgTexture)
    self.content:SetTexturePixelCoordinates(0, 0, GUIFuncTrain.kBackgroundWidth, GUIFuncTrain.kBackgroundHeight)
    self.background:AddChild(self.content)
    
    self.scanLine = self:CreateAnimatedGraphicItem()
    self.scanLine:SetSize( Vector( Client.GetScreenWidth(), GUIFuncTrain.kScanLineHeight, 0) )
    self.scanLine:SetTexture(GUIFuncTrain.kScanLineTexture)
    self.scanLine:SetLayer(kGUILayerPlayerHUDForeground4)
    self.scanLine:SetIsScaling(false)
    
    self.scanLine:SetPosition( Vector(0, -GUIFuncTrain.kScanLineHeight, 0) )
    self.scanLine:SetPosition( Vector(0, Client.GetScreenHeight() + GUIFuncTrain.kScanLineHeight, 0), GUIFuncTrain.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function GUIFuncTrain:_UpdateBackground(deltaTime)

    // TODO: create some fancy effect (screen of structure is projecting rays in our direction?)

end

end

function GUIFuncTrain:_UninitializeContent()

    GUI.DestroyItem(self.itemName)

end
