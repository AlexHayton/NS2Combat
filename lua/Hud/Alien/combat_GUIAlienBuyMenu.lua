//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIAlienBuyMenulua

Script.Load("lua/GUIParticleSystem.lua")
Script.Load("lua/tweener/Tweener.lua")

class 'combat_GUIAlienBuyMenu' (GUIScript)

combat_GUIAlienBuyMenukBuyMenuTexture = "ui/alien_buymenu.dds"
combat_GUIAlienBuyMenukBuyMenuMaskTexture = "ui/alien_buymenu_mask.dds"
combat_GUIAlienBuyMenukBuyHUDTexture = "ui/alien_buildmenu.dds"

combat_GUIAlienBuyMenukFont = "Candara"
combat_GUIAlienBuyMenukFont2 = "Candarab"

combat_GUIAlienBuyMenukAlienTypes = { { Name = "Fade", Width = GUIScale(188), Height = GUIScale(220), XPos = 4, Index = 1 },
                                { Name = "Gorge", Width = GUIScale(200), Height = GUIScale(167), XPos = 2, Index = 2 },
                                { Name = "Lerk", Width = GUIScale(284), Height = GUIScale(253), XPos = 3, Index = 3 },
                                { Name = "Onos", Width = GUIScale(304), Height = GUIScale(326), XPos = 5, Index = 4 },
                                { Name = "Skulk", Width = GUIScale(240), Height = GUIScale(170), XPos = 1, Index = 5 }}

combat_GUIAlienBuyMenukBackgroundTextureCoordinates = { 9, 1, 602, 424 }
combat_GUIAlienBuyMenukBackgroundWidth = GUIScale((combat_GUIAlienBuyMenukBackgroundTextureCoordinates[3] - combat_GUIAlienBuyMenukBackgroundTextureCoordinates[1]) * 0.80)
combat_GUIAlienBuyMenukBackgroundHeight = GUIScale((combat_GUIAlienBuyMenukBackgroundTextureCoordinates[4] - combat_GUIAlienBuyMenukBackgroundTextureCoordinates[2]) * 0.80)
// We want the background graphic to look centered around the circle even though there is the part coming off to the right.
combat_GUIAlienBuyMenukBackgroundXOffset = GUIScale(75)

combat_GUIAlienBuyMenukAlienButtonSize = GUIScale(150)
combat_GUIAlienBuyMenukPlayersTextSize = GUIScale(24)
combat_GUIAlienBuyMenukAlienSelectedButtonSize = combat_GUIAlienBuyMenukAlienButtonSize * 2
combat_GUIAlienBuyMenukAlienSelectedBackground = "ui/AlienBackground.dds"
combat_GUIAlienBuyMenukResearchTextSize = GUIScale(24)

combat_GUIAlienBuyMenukEvolveButtonWidth = GUIScale(250)
combat_GUIAlienBuyMenukEvolveButtonHeight = GUIScale(80)
combat_GUIAlienBuyMenukEvolveButtonYOffset = GUIScale(20)
combat_GUIAlienBuyMenukEvolveButtonTextSize = GUIScale(22)
combat_GUIAlienBuyMenukEvolveButtonNeedResourcesTextureCoordinates = { 87, 429, 396, 511 }
combat_GUIAlienBuyMenukEvolveButtonTextureCoordinates = { 396, 428, 706, 511 }
combat_GUIAlienBuyMenukEvolveButtonVeinsTextureCoordinates = { 600, 341, 915, 428 }

combat_GUIAlienBuyMenukHighLightTexPixelCoords = { 560, 960, 640, 1040 }

combat_GUIAlienBuyMenukCurrentAlienSize = GUIScale(200)
combat_GUIAlienBuyMenukCurrentAlienTitleTextSize = GUIScale(32)
combat_GUIAlienBuyMenukCurrentAlienTitleOffset = Vector(0, GUIScale(25), 0)

combat_GUIAlienBuyMenukResourceDisplayBackgroundTextureCoordinates = { 711, 295, 824, 346 }
combat_GUIAlienBuyMenukResourceDisplayWidth = GUIScale((combat_GUIAlienBuyMenukResourceDisplayBackgroundTextureCoordinates[3] - combat_GUIAlienBuyMenukResourceDisplayBackgroundTextureCoordinates[1]) * 1.2)
combat_GUIAlienBuyMenukResourceDisplayHeight = GUIScale((combat_GUIAlienBuyMenukResourceDisplayBackgroundTextureCoordinates[4] - combat_GUIAlienBuyMenukResourceDisplayBackgroundTextureCoordinates[2]) * 1.2)
combat_GUIAlienBuyMenukResourceFontSize = GUIScale(24)
combat_GUIAlienBuyMenukResourceTextYOffset = GUIScale(200)

combat_GUIAlienBuyMenukResourceIconTextureCoordinates = { 825, 309, 858, 342 }
combat_GUIAlienBuyMenukResourceIconWidth = GUIScale(combat_GUIAlienBuyMenukResourceIconTextureCoordinates[3] - combat_GUIAlienBuyMenukResourceIconTextureCoordinates[1])
combat_GUIAlienBuyMenukResourceIconHeight = GUIScale(combat_GUIAlienBuyMenukResourceIconTextureCoordinates[4] - combat_GUIAlienBuyMenukResourceIconTextureCoordinates[2])

combat_GUIAlienBuyMenukMouseOverInfoTextSize = GUIScale(20)
combat_GUIAlienBuyMenukMouseOverInfoOffset = Vector(GUIScale(10), GUIScale(100), 0)
combat_GUIAlienBuyMenukMouseOverInfoResIconOffset = Vector(GUIScale(0), GUIScale(50), 0)

combat_GUIAlienBuyMenukDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
combat_GUIAlienBuyMenukCannotBuyColor = Color(1, 0, 0, 0.5)
combat_GUIAlienBuyMenukEnabledColor = Color(1, 1, 1, 1)

local kTooltipTextWidth = GUIScale(300)

combat_GUIAlienBuyMenukMaxNumberOfUpgradeButtons = 9
combat_GUIAlienBuyMenukUpgradeButtonSize = GUIScale(54)
combat_GUIAlienBuyMenukUpgradeButtonDistance = GUIScale(198)
// The distance in pixels to move the button inside the embryo when selected.
combat_GUIAlienBuyMenukUpgradeButtonDistanceInside = GUIScale(74)
combat_GUIAlienBuyMenukUpgradeButtonTextureSize = 80
combat_GUIAlienBuyMenukUpgradeButtonBackgroundTextureCoordinates = { 15, 434, 85, 505 }
combat_GUIAlienBuyMenukUpgradeButtonMoveTime = 0.5

combat_GUIAlienBuyMenukCloseButtonSize = GUIScale(48)
combat_GUIAlienBuyMenukCloseButtonTextureCoordinates = { 612, 300, 660, 342 }
combat_GUIAlienBuyMenukCloseButtonRollOverTextureCoordinates = { 664, 300, 712, 342 }

combat_GUIAlienBuyMenukGlowieBigTextureCoordinates = { 860, 294, 888, 315 }
combat_GUIAlienBuyMenukGlowieSmallTextureCoordinates = { 890, 294, 905, 314 }

combat_GUIAlienBuyMenukSmokeBigTextureCoordinates = { { 620, 1, 759, 146 }, { 765, 1, 905, 146 }, { 624, 150, 763, 293 }, { 773, 152, 912, 297 } }
combat_GUIAlienBuyMenukSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }

combat_GUIAlienBuyMenukCornerPulseTime = 4
combat_GUIAlienBuyMenukCornerTextureCoordinates = { TopLeft = { 605, 1, 765, 145 },  BottomLeft = { 605, 145, 765, 290 }, TopRight = { 765, 1, 910, 145 }, BottomRight = { 765, 145, 910, 290 } }
combat_GUIAlienBuyMenukCornerWidths = { }
combat_GUIAlienBuyMenukCornerHeights = { }
for location, texCoords in pairs(combat_GUIAlienBuyMenukCornerTextureCoordinates) do
    combat_GUIAlienBuyMenukCornerWidths[location] = GUIScale(texCoords[3] - texCoords[1])
    combat_GUIAlienBuyMenukCornerHeights[location] = GUIScale(texCoords[4] - texCoords[2])
end

local kAlienMaximumUpgradeLevel = 3

local kUpgradeButtonMinSizeScalar = 0.75
local kUpgradeButtonMaxSizeScalar = 1

function combat_GUIAlienBuyMenu:Initialize()

    self.numSelectedUpgrades = 0

    self.mouseOverStates = { }
    
    self.upgradeTweeners = { }
    
    self:_InitializeBackground()
    //self:_InitializeResourceDisplay()
    self:_InitializeUpgradeButtons()
    // _InitializeMouseOverInfo() must be called before _InitializeAlienButtons().
    self:_InitializeMouseOverInfo()
    self:_InitializeAlienButtons()
    self:_InitializeCurrentAlienDisplay()
    self:_InitializeEvolveButton()
    self:_InitializeCloseButton()
    self:_InitializeGlowieParticles()
    self:_InitializeSmokeParticles()
    self:_InitializeCorners()
    
    AlienBuy_OnOpen()
    
end

function combat_GUIAlienBuyMenu:Uninitialize()

    self:_UninitializeBackground()
    //self:_UninitializeResourceDisplay()
    self:_UninitializeUpgradeButtons()
    self:_UninitializeMouseOverInfo()
    self:_UninitializeAlienButtons()
    self:_UninitializeCurrentAlienDisplay()
    self:_UninitializeEvolveButton()
    self:_UninitializeCloseButton()
    self:_UninitializeGlowieParticles()
    self:_UninitializeSmokeParticles()
    self:_UninitializeCorners()

end

