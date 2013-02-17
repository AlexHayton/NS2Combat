//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// modified from GuiExploreHint


Script.Load("lua/GUIScript.lua")
Script.Load("lua/NS2Utility.lua")

class 'GUIEemHint' (GUIScript)

GUIEemHint.kAlienBackgroundTexture = "ui/alien_commander_background.dds"
GUIEemHint.kMarineBackgroundTexture = "ui/marine_commander_background.dds"

GUIEemHint.kBackgroundTopCoords = { X1 = 758, Y1 = 452, X2 = 987, Y2 = 487 }
GUIEemHint.kBackgroundTopHeight = GUIEemHint.kBackgroundTopCoords.Y2 - GUIEemHint.kBackgroundTopCoords.Y1
GUIEemHint.kBackgroundCenterCoords = { X1 = 758, Y1 = 487, X2 = 987, Y2 = 505 }
GUIEemHint.kBackgroundBottomCoords = { X1 = 758, Y1 = 505, X2 = 987, Y2 = 536 }
GUIEemHint.kBackgroundBottomHeight = GUIEemHint.kBackgroundBottomCoords.Y2 - GUIEemHint.kBackgroundBottomCoords.Y1

GUIEemHint.kBackgroundExtraXOffset = 20
GUIEemHint.kBackgroundExtraYOffset = 20

GUIEemHint.kTextXOffset = 30
GUIEemHint.kTextYOffset = 17

GUIEemHint.kResourceIconSize = 32
GUIEemHint.kResourceIconTextureWidth = 32
GUIEemHint.kResourceIconTextureHeight = 32
GUIEemHint.kResourceIconXOffset = -30
GUIEemHint.kResourceIconYOffset = 20

GUIEemHint.kResourceIconTextureCoordinates = { }
// Team coordinates.
table.insert(GUIEemHint.kResourceIconTextureCoordinates, { X1 = 844, Y1 = 412, X2 = 882, Y2 = 450 })
// Personal coordinates.
table.insert(GUIEemHint.kResourceIconTextureCoordinates, { X1 = 774, Y1 = 417, X2 = 804, Y2 = 446 })
// Energy coordinates.
table.insert(GUIEemHint.kResourceIconTextureCoordinates, { X1 = 828, Y1 = 546, X2 = 859, Y2 = 577 })
// Ammo coordinates.
table.insert(GUIEemHint.kResourceIconTextureCoordinates, { X1 = 828, Y1 = 546, X2 = 859, Y2 = 577 })

GUIEemHint.kResourceColors = { Color(0, 1, 0, 1), Color(0.2, 0.4, 1, 1), Color(1, 0, 1, 1) }

GUIEemHint.kCostXOffset = -2

GUIEemHint.kRequiresTextMaxHeight = 32
GUIEemHint.kRequiresYOffset = 10

GUIEemHint.kEnablesTextMaxHeight = 48
GUIEemHint.kEnablesYOffset = 10

GUIEemHint.kInfoTextMaxHeight = 48
GUIEemHint.kInfoYOffset = 10

local kTooltipDuration = 1.5

local kExploreModeTextPos = GUIScale( Vector(0, 90, 0) )
local kExploreModeFontScale = GUIScale( Vector(1, 1, 0) )