function combat_GUIAlienBuyMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(combat_GUIAlienBuyMenukBackgroundWidth, combat_GUIAlienBuyMenukBackgroundHeight, 0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetPosition(Vector(-combat_GUIAlienBuyMenukBackgroundWidth / 2, -combat_GUIAlienBuyMenukBackgroundHeight / 2, 0))
    self.background:SetColor(Color(0, 0, 0, 0))
    self.background:SetLayer(kGUILayerPlayerHUD)
    
    self.backgroundCircle = GUIManager:CreateGraphicItem()
    self.backgroundCircle:SetSize(Vector(combat_GUIAlienBuyMenukBackgroundWidth, combat_GUIAlienBuyMenukBackgroundHeight, 0))
    self.backgroundCircle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.backgroundCircle:SetPosition(Vector((-combat_GUIAlienBuyMenukBackgroundWidth / 2) + combat_GUIAlienBuyMenukBackgroundXOffset, -combat_GUIAlienBuyMenukBackgroundHeight / 2, 0))
    self.backgroundCircle:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.backgroundCircle:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukBackgroundTextureCoordinates))
    self.backgroundCircle:SetShader("shaders/GUIWavy.surface_shader")
    self.backgroundCircle:SetAdditionalTexture("wavyMask", combat_GUIAlienBuyMenukBuyMenuMaskTexture)
    self.background:AddChild(self.backgroundCircle)
    
    self.backgroundCircleStencil = GUIManager:CreateGraphicItem()
    self.backgroundCircleStencil:SetIsStencil(true)
    // This never moves and we want it to draw the stencil for the upgrade buttons.
    self.backgroundCircleStencil:SetClearsStencilBuffer(false)
    self.backgroundCircleStencil:SetSize(Vector(combat_GUIAlienBuyMenukBackgroundWidth, combat_GUIAlienBuyMenukBackgroundHeight, 0))
    self.backgroundCircleStencil:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.backgroundCircleStencil:SetPosition(Vector((-combat_GUIAlienBuyMenukBackgroundWidth / 2) + combat_GUIAlienBuyMenukBackgroundXOffset, -combat_GUIAlienBuyMenukBackgroundHeight / 2, 0))
    self.backgroundCircleStencil:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.backgroundCircleStencil:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukBackgroundTextureCoordinates))
    self.background:AddChild(self.backgroundCircleStencil)
    
end

function combat_GUIAlienBuyMenu:_UninitializeBackground()

    GUI.DestroyItem(self.backgroundCircleStencil)
    self.backgroundCircleStencil = nil
    
    GUI.DestroyItem(self.backgroundCircle)
    self.backgroundCircle = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function combat_GUIAlienBuyMenu:_InitializeResourceDisplay()
    
    self.resourceDisplayBackground = GUIManager:CreateGraphicItem()
    self.resourceDisplayBackground:SetSize(Vector(combat_GUIAlienBuyMenukResourceDisplayWidth, combat_GUIAlienBuyMenukResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.resourceDisplayBackground:SetPosition(Vector((-combat_GUIAlienBuyMenukResourceDisplayWidth / 2), -combat_GUIAlienBuyMenukResourceTextYOffset, 0))
    self.resourceDisplayBackground:SetColor(Color(0, 0, 0, 0))
    self.resourceDisplayBackground:SetLayer(kGUILayerPlayerHUDForeground4)
    self.resourceDisplayBackground:SetParentRenders(false)
    self.background:AddChild(self.resourceDisplayBackground)
    
    self.resourceDisplayParticles = GUIParticleSystem()
    self.resourceDisplayParticles:Initialize()
    
    self.resourceDisplayParticles:AddParticleType("Smoke",
                                                        { SetTexture = { combat_GUIAlienBuyMenukBuyMenuTexture },
                                                          SetTexturePixelCoordinates = combat_GUIAlienBuyMenukSmokeSmallTextureCoordinates })
    
    local fadeInFunc = function(particle, lifetime) if lifetime <= 0.5 then particle.Item:SetColor(Color(1, 1, 1, lifetime / 2)) end end
    local fadeOutFunc = function(particle, lifetime) if lifetime > 0.5 then particle.Item:SetColor(Color(1, 1, 1, (1 - lifetime) / 2)) end end
    local scaleFunc = function(particle, lifetime) particle.Item:SetScale(Vector(0.5 + (1 - lifetime * 0.5), 0.5 + (1 - lifetime * 0.5), 0)) end
    local mainEmitter = { Name = "Main",
                          Position = Vector(0, 0, 0),
                          EmitOffsetLimits = { Min = Vector(-25, -5, 0),
                                               Max = Vector(5, 5, 0) },
                          SizeLimits = { MinX = 50, MaxX = 50, MinY = 30, MaxY = 30 },
                          VelocityLimits = { Min = Vector(-2, -0.5, 0), Max = Vector(10, 0.5, 0) },
                          AccelLimits = { Min = Vector(-0.01, -0.5, 0), Max = Vector(0.05, 0.5, 0) },
                          RateLimits = { Min = 0.1, Max = 0.2 },
                          LifeLimits = { Min = 8, Max = 9 },
                          LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.resourceDisplayParticles:AddEmitter(mainEmitter)
    
    self.resourceDisplayParticles:AddParticleTypeToEmitter("Smoke", "Main")
    
    self.resourceDisplayParticles:AttachToItem(self.resourceDisplayBackground)
    self.resourceDisplayParticles:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.resourceDisplayParticles:SetLayer(kGUILayerPlayerHUDForeground3)
    self.resourceDisplayParticles:FastForward(3)
    
    self.resourceDisplayIcon = GUIManager:CreateGraphicItem()
    self.resourceDisplayIcon:SetSize(Vector(combat_GUIAlienBuyMenukResourceIconWidth, combat_GUIAlienBuyMenukResourceIconHeight, 0))
    self.resourceDisplayIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.resourceDisplayIcon:SetPosition(Vector(-combat_GUIAlienBuyMenukResourceIconWidth, -combat_GUIAlienBuyMenukResourceIconHeight / 2, 0))
    self.resourceDisplayIcon:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.resourceDisplayIcon:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukResourceIconTextureCoordinates))
    self.resourceDisplayBackground:AddChild(self.resourceDisplayIcon)

    self.resourceDisplay = GUIManager:CreateTextItem()
    self.resourceDisplay:SetFontName(combat_GUIAlienBuyMenukFont)
    self.resourceDisplay:SetFontSize(combat_GUIAlienBuyMenukResourceFontSize)
    self.resourceDisplay:SetFontIsBold(true)
    self.resourceDisplay:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplay:SetTextAlignmentX(GUIItem.Align_Min)
    self.resourceDisplay:SetTextAlignmentY(GUIItem.Align_Center)
    self.resourceDisplay:SetColor(ColorIntToColor(kAlienTeamColor))
    self.resourceDisplay:SetText("")
    self.resourceDisplayIcon:AddChild(self.resourceDisplay)

end

function combat_GUIAlienBuyMenu:_UninitializeResourceDisplay()

    GUI.DestroyItem(self.resourceDisplay)
    self.resourceDisplay = nil
    
    GUI.DestroyItem(self.resourceDisplayIcon)
    self.resourceDisplayIcon = nil
    
    self.resourceDisplayParticles:Uninitialize()
    self.resourceDisplayParticles = nil
    
    GUI.DestroyItem(self.resourceDisplayBackground)
    self.resourceDisplayBackground = nil
    
end

function combat_GUIAlienBuyMenu:_InitializeAlienButtons()

    self.alienButtons = { }

    for k, alienType in ipairs(combat_GUIAlienBuyMenukAlienTypes) do
    
        // The alien image.
        local alienGraphicItem = GUIManager:CreateGraphicItem()
        local ARAdjustedHeight = (alienType.Height / alienType.Width) * combat_GUIAlienBuyMenukAlienButtonSize
        alienGraphicItem:SetSize(Vector(combat_GUIAlienBuyMenukAlienButtonSize, ARAdjustedHeight, 0))
        alienGraphicItem:SetAnchor(GUIItem.Middle, GUIItem.Center)
        alienGraphicItem:SetPosition(Vector(-combat_GUIAlienBuyMenukAlienButtonSize / 2, -ARAdjustedHeight / 2, 0))
        alienGraphicItem:SetTexture("ui/" .. alienType.Name .. ".dds")
        alienGraphicItem:SetIsVisible(AlienBuy_IsAlienResearched(alienType.Index))
        
        // Create the text that indicates how many players are playing as a specific alien type.
        local playersText = GUIManager:CreateTextItem()
        playersText:SetAnchor(GUIItem.Right, GUIItem.Top)
        playersText:SetFontName(combat_GUIAlienBuyMenukFont)
        playersText:SetFontSize(combat_GUIAlienBuyMenukPlayersTextSize)
        playersText:SetTextAlignmentX(GUIItem.Align_Max)
        playersText:SetTextAlignmentY(GUIItem.Align_Min)
        playersText:SetText("x" .. ToString(ScoreboardUI_GetNumberOfAliensByType(alienType.Name)))
        playersText:SetColor(ColorIntToColor(kAlienTeamColor))
        alienGraphicItem:AddChild(playersText)
        
        // Create the text that indicates the research progress.
        local researchText = GUIManager:CreateTextItem()
        researchText:SetAnchor(GUIItem.Middle, GUIItem.Center)
        researchText:SetFontName(combat_GUIAlienBuyMenukFont)
        researchText:SetFontSize(combat_GUIAlienBuyMenukResearchTextSize)
        researchText:SetTextAlignmentX(GUIItem.Align_Center)
        researchText:SetTextAlignmentY(GUIItem.Align_Center)
        researchText:SetColor(ColorIntToColor(kAlienTeamColor))
        alienGraphicItem:AddChild(researchText)
        
        // Create the selected background item for this alien item.
        local selectedBackground = GUIManager:CreateGraphicItem()
        selectedBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
        selectedBackground:SetSize(Vector(combat_GUIAlienBuyMenukAlienSelectedButtonSize, combat_GUIAlienBuyMenukAlienSelectedButtonSize, 0))
        selectedBackground:SetTexture(combat_GUIAlienBuyMenukAlienSelectedBackground)
        // Hide the selected background for now.
        selectedBackground:SetColor(Color(1, 1, 1, 0))
        selectedBackground:AddChild(alienGraphicItem)
        
        table.insert(self.alienButtons, { TypeData = alienType, Button = alienGraphicItem, SelectedBackground = selectedBackground, PlayersText = playersText, ResearchText = researchText, ARAdjustedHeight = ARAdjustedHeight })
        self.background:AddChild(selectedBackground)
        
    end
    
    self:_UpdateAlienButtons()

end

function combat_GUIAlienBuyMenu:_UninitializeAlienButtons()

    for i, button in ipairs(self.alienButtons) do
        GUI.DestroyItem(button.PlayersText)
        GUI.DestroyItem(button.Button)
        GUI.DestroyItem(button.SelectedBackground)
    end
    self.alienButtons = nil
    
    GUI.DestroyItem(self.mouseOverAlienBackground)
    self.mouseOverAlienBackground = nil
    
end

function combat_GUIAlienBuyMenu:_InitializeCurrentAlienDisplay()

    self.currentAlienDisplay = { }
    
    self.currentAlienDisplay.Icon = GUIManager:CreateGraphicItem()
    self.currentAlienDisplay.Icon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    local width = combat_GUIAlienBuyMenukAlienTypes[CombatAlienBuy_GetCurrentAlien()].Width
    local height = combat_GUIAlienBuyMenukAlienTypes[CombatAlienBuy_GetCurrentAlien()].Height
    self.currentAlienDisplay.Icon:SetSize(Vector(width, height, 0))
    self.currentAlienDisplay.Icon:SetPosition(Vector((-width / 2), -height / 2, 0))
    self.currentAlienDisplay.Icon:SetTexture("ui/" .. combat_GUIAlienBuyMenukAlienTypes[CombatAlienBuy_GetCurrentAlien()].Name .. ".dds")
    self.currentAlienDisplay.Icon:SetLayer(kGUILayerPlayerHUDForeground2)
    self.currentAlienDisplay.Icon:SetParentRenders(false)
    self.background:AddChild(self.currentAlienDisplay.Icon)
    
    self.currentAlienDisplay.TitleShadow = GUIManager:CreateTextItem()
    self.currentAlienDisplay.TitleShadow:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.currentAlienDisplay.TitleShadow:SetPosition(combat_GUIAlienBuyMenukCurrentAlienTitleOffset)
    self.currentAlienDisplay.TitleShadow:SetFontName(combat_GUIAlienBuyMenukFont)
    self.currentAlienDisplay.TitleShadow:SetFontSize(combat_GUIAlienBuyMenukCurrentAlienTitleTextSize)
    self.currentAlienDisplay.TitleShadow:SetTextAlignmentX(GUIItem.Align_Center)
    self.currentAlienDisplay.TitleShadow:SetTextAlignmentY(GUIItem.Align_Min)
    self.currentAlienDisplay.TitleShadow:SetText(string.upper(combat_GUIAlienBuyMenukAlienTypes[CombatAlienBuy_GetCurrentAlien()].Name))
    self.currentAlienDisplay.TitleShadow:SetColor(Color(0, 0, 0, 1))
    self.background:AddChild(self.currentAlienDisplay.TitleShadow)
    
    self.currentAlienDisplay.Title = GUIManager:CreateTextItem()
    self.currentAlienDisplay.Title:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.currentAlienDisplay.Title:SetPosition(Vector(-2, -2, 0))
    self.currentAlienDisplay.Title:SetFontName(combat_GUIAlienBuyMenukFont)
    self.currentAlienDisplay.Title:SetFontSize(combat_GUIAlienBuyMenukCurrentAlienTitleTextSize)
    self.currentAlienDisplay.Title:SetTextAlignmentX(GUIItem.Align_Center)
    self.currentAlienDisplay.Title:SetTextAlignmentY(GUIItem.Align_Min)
    self.currentAlienDisplay.Title:SetText(string.upper(combat_GUIAlienBuyMenukAlienTypes[CombatAlienBuy_GetCurrentAlien()].Name))
    self.currentAlienDisplay.Title:SetColor(ColorIntToColor(kAlienTeamColor))
    self.currentAlienDisplay.TitleShadow:AddChild(self.currentAlienDisplay.Title)

end

function combat_GUIAlienBuyMenu:_UninitializeCurrentAlienDisplay()

    GUI.DestroyItem(self.currentAlienDisplay.Title)
    GUI.DestroyItem(self.currentAlienDisplay.TitleShadow)
    GUI.DestroyItem(self.currentAlienDisplay.Icon)
    self.currentAlienDisplay = nil
    
end

function combat_GUIAlienBuyMenu:_InitializeMouseOverInfo()

    self.mouseOverInfo = GUIManager:CreateTextItem()
    self.mouseOverInfo:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfo:SetPosition(combat_GUIAlienBuyMenukMouseOverInfoOffset)
    self.mouseOverInfo:SetFontName(combat_GUIAlienBuyMenukFont)
    self.mouseOverInfo:SetFontSize(combat_GUIAlienBuyMenukMouseOverInfoTextSize)
    self.mouseOverInfo:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverInfo:SetTextAlignmentY(GUIItem.Align_Min)
    self.mouseOverInfo:SetText(string.upper(combat_GUIAlienBuyMenukAlienTypes[CombatAlienBuy_GetCurrentAlien()].Name))
    self.mouseOverInfo:SetColor(ColorIntToColor(kAlienTeamColor))
    // Only visible on mouse over.
    self.mouseOverInfo:SetIsVisible(false)
    self.background:AddChild(self.mouseOverInfo)
    
    self.mouseOverInfoResIcon = GUIManager:CreateGraphicItem()
    self.mouseOverInfoResIcon:SetSize(Vector(combat_GUIAlienBuyMenukResourceIconWidth, combat_GUIAlienBuyMenukResourceIconHeight, 0))
    self.mouseOverInfoResIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoResIcon:SetPosition(combat_GUIAlienBuyMenukMouseOverInfoResIconOffset)
    self.mouseOverInfoResIcon:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.mouseOverInfoResIcon:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukResourceIconTextureCoordinates))
    self.mouseOverInfoResIcon:SetIsVisible(false)
    self.background:AddChild(self.mouseOverInfoResIcon)
    
    self.mouseOverInfoResAmount = GUIManager:CreateTextItem()
    self.mouseOverInfoResAmount:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.mouseOverInfoResAmount:SetPosition(Vector(0, 0, 0))
    self.mouseOverInfoResAmount:SetFontName(combat_GUIAlienBuyMenukFont)
    self.mouseOverInfoResAmount:SetFontSize(combat_GUIAlienBuyMenukMouseOverInfoTextSize)
    self.mouseOverInfoResAmount:SetTextAlignmentX(GUIItem.Align_Min)
    self.mouseOverInfoResAmount:SetTextAlignmentY(GUIItem.Align_Center)
    self.mouseOverInfoResAmount:SetColor(ColorIntToColor(kAlienTeamColor))
    self.mouseOverInfoResIcon:AddChild(self.mouseOverInfoResAmount)

end

function combat_GUIAlienBuyMenu:_UninitializeMouseOverInfo()

    GUI.DestroyItem(self.mouseOverInfoResAmount)
    self.mouseOverInfoResAmount = nil
    
    GUI.DestroyItem(self.mouseOverInfoResIcon)
    self.mouseOverInfoResIcon = nil
    
    GUI.DestroyItem(self.mouseOverInfo)
    self.mouseOverInfo = nil

end

function combat_GUIAlienBuyMenu:_InitializeUpgradeButtons()

    // There are purchased and unpurchased buttons. Both are managed in this list.
    self.upgradeButtons = { }
    for i = 1, combat_GUIAlienBuyMenukMaxNumberOfUpgradeButtons + 1 do

        // Every upgrade has an icon.
        local buttonIcon = GUIManager:CreateGraphicItem()
        buttonIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
        buttonIcon:SetSize(Vector(combat_GUIAlienBuyMenukUpgradeButtonSize, combat_GUIAlienBuyMenukUpgradeButtonSize, 0))
        buttonIcon:SetPosition(Vector(-combat_GUIAlienBuyMenukUpgradeButtonSize / 2, combat_GUIAlienBuyMenukUpgradeButtonSize, 0))
        buttonIcon:SetTexture(combat_GUIAlienBuyMenukBuyHUDTexture)
        // Render above the Alien image.
        buttonIcon:SetLayer(kGUILayerPlayerHUDForeground3)
        buttonIcon:SetParentRenders(false)
        buttonIcon:SetIsVisible(false)
        self.background:AddChild(buttonIcon)
        
        // The background is visible only inside the embryo.
        local buttonBackground = GUIManager:CreateGraphicItem()
        buttonBackground:SetSize(Vector(combat_GUIAlienBuyMenukUpgradeButtonSize, combat_GUIAlienBuyMenukUpgradeButtonSize, 0))
        buttonBackground:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
        buttonBackground:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukUpgradeButtonBackgroundTextureCoordinates))
        buttonBackground:SetStencilFunc(GUIItem.NotEqual)
        buttonBackground:SetIsVisible(false)
        buttonIcon:AddChild(buttonBackground)

        table.insert(self.upgradeButtons, { Background = buttonBackground, Icon = buttonIcon,
                                            Selected = false, SelectedMovePercent = 0, Cost = 0, Purchased = false, Index = nil })
        
    end
    
    // They all start off deselected.
    self:_DeselectAllUpgrades()
    self.initialSelect = true