function GUIEemHint:Initialize()

     self.flashColor = Color(1,1,1,0)

    self.textureName = GUIEemHint.kMarineBackgroundTexture
    if PlayerUI_IsOnAlienTeam() then
        self.textureName = GUIEemHint.kAlienBackgroundTexture
    end
    
    self.tooltipWidth = GUIScale(320)
    self.tooltipHeight = GUIScale(32)
    
    self.tooltipX = 0
    self.tooltipY = 0
    
    self:InitializeBackground()
    
    self.text = GUIManager:CreateTextItem()
    self.text:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.text:SetTextAlignmentX(GUIItem.Align_Min)
    self.text:SetTextAlignmentY(GUIItem.Align_Min)
    self.text:SetPosition(Vector(GUIEemHint.kTextXOffset, GUIEemHint.kTextYOffset, 0))
    self.text:SetColor(Color(1, 1, 1, 1))
    self.text:SetFontIsBold(true)
    self.text:SetFontName("fonts/AgencyFB_medium.fnt")
    self.text:SetInheritsParentAlpha(true)
    self.background:AddChild(self.text)
    
    self.resourceIcon = GUIManager:CreateGraphicItem()
    self.resourceIcon:SetSize(Vector(GUIEemHint.kResourceIconSize, GUIEemHint.kResourceIconSize, 0))
    self.resourceIcon:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.resourceIcon:SetPosition(Vector(-GUIEemHint.kResourceIconSize + GUIEemHint.kResourceIconXOffset, GUIEemHint.kResourceIconYOffset, 0))
    self.resourceIcon:SetTexture(self.textureName)
    self.resourceIcon:SetIsVisible(false)
    self.resourceIcon:SetInheritsParentAlpha(true)
    self.background:AddChild(self.resourceIcon)
    
    self.cost = GUIManager:CreateTextItem()
    self.cost:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.cost:SetTextAlignmentX(GUIItem.Align_Max)
    self.cost:SetTextAlignmentY(GUIItem.Align_Center)
    self.cost:SetPosition(Vector(GUIEemHint.kCostXOffset, GUIEemHint.kResourceIconSize / 2, 0))
    self.cost:SetColor(Color(1, 1, 1, 1))
    self.cost:SetFontIsBold(true)
    self.cost:SetInheritsParentAlpha(true)
    self.cost:SetFontName("fonts/AgencyFB_small.fnt")
    self.resourceIcon:AddChild(self.cost)
    
    self.requires = GUIManager:CreateTextItem()
    self.requires:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.requires:SetTextAlignmentX(GUIItem.Align_Min)
    self.requires:SetTextAlignmentY(GUIItem.Align_Min)
    self.requires:SetColor(Color(1, 0, 0, 1))
    self.requires:SetText("Requires:")
    self.requires:SetFontIsBold(true)
    self.requires:SetIsVisible(false)
    self.requires:SetInheritsParentAlpha(true)
    self.background:AddChild(self.requires)
    
    self.requiresInfo = GUIManager:CreateTextItem()
    self.requiresInfo:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.requiresInfo:SetTextAlignmentX(GUIItem.Align_Min)
    self.requiresInfo:SetTextAlignmentY(GUIItem.Align_Min)
    self.requiresInfo:SetPosition(Vector(0, 0, 0))
    self.requiresInfo:SetColor(Color(1, 1, 1, 1))
    self.requiresInfo:SetFontIsBold(true)
    self.requiresInfo:SetTextClipped(true, self.tooltipWidth - GUIEemHint.kTextXOffset * 2, GUIEemHint.kRequiresTextMaxHeight)
    self.requiresInfo:SetInheritsParentAlpha(true)
    self.requires:AddChild(self.requiresInfo)
    
    self.enables = GUIManager:CreateTextItem()
    self.enables:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.enables:SetTextAlignmentX(GUIItem.Align_Min)
    self.enables:SetTextAlignmentY(GUIItem.Align_Min)
    self.enables:SetColor(Color(0, 1, 0, 1))
    self.enables:SetText("Enables:")
    self.enables:SetFontIsBold(true)
    self.enables:SetIsVisible(false)
    self.enables:SetInheritsParentAlpha(true)
    self.background:AddChild(self.enables)
    
    self.enablesInfo = GUIManager:CreateTextItem()
    self.enablesInfo:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.enablesInfo:SetTextAlignmentX(GUIItem.Align_Min)
    self.enablesInfo:SetTextAlignmentY(GUIItem.Align_Min)
    self.enablesInfo:SetPosition(Vector(0, 0, 0))
    self.enablesInfo:SetColor(Color(1, 1, 1, 1))
    self.enablesInfo:SetFontIsBold(true)
    self.enablesInfo:SetTextClipped(true, self.tooltipWidth - GUIEemHint.kTextXOffset * 2, GUIEemHint.kEnablesTextMaxHeight)
    self.enablesInfo:SetInheritsParentAlpha(true)
    self.enables:AddChild(self.enablesInfo)
    
    self.info = GUIManager:CreateTextItem()
    self.info:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.info:SetTextAlignmentX(GUIItem.Align_Min)
    self.info:SetTextAlignmentY(GUIItem.Align_Min)
    self.info:SetColor(Color(1, 1, 1, 1))
    self.info:SetFontIsBold(false)
    self.info:SetTextClipped(true, self.tooltipWidth - GUIEemHint.kTextXOffset * 2, GUIEemHint.kInfoTextMaxHeight)
    self.info:SetIsVisible(false)
    self.info:SetInheritsParentAlpha(true)
    self.info:SetFontName("fonts/AgencyFB_tiny.fnt")
    self.background:AddChild(self.info)

    self.backGroundColor = Color(1,1,1,0)
    self.timeLastData = 0
    self:SetBackgroundColor(self.backGroundColor)
    