end

function combat_GUIAlienBuyMenu:_UninitializeUpgradeButtons()

    for i, currentButton in ipairs(self.upgradeButtons) do
        GUI.DestroyItem(currentButton.Icon)
        GUI.DestroyItem(currentButton.Background)
    end
    self.upgradeButtons = { }

end

function combat_GUIAlienBuyMenu:_InitializeEvolveButton()

    self.selectedAlienType = CombatAlienBuy_GetCurrentAlien()
    
    self.evolveButtonBackground = GUIManager:CreateGraphicItem()
    self.evolveButtonBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.evolveButtonBackground:SetSize(Vector(combat_GUIAlienBuyMenukEvolveButtonWidth, combat_GUIAlienBuyMenukEvolveButtonHeight, 0))
    self.evolveButtonBackground:SetPosition(Vector(-combat_GUIAlienBuyMenukEvolveButtonWidth / 2, combat_GUIAlienBuyMenukEvolveButtonHeight / 2 + combat_GUIAlienBuyMenukEvolveButtonYOffset, 0))
    self.evolveButtonBackground:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.evolveButtonBackground:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukEvolveButtonTextureCoordinates))
    self.background:AddChild(self.evolveButtonBackground)
    
    self.evolveButtonVeins = GUIManager:CreateGraphicItem()
    self.evolveButtonVeins:SetSize(Vector(combat_GUIAlienBuyMenukEvolveButtonWidth, combat_GUIAlienBuyMenukEvolveButtonHeight, 0))
    self.evolveButtonVeins:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.evolveButtonVeins:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukEvolveButtonVeinsTextureCoordinates))
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, 0))
    self.evolveButtonBackground:AddChild(self.evolveButtonVeins)
    
    self.evolveButtonText = GUIManager:CreateTextItem()
    self.evolveButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.evolveButtonText:SetFontName(combat_GUIAlienBuyMenukFont)
    self.evolveButtonText:SetFontSize(combat_GUIAlienBuyMenukEvolveButtonTextSize)
    self.evolveButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.evolveButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.evolveButtonText:SetText("Evolve for ")
    self.evolveButtonText:SetColor(Color(0, 0, 0, 1))
    self.evolveButtonVeins:AddChild(self.evolveButtonText)
    
    self.evolveResourceIcon = GUIManager:CreateGraphicItem()
    self.evolveResourceIcon:SetSize(Vector(combat_GUIAlienBuyMenukResourceIconWidth, combat_GUIAlienBuyMenukResourceIconHeight, 0))
    self.evolveResourceIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.evolveResourceIcon:SetPosition(Vector(4, -combat_GUIAlienBuyMenukResourceIconHeight / 2, 0))
    self.evolveResourceIcon:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.evolveResourceIcon:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukResourceIconTextureCoordinates))
    self.evolveResourceIcon:SetIsVisible(false)
    self.evolveButtonText:AddChild(self.evolveResourceIcon)
    
    self.evolveButtonResAmount = GUIManager:CreateTextItem()
    self.evolveButtonResAmount:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.evolveButtonResAmount:SetPosition(Vector(0, 0, 0))
    self.evolveButtonResAmount:SetFontName(combat_GUIAlienBuyMenukFont)
    self.evolveButtonResAmount:SetFontSize(combat_GUIAlienBuyMenukEvolveButtonTextSize)
    self.evolveButtonResAmount:SetTextAlignmentX(GUIItem.Align_Min)
    self.evolveButtonResAmount:SetTextAlignmentY(GUIItem.Align_Center)
    self.evolveButtonResAmount:SetColor(Color(0, 0, 0, 1))
    self.evolveResourceIcon:AddChild(self.evolveButtonResAmount)

end

function combat_GUIAlienBuyMenu:_UninitializeEvolveButton()

    GUI.DestroyItem(self.evolveButtonResAmount)
    self.evolveButtonResAmount = nil
    
    GUI.DestroyItem(self.evolveResourceIcon)
    self.evolveResourceIcon = nil
    
    GUI.DestroyItem(self.evolveButtonText)
    self.evolveButtonText = nil
    
    GUI.DestroyItem(self.evolveButtonVeins)
    self.evolveButtonVeins = nil
    
    GUI.DestroyItem(self.evolveButtonBackground)
    self.evolveButtonBackground = nil
    
end

function combat_GUIAlienBuyMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.closeButton:SetSize(Vector(combat_GUIAlienBuyMenukCloseButtonSize, combat_GUIAlienBuyMenukCloseButtonSize, 0))
    self.closeButton:SetPosition(Vector(-combat_GUIAlienBuyMenukCloseButtonSize * 2, combat_GUIAlienBuyMenukCloseButtonSize, 0))
    self.closeButton:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    self.closeButton:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCloseButtonTextureCoordinates))
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.closeButtonSmoke = GUIParticleSystem()
    self.closeButtonSmoke:Initialize()
    
    self.closeButtonSmoke:AddParticleType("Smoke",
                                          { SetTexture = { combat_GUIAlienBuyMenukBuyMenuTexture },
                                            SetTexturePixelCoordinates = combat_GUIAlienBuyMenukSmokeSmallTextureCoordinates })
    
    local fadeInFunc = function(particle, lifetime) if lifetime <= 0.5 then particle.Item:SetColor(Color(1, 1, 1, lifetime / 2)) end end
    local fadeOutFunc = function(particle, lifetime) if lifetime > 0.5 then particle.Item:SetColor(Color(1, 1, 1, (1 - lifetime) / 2)) end end
    local scaleFunc = function(particle, lifetime) particle.Item:SetScale(Vector(0.5 + (1 - lifetime * 0.5), 0.5 + (1 - lifetime * 0.5), 0)) end
    local mainEmitter = { Name = "Main",
                          Position = Vector(0, 0, 0),
                          EmitOffsetLimits = { Min = Vector(-10, -10, 0), Max = Vector(10, 10, 0) },
                          SizeLimits = { MinX = 30, MaxX = 30, MinY = 15, MaxY = 15 },
                          VelocityLimits = { Min = Vector(-2, -1, 0), Max = Vector(10, 1, 0) },
                          AccelLimits = { Min = Vector(-0.01, -1, 0), Max = Vector(0.05, 1, 0) },
                          RateLimits = { Min = 0.1, Max = 0.2 },
                          LifeLimits = { Min = 6, Max = 8 },
                          LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.closeButtonSmoke:AddEmitter(mainEmitter)
    
    self.closeButtonSmoke:AddParticleTypeToEmitter("Smoke", "Main")
    
    self.closeButtonSmoke:AttachToItem(self.closeButton)
    self.closeButtonSmoke:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.closeButtonSmoke:SetLayer(kGUILayerPlayerHUDForeground3)
    self.closeButtonSmoke:FastForward(3)
    
end

function combat_GUIAlienBuyMenu:_UninitializeCloseButton()

    self.closeButtonSmoke:Uninitialize()
    self.closeButtonSmoke = nil
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function combat_GUIAlienBuyMenu:_InitializeGlowieParticles()

    self.glowieParticles = GUIParticleSystem()
    self.glowieParticles:Initialize()
    
    self.glowieParticles:AddParticleType("Glowie",
                                           { SetTexture = { combat_GUIAlienBuyMenukBuyMenuTexture },
                                             SetTexturePixelCoordinates = { combat_GUIAlienBuyMenukGlowieBigTextureCoordinates, combat_GUIAlienBuyMenukGlowieSmallTextureCoordinates },
                                             SetStencilFunc = { GUIItem.NotEqual } })
    
    local followVelocityFunc = function(particle, lifeTime)
                                   particle.Item:SetRotation(Vector(0, 0, math.atan2(particle.velocity.x, particle.velocity.y) - math.pi / 2))
                               end
    // The glowie will fade in until the lifetime is at this amount and then fade out for the rest of the time.
    local fadeInToLifetime = 0.3
    local fadeInFunc = function(particle, lifetime) if lifetime <= fadeInToLifetime then particle.Item:SetColor(Color(1, 1, 1, lifetime / fadeInToLifetime)) end end
    local fadeOutFunc = function(particle, lifetime) if lifetime > fadeInToLifetime then particle.Item:SetColor(Color(1, 1, 1, 1 - (lifetime - fadeInToLifetime) / (1 - fadeInToLifetime))) end end
    local scaleFunc = function(particle, lifetime) particle.Item:SetScale(Vector(0.5 + (lifetime * 0.5), 0.5 + (lifetime * 0.5), 0)) end
    local centerEmitter = { Name = "CenterBig",
                            Position = Vector(0, 0, 0),
                            EmitOffsetLimits = { Min = Vector(-100, -100, 0), Max = Vector(100, 100, 0) },
                            SizeLimits = { MinX = 15, MaxX = 15, MinY = 10, MaxY = 10 },
                            VelocityLimits = { Min = Vector(-1, -1, 0), Max = Vector(1, 1, 0) },
                            AccelLimits = { Min = Vector(-0.5, -0.5, 0), Max = Vector(0.5, 0.5, 0) },
                            RateLimits = { Min = 0.5, Max = 1.0 },
                            LifeLimits = { Min = 15, Max = 20 },
                            LifeTimeFuncs = { followVelocityFunc, fadeInFunc, fadeOutFunc, scaleFunc } }
    self.glowieParticles:AddEmitter(centerEmitter)
    
    self.glowieParticles:AddParticleTypeToEmitter("Glowie", "CenterBig")
    
    local randomTurnMod = function(particle, deltaTime)
                              if math.random() < 0.20 * deltaTime then
                                  particle.velocity = Vector(particle.velocity.y, -particle.velocity.x, 0)
                              end
                          end
    self.glowieParticles:AddModifier({ Name = "RandomTurn", ModFunc = randomTurnMod })
    
    local limitVelocityMod = function(particle, deltaTime)
                                 local particleSpeed = particle.velocity:GetLengthSquared()
                                 local maxSpeed = 5
                                 if particleSpeed >= maxSpeed * maxSpeed then
                                    particle.velocity = GetNormalizedVector(particle.velocity) * maxSpeed
                                 end
                             end
    self.glowieParticles:AddModifier({ Name = "VelocityLimit", ModFunc = limitVelocityMod })
    
    self.glowieParticles:AttachToItem(self.background)
    self.glowieParticles:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.glowieParticles:SetLayer(kGUILayerPlayerHUDForeground1)
    
    // Fast forward so particles already exist when the player first sees the menu.
    self.glowieParticles:FastForward(10)
    
    // We don't want the mouse affecting the particles until the player can see the particles, so add it after the FF.
    local mouseAttractMod = function(particle, deltaTime)
                                local itemScreenPosition = particle.Item:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
                                itemScreenPosition.x = itemScreenPosition.x + particle.Item:GetSize().x / 2
                                itemScreenPosition.y = itemScreenPosition.y + particle.Item:GetSize().y / 2
                                local mouseX, mouseY = Client.GetCursorPosScreen()
                                local mousePos = Vector(mouseX, mouseY, 0)
                                local attractDir = mousePos - itemScreenPosition
                                local attractForce = 1 - math.min(1, attractDir:GetLengthSquared() / (200 * 200))
                                particle.velocity = particle.velocity + (attractDir * attractForce * 0.5 * deltaTime)
                            end
    self.glowieParticles:AddModifier({ Name = "MouseAttract", ModFunc = mouseAttractMod })

end

function combat_GUIAlienBuyMenu:_UninitializeGlowieParticles()

    self.glowieParticles:Uninitialize()
    self.glowieParticles = nil

end

function combat_GUIAlienBuyMenu:_InitializeSmokeParticles()

    self.smokeParticles = GUIParticleSystem()
    self.smokeParticles:Initialize()
    
    self.smokeParticles:AddParticleType("SmokeBig",
                                          { SetTexture = { combat_GUIAlienBuyMenukBuyMenuTexture },
                                            SetTexturePixelCoordinates = combat_GUIAlienBuyMenukSmokeSmallTextureCoordinates })
    
    local fadeInFunc = function(particle, lifetime) if lifetime <= 0.5 then particle.Item:SetColor(Color(1, 1, 1, lifetime / 2)) end end
    local fadeOutFunc = function(particle, lifetime) if lifetime > 0.5 then particle.Item:SetColor(Color(1, 1, 1, (1 - lifetime) / 2)) end end
    local scaleFunc = function(particle, lifetime) particle.Item:SetScale(Vector(0.5 + (1 - lifetime * 0.5), 0.5 + (1 - lifetime * 0.5), 0)) end
    
    local tailEmitter = { Name = "Tail",
                          Position = Vector(0, 0, 0),
                          EmitOffsetLimits = { Min = Vector(0, -50, 0), Max = Vector(40, 50, 0) },
                          SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                          VelocityLimits = { Min = Vector(10, -10, 0), Max = Vector(40, 10, 0) },
                          AccelLimits = { Min = Vector(-0.05, -5, 0), Max = Vector(0.4, 5, 0) },
                          RateLimits = { Min = 0.05, Max = 0.1 },
                          LifeLimits = { Min = 3, Max = 5 },
                          LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(tailEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Tail")
    
    local topEmitter = { Name = "Top",
                         Position = Vector(GUIScale(-300), GUIScale(-150), 0),
                         EmitOffsetLimits = { Min = Vector(-80, -80, 0), Max = Vector(50, 20, 0) },
                         SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                         VelocityLimits = { Min = Vector(10, 0, 0), Max = Vector(40, 10, 0) },
                         AccelLimits = { Min = Vector(-0.05, 0, 0), Max = Vector(0.4, 2.5, 0) },
                         RateLimits = { Min = 0.1, Max = 0.2 },
                         LifeLimits = { Min = 10, Max = 15 },
                         LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(topEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Top")
    
    local bottomEmitter = { Name = "Bottom",
                            Position = Vector(GUIScale(-300), GUIScale(150), 0),
                            EmitOffsetLimits = { Min = Vector(-80, -20, 0), Max = Vector(50, 80, 0) },
                            SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                            VelocityLimits = { Min = Vector(10, -10, 0), Max = Vector(40, 0, 0) },
                            AccelLimits = { Min = Vector(-0.05, -2.5, 0), Max = Vector(0.4, 0, 0) },
                            RateLimits = { Min = 0.1, Max = 0.2 },
                            LifeLimits = { Min = 10, Max = 15 },
                            LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(bottomEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Bottom")
    
    local frontEmitter = { Name = "Front",
                           Position = Vector(GUIScale(-500), GUIScale(0), 0),
                           EmitOffsetLimits = { Min = Vector(-100, -20, 0), Max = Vector(0, 20, 0) },
                           SizeLimits = { MinX = 150, MaxX = 150, MinY = 100, MaxY = 100 },
                           VelocityLimits = { Min = Vector(20, -30, 0), Max = Vector(30, 30, 0) },
                           AccelLimits = { Min = Vector(-0.05, -5, 0), Max = Vector(0.4, 5, 0) },
                           RateLimits = { Min = 0.5, Max = 0.1 },
                           LifeLimits = { Min = 5, Max = 10 },
                           LifeTimeFuncs = { fadeInFunc, fadeOutFunc, scaleFunc } }
    self.smokeParticles:AddEmitter(frontEmitter)
    self.smokeParticles:AddParticleTypeToEmitter("SmokeBig", "Front")
    
    local mouseRepulseMod = function(particle, deltaTime)
                                local itemScreenPosition = particle.Item:GetScreenPosition(Client.GetScreenWidth(), Client.GetScreenHeight())
                                itemScreenPosition.x = itemScreenPosition.x + particle.Item:GetSize().x / 2
                                itemScreenPosition.y = itemScreenPosition.y + particle.Item:GetSize().y / 2
                                local mouseX, mouseY = Client.GetCursorPosScreen()
                                local mousePos = Vector(mouseX, mouseY, 0)
                                local repulsionDir = itemScreenPosition - mousePos
                                local repulsionForce = 1 - math.min(1, repulsionDir:GetLengthSquared() / (100 * 100))
                                particle.Item:SetPosition(particle.Item:GetPosition() + (repulsionDir * repulsionForce * 2 * deltaTime))
                            end
    self.smokeParticles:AddModifier({ Name = "MouseRepulse", ModFunc = mouseRepulseMod })
    
    self.smokeParticles:AttachToItem(self.background)
    self.smokeParticles:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.smokeParticles:SetLayer(kGUILayerPlayerHUDBackground)
    
    // Fast forward so particles already exist when the player first sees the menu.
    self.smokeParticles:FastForward(3)

end

function combat_GUIAlienBuyMenu:_UninitializeSmokeParticles()

    self.smokeParticles:Uninitialize()
    self.smokeParticles = nil
    
end

function combat_GUIAlienBuyMenu:_InitializeCorners()

    self.corners = { }
    
    local topLeftCorner = GUIManager:CreateGraphicItem()
    topLeftCorner:SetAnchor(GUIItem.Left, GUIItem.Top)
    topLeftCorner:SetSize(Vector(combat_GUIAlienBuyMenukCornerWidths.TopLeft, combat_GUIAlienBuyMenukCornerHeights.TopLeft, 0))
    topLeftCorner:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    topLeftCorner:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCornerTextureCoordinates.TopLeft))
    topLeftCorner:SetLayer(kGUILayerPlayerHUDBackground)
    topLeftCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.TopLeft = topLeftCorner
    
    local bottomLeftCorner = GUIManager:CreateGraphicItem()
    bottomLeftCorner:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    bottomLeftCorner:SetPosition(Vector(0, -combat_GUIAlienBuyMenukCornerHeights.BottomLeft, 0))
    bottomLeftCorner:SetSize(Vector(combat_GUIAlienBuyMenukCornerWidths.BottomLeft, combat_GUIAlienBuyMenukCornerHeights.BottomLeft, 0))
    bottomLeftCorner:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    bottomLeftCorner:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCornerTextureCoordinates.BottomLeft))
    bottomLeftCorner:SetLayer(kGUILayerPlayerHUDBackground)
    bottomLeftCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.BottomLeft = bottomLeftCorner
    
    local topRightCorner = GUIManager:CreateGraphicItem()
    topRightCorner:SetAnchor(GUIItem.Right, GUIItem.Top)
    topRightCorner:SetPosition(Vector(-combat_GUIAlienBuyMenukCornerWidths.TopRight, 0, 0))
    topRightCorner:SetSize(Vector(combat_GUIAlienBuyMenukCornerWidths.TopRight, combat_GUIAlienBuyMenukCornerHeights.TopRight, 0))
    topRightCorner:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    topRightCorner:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCornerTextureCoordinates.TopRight))
    topRightCorner:SetLayer(kGUILayerPlayerHUDBackground)
    topRightCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.TopRight = topRightCorner
    
    local bottomRightCorner = GUIManager:CreateGraphicItem()
    bottomRightCorner:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    bottomRightCorner:SetPosition(Vector(-combat_GUIAlienBuyMenukCornerWidths.BottomRight, -combat_GUIAlienBuyMenukCornerHeights.BottomRight, 0))
    bottomRightCorner:SetSize(Vector(combat_GUIAlienBuyMenukCornerWidths.BottomRight, combat_GUIAlienBuyMenukCornerHeights.BottomRight, 0))
    bottomRightCorner:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    bottomRightCorner:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCornerTextureCoordinates.BottomRight))
    bottomRightCorner:SetLayer(kGUILayerPlayerHUDBackground)
    bottomRightCorner:SetShader("shaders/GUIWavyNoMask.surface_shader")
    self.corners.BottomRight = bottomRightCorner
    
    self.cornerTweeners = { }
    for cornerName, _ in pairs(self.corners) do
        self.cornerTweeners[cornerName] = Tweener("loopforward")
        self.cornerTweeners[cornerName].add(combat_GUIAlienBuyMenukCornerPulseTime, { percent = 1 }, Easing.linear)
        self.cornerTweeners[cornerName].add(combat_GUIAlienBuyMenukCornerPulseTime, { percent = 0 }, Easing.linear)
    end