end

function GUIEemHint:InitializeBackground()

    self.backgroundTop = GUIManager:CreateGraphicItem()
    self.backgroundTop:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.backgroundTop:SetSize(Vector(self.tooltipWidth, self.tooltipHeight, 0))
    self.backgroundTop:SetTexture(self.textureName)
    GUISetTextureCoordinatesTable(self.backgroundTop, GUIEemHint.kBackgroundTopCoords)
    
    self.background = self.backgroundTop
    
    self.backgroundCenter = GUIManager:CreateGraphicItem()
    self.backgroundCenter:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.backgroundCenter:SetSize(Vector(self.tooltipWidth, self.tooltipHeight, 0))
    self.backgroundCenter:SetTexture(self.textureName)
    GUISetTextureCoordinatesTable(self.backgroundCenter, GUIEemHint.kBackgroundCenterCoords)
    self.backgroundTop:AddChild(self.backgroundCenter)
    
    self.backgroundBottom = GUIManager:CreateGraphicItem()
    self.backgroundBottom:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.backgroundBottom:SetSize(Vector(self.tooltipWidth, GUIEemHint.kBackgroundBottomHeight, 0))
    self.backgroundBottom:SetTexture(self.textureName)
    GUISetTextureCoordinatesTable(self.backgroundBottom, GUIEemHint.kBackgroundBottomCoords)
    self.backgroundCenter:AddChild(self.backgroundBottom)
    
    self.flash = GUIManager:CreateGraphicItem()
    self.flash:SetBlendTechnique(GUIItem.Add)
    self.backgroundTop:AddChild(self.flash)

end

function GUIEemHint:SetBackgroundColor(color)

    self.backgroundTop:SetColor(color)
    self.backgroundCenter:SetColor(color)
    self.backgroundBottom:SetColor(color)

end

function GUIEemHint:Uninitialize()

    // Everything is attached to the background so uninitializing it will destroy all items.
    if self.background then
        GUI.DestroyItem(self.background)
    end
    
    if self.exploreModeText then
        GUI.DestroyItem(self.exploreModeText)
    end
    
end

function GUIEemHint:UpdateData(text, hotkey, costNumber, requires, enables, info, typeNumber)

    self.backGroundColor.a = 1
    self.timeLastData = Shared.GetTime()
    self:SetBackgroundColor(self.backGroundColor)

    local totalTextHeight = self:CalculateTotalTextHeight(text, requires, enables, info)
    self:UpdateSizeAndPosition(totalTextHeight)

    self.text:SetText(text)
    if costNumber > 0 and typeNumber > 0 then
        self.resourceIcon:SetIsVisible(true)
        GUISetTextureCoordinatesTable(self.resourceIcon, GUIEemHint.kResourceIconTextureCoordinates[typeNumber])
        self.cost:SetText(ToString(costNumber))
        //self.cost:SetColor(GUIEemHint.kResourceColors[typeNumber])
    else
        self.resourceIcon:SetIsVisible(false)
    end
    
    local nextYPosition = self.text:GetPosition().y + self.text:GetTextHeight(text)
    if string.len(requires) > 0 then
        self.requires:SetIsVisible(true)
        nextYPosition = nextYPosition + GUIEemHint.kRequiresYOffset
        self.requires:SetPosition(Vector(GUIEemHint.kTextXOffset, nextYPosition, 0))
        self.requiresInfo:SetText(requires)
    else
        self.requires:SetIsVisible(false)
    end
    
    if self.requires:GetIsVisible() then
        nextYPosition = self.requires:GetPosition().y + self.requires:GetTextHeight(self.requires:GetText()) + self.requiresInfo:GetTextHeight(self.requiresInfo:GetText())
    end
    
    if string.len(enables) > 0 then
        nextYPosition = nextYPosition + GUIEemHint.kEnablesYOffset
        self.enables:SetIsVisible(true)
        self.enables:SetPosition(Vector(GUIEemHint.kTextXOffset, nextYPosition, 0))
        self.enablesInfo:SetText(enables)
    else
        self.enables:SetIsVisible(false)
    end
    
    if self.enables:GetIsVisible() then
        nextYPosition = self.enables:GetPosition().y + self.enables:GetTextHeight(self.enables:GetText()) + self.enablesInfo:GetTextHeight(self.enablesInfo:GetText())
    end

    if string.len(info) > 0 then
        nextYPosition = nextYPosition + GUIEemHint.kInfoYOffset
        self.info:SetIsVisible(true)
        self.info:SetPosition(Vector(GUIEemHint.kTextXOffset, nextYPosition, 0))
        self.info:SetText(info)
    else
        self.info:SetIsVisible(false)
    end
    