end

function combat_GUIAlienBuyMenu:_UninitializeCorners()

    for cornerName, cornerItem in pairs(self.corners) do
        GUI.DestroyItem(cornerItem)
    end
    self.corners = { }
    
    self.cornerTweeners = { }

end

local function GetSelectedUpgradesCost(self)

    local cost = 0
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected then
            cost = cost + currentButton.Cost
        end
        
    end
    
    return cost
    
end

local function GetNumberOfSelectedUpgrades(self)

    local numSelected = 0
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected and not currentButton.Purchased then
            numSelected = numSelected + 1
        end
        
    end
    
    return numSelected
    
end

local function GetCanAffordAlienTypeAndUpgrades(self, alienType)

    local alienCost = CombatAlienBuy_GetAlienCost(alienType)
    local upgradesCost = GetSelectedUpgradesCost(self)
    // Cannot buy the current alien without upgrades.
    if alienType == CombatAlienBuy_GetCurrentAlien() then
        alienCost = 0
    end
    
    return PlayerUI_GetPlayerResources() >= alienCost + upgradesCost - AlienBuy_GetHyperMutationCostReduction(self.selectedAlienType)
    
end

/**
 * Returns true if the player has a different Alien or any upgrade selected.
 */
local function GetAlienOrUpgradeSelected(self)
    return self.selectedAlienType ~= CombatAlienBuy_GetCurrentAlien() or GetNumberOfSelectedUpgrades(self) > 0
end

local function UpdateEvolveButton(self)

    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(combat_GUIAlienBuyMenukAlienTypes[self.selectedAlienType].Index)
    local selectedUpgradesCost = GetSelectedUpgradesCost(self)
    local numberOfSelectedUpgrades = GetNumberOfSelectedUpgrades(self)
    local evolveButtonTextureCoords = combat_GUIAlienBuyMenukEvolveButtonTextureCoordinates
    
    evolveText = "Select upgrades"
    
    // If the current alien is selected with no upgrades, cannot evolve.
    if self.selectedAlienType == CombatAlienBuy_GetCurrentAlien() and numberOfSelectedUpgrades == 0 then
        evolveButtonTextureCoords = combat_GUIAlienBuyMenukEvolveButtonNeedResourcesTextureCoordinates
    elseif researching then
    
        // If researching, cannot evolve.
        evolveButtonTextureCoords = combat_GUIAlienBuyMenukEvolveButtonNeedResourcesTextureCoordinates
        evolveText = "Researching..."
        
    elseif not GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) then
    
        // If cannot afford selected alien type and/or upgrades, cannot evolve.
        evolveButtonTextureCoords = combat_GUIAlienBuyMenukEvolveButtonNeedResourcesTextureCoordinates
        evolveText = "Need "
        evolveCost = CombatAlienBuy_GetAlienCost(self.selectedAlienType) + selectedUpgradesCost - AlienBuy_GetHyperMutationCostReduction(self.selectedAlienType)
        
    else
    
        // Evolution is possible! Darwin would be proud.
        local totalCost = selectedUpgradesCost
        
        // Cannot buy the current alien.
        if self.selectedAlienType ~= CombatAlienBuy_GetCurrentAlien() then
            totalCost = totalCost + CombatAlienBuy_GetAlienCost(self.selectedAlienType)
        end
        
        evolveText = "Evolve for "
        evolveCost = totalCost - AlienBuy_GetHyperMutationCostReduction(self.selectedAlienType) // shows also negative values
        
    end
            
    self.evolveButtonBackground:SetTexturePixelCoordinates(unpack(evolveButtonTextureCoords))
    self.evolveButtonText:SetText(evolveText)
    self.evolveResourceIcon:SetIsVisible(evolveCost ~= nil)
    local totalEvolveButtonTextWidth = 0
    
    if evolveCost ~= nil then
    
        local evolveCostText = ToString(evolveCost)
        self.evolveButtonResAmount:SetText(evolveCostText)
        totalEvolveButtonTextWidth = totalEvolveButtonTextWidth + self.evolveResourceIcon:GetSize().x +
                                     self.evolveButtonResAmount:GetTextWidth(evolveCostText)
        
    end
    
    self.evolveButtonText:SetPosition(Vector(-totalEvolveButtonTextWidth / 2, 0, 0))
    
    local allowedToEvolve = not researching and GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) and hasGameStarted
    allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
    local veinsAlpha = 0
    self.evolveButtonBackground:SetScale(Vector(1, 1, 0))
    
    if allowedToEvolve then
    
        if self:_GetIsMouseOver(self.evolveButtonBackground) then
        
            veinsAlpha = 1
            self.evolveButtonBackground:SetScale(Vector(1.1, 1.1, 0))
            
        else
            veinsAlpha = (math.sin(Shared.GetTime() * 4) + 1) / 2
        end
        
    end
    
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, veinsAlpha))
    
end

function combat_GUIAlienBuyMenu:Update(deltaTime)

    // Assume there is no mouse over info to start.
    self:_HideMouseOverInfo()
    
    //self:_UpdateResourceDisplay(deltaTime)
    
    self.currentAlienDisplay.Icon:SetTexture("ui/" .. combat_GUIAlienBuyMenukAlienTypes[self.selectedAlienType].Name .. ".dds")
    local width = combat_GUIAlienBuyMenukAlienTypes[self.selectedAlienType].Width
    local height = combat_GUIAlienBuyMenukAlienTypes[self.selectedAlienType].Height
    self.currentAlienDisplay.Icon:SetSize(Vector(width, height, 0))
    self.currentAlienDisplay.Icon:SetPosition(Vector((-width / 2), -height / 2, 0))
    
    self.currentAlienDisplay.TitleShadow:SetText(string.upper(combat_GUIAlienBuyMenukAlienTypes[self.selectedAlienType].Name))
    self.currentAlienDisplay.Title:SetText(string.upper(combat_GUIAlienBuyMenukAlienTypes[self.selectedAlienType].Name))
    
    self:_UpdateAlienButtons()
    
    UpdateEvolveButton(self)
    
    self:_UpdateUpgrades(deltaTime)
    
    self:_UpdateCloseButton(deltaTime)
    
    self:_UpdateParticles(deltaTime)
    
    self:_UpdateCorners(deltaTime)
    
    self:_UpdateAbilityIcons(deltaTime)
    
    table.foreach(self.upgradeTweeners, function(tweener) self.upgradeTweeners[tweener].update(deltaTime) end)
    
end

local function CreateAbilityIcon(self)

    local graphicItem = GetGUIManager():CreateGraphicItem()
    graphicItem:SetTexture(combat_GUIAlienBuyMenukBuyHUDTexture)
    graphicItem:SetSize(Vector(combat_GUIAlienBuyMenukUpgradeButtonSize, combat_GUIAlienBuyMenukUpgradeButtonSize, 0))
    graphicItem:SetAnchor(GUIItem.Right, GUIItem.Top)
    
    local highLight = GetGUIManager():CreateGraphicItem()
    highLight:SetSize(Vector(combat_GUIAlienBuyMenukUpgradeButtonSize, combat_GUIAlienBuyMenukUpgradeButtonSize, 0))
    highLight:SetIsVisible(false)
    highLight:SetTexture(combat_GUIAlienBuyMenukBuyMenuTexture)
    highLight:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukUpgradeButtonBackgroundTextureCoordinates))
    
    graphicItem:AddChild(highLight)    
    self.background:AddChild(graphicItem)
    
    return { Icon = graphicItem, TechId = kTechId.None, HighLight = highLight }

end

function combat_GUIAlienBuyMenu:_UpdateAbilityIcons()

    local availableAbilities = AlienBuy_GetAbilitiesFor(IndexToAlienTechId(self.selectedAlienType))
    
    if not self.currentAbilities then
        self.currentAbilities = {}
    end
    
    if #availableAbilities > #self.currentAbilities then
    
        for i = 1, #availableAbilities - #self.currentAbilities do
        
            table.insert(self.currentAbilities, CreateAbilityIcon(self))
        
        end
    
    end
    
    local xOffset = combat_GUIAlienBuyMenukUpgradeButtonSize * -2

    for index, abilityItem in ipairs(self.currentAbilities) do
    
        if availableAbilities[index] then
        
            abilityItem.Icon:SetIsVisible(true)
            abilityItem.TechId = availableAbilities[index]
            abilityItem.Icon:SetTexturePixelCoordinates(unpack( GetTextureCoordinatesForIcon(availableAbilities[index], false) ))
            abilityItem.Icon:SetPosition( Vector(combat_GUIAlienBuyMenukUpgradeButtonSize * index + xOffset, 0, 0) )
            
            local mouseOver = self:_GetIsMouseOver(abilityItem.Icon)    
            abilityItem.HighLight:SetIsVisible(mouseOver)
            
            if mouseOver then
            
                local abilityInfoText = Locale.ResolveString( LookupTechData(abilityItem.TechId, kTechDataDisplayName, "") )
                local tooltip = Locale.ResolveString( LookupTechData(abilityItem.TechId, kTechDataTooltipInfo, "") )
                
                if string.len(tooltip) > 0 then
                    abilityInfoText = abilityInfoText .. "\n" .. tooltip
                end
                
                self:_ShowMouseOverInfo(abilityInfoText, 0)
                
            end
        
        else
            abilityItem.Icon:SetIsVisible(false)
        end
    
    end

end

function combat_GUIAlienBuyMenu:_GetCanAffordAlienType(alienType)

    local alienCost = CombatAlienBuy_GetAlienCost(alienType)
    // Cannot buy the current alien without upgrades.
    if alienType == CombatAlienBuy_GetCurrentAlien() then
        return false
    end

    return PlayerUI_GetPlayerResources() >= alienCost - AlienBuy_GetHyperMutationCostReduction(alienType)
    
end

function combat_GUIAlienBuyMenu:_GetAlienTypeResearchInfo(alienType)
    local researched = true
    local researchProgress = AlienBuy_GetAlienResearchProgress(alienType)
    local researching = researchProgress > 0 and researchProgress < 1
    return researched, researchProgress, researching
end

function combat_GUIAlienBuyMenu:_GetNumberOfAliensAvailable()

    local numberResearched = 0
    for k, alienType in ipairs(combat_GUIAlienBuyMenukAlienTypes) do
        local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(alienType.Index)
        numberResearched = numberResearched + (((researched or researching) and 1) or 0)
    end
    return numberResearched

end

function combat_GUIAlienBuyMenu:_UpdateResourceDisplay(deltaTime)

    self.resourceDisplay:SetText(ToString(PlayerUI_GetPlayerResources()))
    self.resourceDisplayParticles:Update(deltaTime)

end

function combat_GUIAlienBuyMenu:_UpdateAlienButtons()

    local numAlienTypes = self:_GetNumberOfAliensAvailable()
    local totalAlienButtonsWidth = combat_GUIAlienBuyMenukAlienButtonSize * numAlienTypes
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    for k, alienButton in ipairs(self.alienButtons) do
    
        // Info needed for the rest of this code.
        local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(alienButton.TypeData.Index)
        researched = true
        
        local buttonIsVisible = true
        alienButton.Button:SetIsVisible(buttonIsVisible)
        
        // Don't bother updating anything else unless it is visible.
        if buttonIsVisible then
        
            local isCurrentAlien = CombatAlienBuy_GetCurrentAlien() == alienButton.TypeData.Index
            if researched and (isCurrentAlien or self:_GetCanAffordAlienType(alienButton.TypeData.Index)) then
                alienButton.Button:SetColor(combat_GUIAlienBuyMenukEnabledColor)
            elseif researched and not self:_GetCanAffordAlienType(alienButton.TypeData.Index) then
                alienButton.Button:SetColor(combat_GUIAlienBuyMenukCannotBuyColor)
            elseif researching then
                alienButton.Button:SetColor(combat_GUIAlienBuyMenukDisabledColor)
            end
            
            local mouseOver = self:_GetIsMouseOver(alienButton.Button)
            
            if mouseOver then
                local classStats = CombatAlienBuy_GetClassStats(combat_GUIAlienBuyMenukAlienTypes[alienButton.TypeData.Index].Index)
                local mouseOverName = string.upper(combat_GUIAlienBuyMenukAlienTypes[alienButton.TypeData.Index].Name)
                self:_ShowMouseOverInfo(mouseOverName .. "\n" .. ToString(classStats[2]) .. " Health\n" .. ToString(classStats[3]) .. " Armor", classStats[4])
            end
            
            // Only show the background if the mouse is over this button.
            alienButton.SelectedBackground:SetColor(Color(1, 1, 1, ((mouseOver and 1) or 0)))

            local offset = Vector((((alienButton.TypeData.XPos - 1) / numAlienTypes) * (combat_GUIAlienBuyMenukAlienButtonSize * numAlienTypes)) - (totalAlienButtonsWidth / 2), 0, 0)
            alienButton.SelectedBackground:SetPosition(Vector(-combat_GUIAlienBuyMenukAlienButtonSize / 2, -combat_GUIAlienBuyMenukAlienSelectedButtonSize / 2 - alienButton.ARAdjustedHeight / 2, 0) + offset)

            alienButton.PlayersText:SetText("x" .. ToString(ScoreboardUI_GetNumberOfAliensByType(alienButton.TypeData.Name)))
            
            alienButton.ResearchText:SetIsVisible(researching)
            if researching then
                alienButton.ResearchText:SetText(string.format("%d%%", researchProgress * 100))
            end
            
        end
        
    end

end

function combat_GUIAlienBuyMenu:_UpdateUpgrades(deltaTime)

    for i, currentButton in ipairs(self.upgradeButtons) do
        currentButton.Icon:SetIsVisible(false)
    end
    
    local allUpgrades = { }
    
    local upgradeIndex = 0
    
    local numElementsPerPurchasedUpgrades = 7
    local purchasedUpgrades = CombatAlienBuy_GetPurchasedUpgrades(self.selectedAlienType)
    numPurchasedUpgrades = table.count(purchasedUpgrades) / numElementsPerPurchasedUpgrades
    for i = 0, numPurchasedUpgrades - 1 do
        local currentIndex = i * numElementsPerPurchasedUpgrades + 1
        local currentUpgrade = { }
        currentUpgrade.IconXOffset = purchasedUpgrades[currentIndex] * combat_GUIAlienBuyMenukUpgradeButtonTextureSize
        currentUpgrade.IconYOffset = purchasedUpgrades[currentIndex + 1] * combat_GUIAlienBuyMenukUpgradeButtonTextureSize
        currentUpgrade.Name = purchasedUpgrades[currentIndex + 2]
        currentUpgrade.Tooltip = purchasedUpgrades[currentIndex + 3]
        currentUpgrade.Purchased = true
        currentUpgrade.TechId = purchasedUpgrades[currentIndex + 4]
        currentUpgrade.Available = purchasedUpgrades[currentIndex + 5]
        
        if self.initialSelect == true then
            currentUpgrade.Selected = true
            currentUpgrade.Initialized = true
        end
        
        currentUpgrade.Index = upgradeIndex
        upgradeIndex = upgradeIndex + 1
        
        table.insert(allUpgrades, currentUpgrade)
    end
    
    local numElementsPerUnpurchasedUpgrades = 8
    local unpurchasedUpgrades = CombatAlienBuy_GetUnpurchasedUpgrades(self.selectedAlienType)
    local numUnpurchasedUpgrades = table.count(unpurchasedUpgrades) / numElementsPerUnpurchasedUpgrades
    for i = 0, numUnpurchasedUpgrades - 1 do
        local currentIndex = i * numElementsPerUnpurchasedUpgrades + 1
        local currentUpgrade = { }
        currentUpgrade.IconXOffset = unpurchasedUpgrades[currentIndex] * combat_GUIAlienBuyMenukUpgradeButtonTextureSize
        currentUpgrade.IconYOffset = unpurchasedUpgrades[currentIndex + 1] * combat_GUIAlienBuyMenukUpgradeButtonTextureSize
        currentUpgrade.Name = unpurchasedUpgrades[currentIndex + 2]
        currentUpgrade.Tooltip = unpurchasedUpgrades[currentIndex + 3]
        currentUpgrade.ResearchPercent = unpurchasedUpgrades[currentIndex + 4]
        currentUpgrade.Cost = unpurchasedUpgrades[currentIndex + 5]
        currentUpgrade.Purchased = false
        currentUpgrade.Index = upgradeIndex
        currentUpgrade.TechId = unpurchasedUpgrades[currentIndex + 6]
        // All ups are availabe
        currentUpgrade.Available = CombatAlienBuy_GetGotRequirements(currentUpgrade.TechId)
        upgradeIndex = upgradeIndex + 1
        table.insert(allUpgrades, currentUpgrade)
    end
    
    local numberOfUpgrades = table.count(allUpgrades)
    ASSERT(numberOfUpgrades <= combat_GUIAlienBuyMenukMaxNumberOfUpgradeButtons)

    local offsetAmount = math.pi / 9
    local buttonAngles = {  math.pi / 2, 
                            math.pi / 2 + offsetAmount, 
                            math.pi / 2 - offsetAmount,
                            math.pi / 2 + offsetAmount * 2, 
                            math.pi / 2 - offsetAmount * 2,
                            math.pi / 2 + offsetAmount * 3, 
                            math.pi / 2 - offsetAmount * 3,
                            math.pi / 2 + offsetAmount * 4 ,
                            math.pi / 2 - offsetAmount * 4 
                        }
                        
    local numSelected = 0

    for i, currentUpgrade in ipairs(allUpgrades) do
    
        local currentButton = self.upgradeButtons[i + 1]
        currentButton.Cost = (currentUpgrade.Cost ~= nil and currentUpgrade.Cost) or 0
        currentButton.Purchased = currentUpgrade.Purchased
        currentButton.Index = currentUpgrade.Index
        currentButton.Icon:SetIsVisible(true)
        local xOffset = currentUpgrade.IconXOffset
        local yOffset = currentUpgrade.IconYOffset
        currentButton.Icon:SetTexturePixelCoordinates(xOffset, yOffset, xOffset + combat_GUIAlienBuyMenukUpgradeButtonTextureSize, yOffset + combat_GUIAlienBuyMenukUpgradeButtonTextureSize)

        // The movementScaleAdjust will make the button get smaller the closer it is to the center of the movement.
        local movementScaleAdjust = 0
        local buttonDistance = combat_GUIAlienBuyMenukUpgradeButtonDistance
        currentButton.Available = currentUpgrade.Available
        
        if currentUpgrade.Initialized then
        
            buttonDistance = buttonDistance - combat_GUIAlienBuyMenukUpgradeButtonDistanceInside
            currentUpgrade.Initialized = false
            local currentTweener = self:_GetUpgradeTweener(currentButton)
            currentTweener.setCurrent(1)
            currentTweener.setMode("forward")
            currentButton.Selected = true
            currentButton.SelectedMovePercent = 1
            
        else
        
            currentButton.SelectedMovePercent = self:_GetUpgradeTweener(currentButton).getCurrentProperties().percent
            local distanceToCenter = math.abs(0.5 - currentButton.SelectedMovePercent)
            // Percent goes from 0 - 1 - 0 when moving to center and then back out.
            local distanceToCenterPercent = 1 - (distanceToCenter / 0.5)
            // Get smaller the closer to the center.
            movementScaleAdjust = -(distanceToCenterPercent * 0.5)
            buttonDistance = buttonDistance - combat_GUIAlienBuyMenukUpgradeButtonDistanceInside * currentButton.SelectedMovePercent
            
        end
        
        local positionOffset = Vector(math.cos(buttonAngles[i]) * buttonDistance, math.sin(buttonAngles[i]) * buttonDistance, 0)
        local buttonPosition = Vector(positionOffset.x - combat_GUIAlienBuyMenukUpgradeButtonSize / 2, positionOffset.y - combat_GUIAlienBuyMenukUpgradeButtonSize / 2, 0)
        currentButton.Icon:SetPosition(buttonPosition)
        
        // Do not show backgrounds for purchased buttons.
        currentButton.Background:SetIsVisible(not currentUpgrade.Purchased)
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local mouseOverButton = self:_GetIsMouseOver(currentButton.Icon)
        
        local iconColor = ConditionalValue(currentButton.Available, Color(1,1,1,1), Color(1,0,0,1))
        
        // Only moused over, unpurchased upgrades should look clickable (scale up).
        local mouseOverScale = ((mouseOverButton) and (Vector(1.1, 1.1, 0) ) ) or (Vector(1, 1, 0) )
        currentButton.Icon:SetScale(mouseOverScale + Vector(movementScaleAdjust, movementScaleAdjust, 0))
        currentButton.Icon:SetColor(iconColor)
        
        if mouseOverButton then
        
            local currentUpgradeInfoText = currentUpgrade.Name
            if string.len(currentUpgrade.Tooltip) > 0 then
                currentUpgradeInfoText = currentUpgradeInfoText .. "\n" .. currentUpgrade.Tooltip
            end
            self:_ShowMouseOverInfo(currentUpgradeInfoText, currentUpgrade.Cost)
            currentButton.Background:SetScale(mouseOverScale)
            
        else
            currentButton.Background:SetScale(Vector(1, 1, 0))
        end
        
        if currentButton.Selected == true then
            numSelected = numSelected + 1
        end
        
        currentButton.TechId = currentUpgrade.TechId
        
        i = i + 1
        
    end
    
    self.initialSelect = false
    self.numSelectedUpgrades = numSelected