end

// Determine the height of the tooltip based on all the text inside of it.
function GUIEemHint:CalculateTotalTextHeight(text, requires, enables, info)

    local totalHeight = 0
    
    if string.len(text) > 0 then
        totalHeight = totalHeight + self.text:GetTextHeight(text)
    end
    
    if string.len(requires) > 0 then
        totalHeight = totalHeight + self.requiresInfo:GetTextHeight(requires)
    end
    
    if string.len(enables) > 0 then
        totalHeight = totalHeight + self.enablesInfo:GetTextHeight(enables)
    end
    
    if string.len(info) > 0 then
        totalHeight = totalHeight + self.info:GetTextHeight(info)
    end
    
    return totalHeight

end

function GUIEemHint:UpdateSizeAndPosition(totalTextHeight)
    
    local topAndBottomHeight = GUIEemHint.kBackgroundTopHeight - GUIEemHint.kBackgroundBottomHeight
    local adjustedHeight = self.tooltipHeight + totalTextHeight - topAndBottomHeight
    self.backgroundCenter:SetSize(Vector(self.tooltipWidth, adjustedHeight, 0))

    self.background:SetPosition(Vector(GUIEemHint.kBackgroundExtraXOffset, 0, 0))
    
    self.flash:SetSize(Vector(self.tooltipWidth, self.tooltipHeight + totalTextHeight + GUIEemHint.kBackgroundTopHeight + GUIEemHint.kBackgroundBottomHeight, 0))

end

function GUIEemHint:SetIsVisible(setIsVisible)

    self.background:SetIsVisible(setIsVisible)

end

function GUIEemHint:GetBackground()

    return self.background

end

function GUIEemHint:Highlight()
    if self.flashColor.a < 0.5 then
        self.flashColor.a = 0.5
    end
end

// Start fadeout if we haven't already
function GUIEemHint:FadeOut()

    self.timeLastData = math.min(self.timeLastData, Shared.GetTime() - kTooltipDuration)
    self.backGroundColor.a = 0
    self:SetBackgroundColor(self.backGroundColor)

end

function GUIEemHint:Update(deltaTime)

    if PlayerUI_IsACommander() then
    
        self.backGroundColor.a = 0
        self:SetBackgroundColor(self.backGroundColor)
        
    else

        if self.timeLastData + kTooltipDuration < Shared.GetTime() then

            self.backGroundColor.a = math.max(0, self.backGroundColor.a - deltaTime)
            self:SetBackgroundColor(self.backGroundColor)

        end
        
        self.textureName = GUIEemHint.kMarineBackgroundTexture
        if PlayerUI_IsOnAlienTeam() then
            self.textureName = GUIEemHint.kAlienBackgroundTexture
        end
        
        self.resourceIcon:SetTexture(self.textureName)
        self.backgroundTop:SetTexture(self.textureName)
        self.backgroundCenter:SetTexture(self.textureName)
        self.backgroundBottom:SetTexture(self.textureName)
    
    end
    
    self.flashColor.a = math.max(0, self.flashColor.a - deltaTime)
    self.flash:SetColor(self.flashColor)

end