end

function combat_GUIAlienBuyMenu:_UpdateCloseButton(deltaTime)

    self.closeButton:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCloseButtonTextureCoordinates))
    if self:_GetIsMouseOver(self.closeButton) then
        self.closeButton:SetTexturePixelCoordinates(unpack(combat_GUIAlienBuyMenukCloseButtonRollOverTextureCoordinates))
    end
    
    self.closeButtonSmoke:Update(deltaTime)

end

function combat_GUIAlienBuyMenu:_UpdateParticles(deltaTime)

    self.glowieParticles:Update(deltaTime)
    self.smokeParticles:Update(deltaTime)

end

function combat_GUIAlienBuyMenu:_UpdateCorners(deltaTime)

    table.foreach(self.cornerTweeners,
        function(corner)
            self.cornerTweeners[corner].update(deltaTime)
            local percent = self.cornerTweeners[corner].getCurrentProperties().percent
            self.corners[corner]:SetColor(Color(1, percent, percent, math.abs(percent - 0.5) + 0.5))
        end)

end

function combat_GUIAlienBuyMenu:_ShowMouseOverInfo(infoText, costAmount)

    self.mouseOverInfo:SetIsVisible(true)
    self.mouseOverInfo:SetText(infoText)
    self.mouseOverInfo:SetTextClipped(true, kTooltipTextWidth, 1024)
    
    self.mouseOverInfoResIcon:SetIsVisible(costAmount ~= nil)
    if costAmount then
        self.mouseOverInfoResAmount:SetText(ToString(costAmount))
    end

end

function combat_GUIAlienBuyMenu:_HideMouseOverInfo()

    self.mouseOverInfo:SetIsVisible(false)
    self.mouseOverInfoResIcon:SetIsVisible(false)
    
end


function combat_GUIAlienBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            // Check if the evolve button was selected.
            local allowedToEvolve = GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType)
            allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
            if allowedToEvolve and self:_GetIsMouseOver(self.evolveButtonBackground) then
            
                local purchases = { }
                // Buy the selected alien if we have a different one selected.
                
                if self.selectedAlienType ~= CombatAlienBuy_GetCurrentAlien() then
                    if CombatAlienBuy_GetCurrentAlien() == 5 then
                        // only buy another calss when youre a skulk
                        table.insert(purchases, CombatAlienBuy_GetTechIdForAlien(self.selectedAlienType))
                    end
                else
                
                    // Buy all selected upgrades.
                    for i, currentButton in ipairs(self.upgradeButtons) do
                    
                        if currentButton.Selected then
                            table.insert(purchases, currentButton.TechId)
                        end
                        
                    end
                
                end
                
                self:_DeselectAllUpgrades()
                
                closeMenu = true
                inputHandled = true
                
                if table.maxn(purchases)  > 0 then
                    CombatAlienBuy_Purchase(purchases)
                end
                
                AlienBuy_OnPurchase()
                
            end
            
            inputHandled = self:_HandleUpgradeClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                // Check if an alien was selected.
                for k, buttonItem in ipairs(self.alienButtons) do
                    
                    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(buttonItem.TypeData.Index)
                    if (researched or researching) and self:_GetIsMouseOver(buttonItem.Button) then
                        
                        if (CombatAlienBuy_GetCurrentAlien() == 5) then
                            // Deselect all upgrades when a different alien type is selected.
                            if self.selectedAlienType ~= buttonItem.TypeData.Index  then
                                AlienBuy_OnSelectAlien(combat_GUIAlienBuyMenukAlienTypes[buttonItem.TypeData.Index].Name)
                            end
                            
                            self.selectedAlienType = buttonItem.TypeData.Index
                            inputHandled = true
                            break
    
                        end
                        
                    end
                    
                end
                
                // Check if the close button was pressed.
                if self:_GetIsMouseOver(self.closeButton) then
                
                    closeMenu = true
                    inputHandled = true
                    AlienBuy_OnClose()
                    
                end
                
            end
            
        end
        
    end
    
    // AlienBuy_Close() must be the last thing called.
    if closeMenu then
    
        self.closingMenu = true
        AlienBuy_Close()
        
    end
    
    return inputHandled
    
end

function combat_GUIAlienBuyMenu:_GetUpgradeTweener(forButton)

    ASSERT(forButton ~= nil)
    
    if self.upgradeTweeners[forButton] == nil then
        self.upgradeTweeners[forButton] = Tweener("forward")
        local amplitude = 0.005
        local period = combat_GUIAlienBuyMenukUpgradeButtonMoveTime * 0.75
        self.upgradeTweeners[forButton].add(combat_GUIAlienBuyMenukUpgradeButtonMoveTime, { percent = 0 }, Easing.outElastic, { amplitude, period })
        self.upgradeTweeners[forButton].add(combat_GUIAlienBuyMenukUpgradeButtonMoveTime, { percent = 1 }, Easing.outElastic, { amplitude, period })
    end
    return self.upgradeTweeners[forButton]

end

function combat_GUIAlienBuyMenu:_DeselectAllUpgrades()

    for i, currentButton in ipairs(self.upgradeButtons) do
    
        currentButton.Selected = false
        currentButton.SelectedMovePercent = 0
        local currentTweener = self:_GetUpgradeTweener(currentButton)
        currentTweener.setCurrent(1)
        currentTweener.setMode("backward")
        // Just assume it will be invisible for now.
        currentButton.Background:SetIsVisible(false)
        
    end
    
    self.numSelectedUpgrades = 0

end

// only 1 upgrade should be selectable
function combat_GUIAlienBuyMenu:_GetHasMaximumSelected()
    // only 1 upgrade should be selectable, but already bought ups are OK
    return self.numSelectedUpgrades - numPurchasedUpgrades >= 20
end

function combat_GUIAlienBuyMenu:_HandleUpgradeClicked(mouseX, mouseY)

    local inputHandled = false
    
    for i, currentButton in ipairs(self.upgradeButtons) do
        // Can't select if it has been purchased already.
        if (not self:_GetHasMaximumSelected() or currentButton.Selected == true) and self:_GetIsMouseOver(currentButton.Icon) then
            currentButton.Selected = not currentButton.Selected
            inputHandled = true
            if currentButton.Selected then AlienBuy_OnUpgradeSelected() else AlienBuy_OnUpgradeDeselected() end
            // Setup a tweener based on the state of the button so it moves to the correct spot.
            local currentTweener = self:_GetUpgradeTweener(currentButton)
            currentTweener.setCurrent((currentButton.Selected and 1) or 2)
            currentTweener.setMode((currentButton.Selected and "forward") or "backward")
        end
    end
    
    return inputHandled

end

/**
 * Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
 */
function combat_GUIAlienBuyMenu:_GetIsMouseOver(overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        AlienBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end

function combat_GUIAlienBuyMenu:OnClose()

    // Check if GUIAlienBuyMenu is what is causing itself to close.
    if not self.closingMenu then
        // Play the close sound since we didn't trigger the close.
        AlienBuy_OnClose()
    end

end