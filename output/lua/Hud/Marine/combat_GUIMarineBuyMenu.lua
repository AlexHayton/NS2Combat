//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIMarineBuyMenu.lua

Script.Load("lua/GUIAnimatedScript.lua")

class 'combat_GUIMarineBuyMenu' (GUIAnimatedScript)

combat_GUIMarineBuyMenu.kBuyMenuTexture = "ui/marine_buy_textures.dds"
combat_GUIMarineBuyMenu.kBuyHUDTexture = "ui/marine_buy_icons.dds"
combat_GUIMarineBuyMenu.kRepeatingBackground = "ui/menu/grid.dds"
combat_GUIMarineBuyMenu.kContentBgTexture = "ui/menu/repeating_bg.dds"
combat_GUIMarineBuyMenu.kContentBgBackTexture = "ui/menu/repeating_bg_black.dds"
combat_GUIMarineBuyMenu.kResourceIconTexture = "ui/pres_icon_big.dds"
combat_GUIMarineBuyMenu.kSmallIconTexture = "ui/combat_marine_buildmenu.dds"
combat_GUIMarineBuyMenu.kBigIconTexture = "ui/marine_buy_bigicons.dds"
combat_GUIMarineBuyMenu.kButtonTexture = "ui/marine_buymenu_button.dds"
combat_GUIMarineBuyMenu.kMenuSelectionTexture = "ui/marine_buymenu_selector.dds"
combat_GUIMarineBuyMenu.kScanLineTexture = "ui/menu/scanLine_big.dds"
combat_GUIMarineBuyMenu.kArrowTexture = "ui/menu/arrow_horiz.dds"

combat_GUIMarineBuyMenu.kFont = Fonts.kAgencyFB_Small
combat_GUIMarineBuyMenu.kFont2 = Fonts.kAgencyFB_Small

combat_GUIMarineBuyMenu.kDescriptionFontName = Fonts.kAgencyFB_Tiny
combat_GUIMarineBuyMenu.kDescriptionFontSize = GUIScale(20)

combat_GUIMarineBuyMenu.kScanLineHeight = GUIScale(256)
combat_GUIMarineBuyMenu.kScanLineAnimDuration = 5

combat_GUIMarineBuyMenu.kArrowWidth = GUIScale(32)
combat_GUIMarineBuyMenu.kArrowHeight = GUIScale(32)
combat_GUIMarineBuyMenu.kArrowTexCoords = { 1, 1, 0, 0 }

// Small Item Icons

combat_GUIMarineBuyMenu.kSmallIconSize = GUIScale( Vector(80, 80, 0) )
combat_GUIMarineBuyMenu.kSelectorSize = GUIScale( Vector(100, 100, 0) )

// x-offset
combat_GUIMarineBuyMenu.kSmallIconOffset_x = GUIScale(120)

combat_GUIMarineBuyMenu.kIconTopOffset = 40
combat_GUIMarineBuyMenu.kItemIconYOffset = {}

combat_GUIMarineBuyMenu.kEquippedIconTopOffset = 58

local smallIconHeight = 80
local smallIconWidth = 80
// max Icon per row
local smallIconRows = 4

local gSmallIconIndex = nil
local function GetSmallIconPixelCoordinates(itemTechId)

    if not kCombatMarineTechIdToMaterialOffset then
    
        // Init marine offsets
        kCombatMarineTechIdToMaterialOffset = {} 
        
        // class 
        kCombatMarineTechIdToMaterialOffset[kTechId.Jetpack] = 40
        kCombatMarineTechIdToMaterialOffset[kTechId.Exosuit] = 76
        kCombatMarineTechIdToMaterialOffset[kTechId.DualMinigunExosuit] = 35
        kCombatMarineTechIdToMaterialOffset[kTechId.ClawRailgunExosuit] = 76
        
        // weapons        
        kCombatMarineTechIdToMaterialOffset[kTechId.LayMines] = 80
        kCombatMarineTechIdToMaterialOffset[kTechId.Welder] = 34
        kCombatMarineTechIdToMaterialOffset[kTechId.Shotgun] = 48
        kCombatMarineTechIdToMaterialOffset[kTechId.GrenadeLauncher] = 72
        kCombatMarineTechIdToMaterialOffset[kTechId.Flamethrower] = 42
		kCombatMarineTechIdToMaterialOffset[kTechId.Mine] = 80
        
        // tech        
        kCombatMarineTechIdToMaterialOffset[kTechId.Armor1] = 49
        kCombatMarineTechIdToMaterialOffset[kTechId.Armor2] = 50
        kCombatMarineTechIdToMaterialOffset[kTechId.Armor3] = 51
        kCombatMarineTechIdToMaterialOffset[kTechId.Weapons1] = 55
        kCombatMarineTechIdToMaterialOffset[kTechId.Weapons2] = 56
        kCombatMarineTechIdToMaterialOffset[kTechId.Weapons3] = 57        
        kCombatMarineTechIdToMaterialOffset[kTechId.MedPack] = 37
        kCombatMarineTechIdToMaterialOffset[kTechId.Scan] = 41
        kCombatMarineTechIdToMaterialOffset[kTechId.MACEMP] = 62
		kCombatMarineTechIdToMaterialOffset[kTechId.CatPack] = 45
		// fast reload
		kCombatMarineTechIdToMaterialOffset[kTechId.AdvancedWeaponry] = 71
		
		// grenades
        kCombatMarineTechIdToMaterialOffset[kTechId.ClusterGrenade] = 92
        kCombatMarineTechIdToMaterialOffset[kTechId.GasGrenade] = 93
        kCombatMarineTechIdToMaterialOffset[kTechId.PulseGrenade] = 94        

    
    end
    
    local index = kCombatMarineTechIdToMaterialOffset[itemTechId]
    if not index then
        index = 0
    end
        
    local columns = 12    
    local textureOffset_x1 = index % columns
    local textureOffset_y1 = math.floor(index / columns)
    
    local pixelXOffset = textureOffset_x1 * smallIconWidth
    local pixelYOffset = textureOffset_y1 * smallIconHeight
        
    return pixelXOffset, pixelYOffset, pixelXOffset + smallIconWidth, pixelYOffset + smallIconHeight

end

                            
combat_GUIMarineBuyMenu.kTextColor = Color(kMarineFontColor)

combat_GUIMarineBuyMenu.kMenuWidth = GUIScale(128)
combat_GUIMarineBuyMenu.kPadding = GUIScale(8)

combat_GUIMarineBuyMenu.kEquippedWidth = GUIScale(128)

combat_GUIMarineBuyMenu.kEquippedColor = Color(0.6, 0.6, 0.6, 0.6)

combat_GUIMarineBuyMenu.kBackgroundWidth = GUIScale(600)
combat_GUIMarineBuyMenu.kBackgroundHeight = GUIScale(520)
// We want the background graphic to look centered around the circle even though there is the part coming off to the right.
combat_GUIMarineBuyMenu.kBackgroundXOffset = GUIScale(0)

combat_GUIMarineBuyMenu.kPlayersTextSize = GUIScale(24)
combat_GUIMarineBuyMenu.kResearchTextSize = GUIScale(24)

combat_GUIMarineBuyMenu.kResourceDisplayHeight = GUIScale(64)

combat_GUIMarineBuyMenu.kResourceIconWidth = GUIScale(32)
combat_GUIMarineBuyMenu.kResourceIconHeight = GUIScale(32)

combat_GUIMarineBuyMenu.kHardCapOffsetX = GUIScale(5)
combat_GUIMarineBuyMenu.kHardCapOffsetY = GUIScale(13)

combat_GUIMarineBuyMenu.kMouseOverInfoTextSize = GUIScale(20)
combat_GUIMarineBuyMenu.kMouseOverInfoOffset = Vector(GUIScale(-30), GUIScale(-20), 0)
combat_GUIMarineBuyMenu.kMouseOverInfoResIconOffset = Vector(GUIScale(-40), GUIScale(-60), 0)

combat_GUIMarineBuyMenu.kDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
combat_GUIMarineBuyMenu.kCannotBuyColor = Color(1, 0, 0, 0.5)
combat_GUIMarineBuyMenu.kEnabledColor = Color(1, 1, 1, 1)

combat_GUIMarineBuyMenu.kCloseButtonColor = Color(1, 1, 0, 1)

combat_GUIMarineBuyMenu.kButtonWidth = GUIScale(160)
combat_GUIMarineBuyMenu.kButtonHeight = GUIScale(64)

combat_GUIMarineBuyMenu.kItemNameOffsetX = GUIScale(28)
combat_GUIMarineBuyMenu.kItemNameOffsetY = GUIScale(256)

combat_GUIMarineBuyMenu.kItemDescriptionOffsetY = GUIScale(300)
combat_GUIMarineBuyMenu.kItemDescriptionSize = GUIScale( Vector(450, 180, 0) )

function combat_GUIMarineBuyMenu:SetHostStructure(hostStructure)

    self.hostStructure = hostStructure
    self:_InitializeItemButtons()
    self.selectedItem = nil
    
end


function combat_GUIMarineBuyMenu:OnClose()

    // Check if GUIMarineBuyMenu is what is causing itself to close.
	self.player.combatBuy = false
    if not self.closingMenu then
        // Play the close sound since we didn't trigger the close.
        MarineBuy_OnClose()
    end


end

function combat_GUIMarineBuyMenu:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.player = Client.GetLocalPlayer()    

    self.mouseOverStates = { }
    self.selectedUpgrades = { }
    self.equipped = { }
    
    self.selectedItemCinematic = nil
    self.selectedItem = nil
    
    self:_InitializeBackground()
    self:_InitializeContent()
    self:_InitializeItemButtons()
    self:_InitializeResourceDisplay()
    self:_InitializeCloseButton()
    self:_InitializeEquipped()    
	self:_InitializeRefundButton()

    // note: items buttons get initialized through SetHostStructure()
    MarineBuy_OnOpen()
    
end

function combat_GUIMarineBuyMenu:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)

	self.player = Client.GetLocalPlayer()
    self:_UpdateBackground(deltaTime)
    self:_UpdateEquipped(deltaTime)
    self:_UpdateItemButtons(deltaTime)
    self:_UpdateContent(deltaTime)
    self:_UpdateResourceDisplay(deltaTime)
    self:_UpdateCloseButton(deltaTime)
	self:_UpdateRefundButton(deltaTime)
    
end

function combat_GUIMarineBuyMenu:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self:_UninitializeItemButtons()
    self:_UninitializeBackground()
    self:_UninitializeContent()
    self:_UninitializeResourceDisplay()
    self:_UninitializeCloseButton()
	self:_UninitializeRefundButton()

end

local function MoveDownAnim(script, item)

    item:SetPosition( Vector(0, -combat_GUIMarineBuyMenu.kScanLineHeight, 0) )
    item:SetPosition( Vector(0, Client.GetScreenHeight() + combat_GUIMarineBuyMenu.kScanLineHeight, 0), combat_GUIMarineBuyMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function combat_GUIMarineBuyMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(Color(0.05, 0.05, 0.1, 0.7))
    self.background:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.repeatingBGTexture = GUIManager:CreateGraphicItem()
    self.repeatingBGTexture:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.repeatingBGTexture:SetTexture(combat_GUIMarineBuyMenu.kRepeatingBackground)
    self.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, Client.GetScreenWidth(), Client.GetScreenHeight())
    self.background:AddChild(self.repeatingBGTexture)
    
    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(Vector(combat_GUIMarineBuyMenu.kBackgroundWidth, combat_GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.content:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.content:SetPosition(Vector((-combat_GUIMarineBuyMenu.kBackgroundWidth / 2) + combat_GUIMarineBuyMenu.kBackgroundXOffset, -combat_GUIMarineBuyMenu.kBackgroundHeight / 2, 0))
    self.content:SetTexture(combat_GUIMarineBuyMenu.kContentBgTexture)
    self.content:SetTexturePixelCoordinates(0, 0, combat_GUIMarineBuyMenu.kBackgroundWidth, combat_GUIMarineBuyMenu.kBackgroundHeight)
    self.background:AddChild(self.content)
    
    self.scanLine = self:CreateAnimatedGraphicItem()
    self.scanLine:SetSize( Vector( Client.GetScreenWidth(), combat_GUIMarineBuyMenu.kScanLineHeight, 0) )
    self.scanLine:SetTexture(combat_GUIMarineBuyMenu.kScanLineTexture)
    self.scanLine:SetLayer(kGUILayerPlayerHUDForeground4)
    self.scanLine:SetIsScaling(false)
    
    self.scanLine:SetPosition( Vector(0, -combat_GUIMarineBuyMenu.kScanLineHeight, 0) )
    self.scanLine:SetPosition( Vector(0, Client.GetScreenHeight() + combat_GUIMarineBuyMenu.kScanLineHeight, 0), combat_GUIMarineBuyMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function combat_GUIMarineBuyMenu:_UpdateBackground(deltaTime)

    // TODO: create some fancy effect (screen of structure is projecting rays in our direction?)

end

function combat_GUIMarineBuyMenu:_UninitializeBackground()
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
    self.content = nil

end

function combat_GUIMarineBuyMenu:_InitializeEquipped()

    self.equippedBg = GetGUIManager():CreateGraphicItem()
    self.equippedBg:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.equippedBg:SetPosition(Vector( combat_GUIMarineBuyMenu.kPadding, -combat_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.equippedBg:SetSize(Vector(combat_GUIMarineBuyMenu.kEquippedWidth, combat_GUIMarineBuyMenu.kBackgroundHeight + combat_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.equippedBg:SetColor(Color(0,0,0,0))
    self.content:AddChild(self.equippedBg)
    
    self.equippedTitle = GetGUIManager():CreateTextItem()
    self.equippedTitle:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.equippedTitle:SetFontIsBold(true)
    self.equippedTitle:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.equippedTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.equippedTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.equippedTitle:SetColor(combat_GUIMarineBuyMenu.kEquippedColor)
    self.equippedTitle:SetPosition(Vector(0, combat_GUIMarineBuyMenu.kResourceDisplayHeight / 2, 0))
    self.equippedTitle:SetText(Combat_ResolveString("EQUIPPED"))
    self.equippedBg:AddChild(self.equippedTitle)
    
    
        self.equipped = { }
    
    local equippedTechIds = self.player:GetUpgrades()
    local selectorPosX = -combat_GUIMarineBuyMenu.kSelectorSize.x + combat_GUIMarineBuyMenu.kPadding
    
    for k, itemTechId in ipairs(equippedTechIds) do
    
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(combat_GUIMarineBuyMenu.kSmallIconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(Vector(-combat_GUIMarineBuyMenu.kSmallIconSize.x/ 2, combat_GUIMarineBuyMenu.kEquippedIconTopOffset + (combat_GUIMarineBuyMenu.kSmallIconSize.y) * k - combat_GUIMarineBuyMenu.kSmallIconSize.y, 0))
        graphicItem:SetTexture(combat_GUIMarineBuyMenu.kSmallIconTexture)
        graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))
        
        self.equippedBg:AddChild(graphicItem)
        table.insert(self.equipped, { Graphic = graphicItem, TechId = itemTechId } )
    
    end
    
end

local function GetHardCapText(upgrade)

	local player = Client.GetLocalPlayer()
    local teamInfo = GetTeamInfoEntity(player:GetTeamNumber())
	local playerCount = teamInfo:GetPlayerCount()
	if (kCombatUpgradeCounts[upgrade:GetId()] == nil) then
		kCombatUpgradeCounts[upgrade:GetId()] = 0
	end
	return kCombatUpgradeCounts[upgrade:GetId()] .. "/" .. math.ceil(upgrade:GetHardCapScale() * playerCount)

end

function combat_GUIMarineBuyMenu:_InitializeItemButtons()
    
    self.menu = GetGUIManager():CreateGraphicItem()
    self.menu:SetPosition(Vector( -combat_GUIMarineBuyMenu.kMenuWidth - combat_GUIMarineBuyMenu.kPadding, 0, 0))
    self.menu:SetTexture(combat_GUIMarineBuyMenu.kContentBgTexture)
    self.menu:SetSize(Vector(combat_GUIMarineBuyMenu.kMenuWidth, combat_GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.menu:SetTexturePixelCoordinates(0, 0, combat_GUIMarineBuyMenu.kMenuWidth, combat_GUIMarineBuyMenu.kBackgroundHeight)
    self.content:AddChild(self.menu)
    
    self.menuHeader = GetGUIManager():CreateGraphicItem()
    self.menuHeader:SetSize(Vector(combat_GUIMarineBuyMenu.kMenuWidth, combat_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetPosition(Vector(0, -combat_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetTexture(combat_GUIMarineBuyMenu.kContentBgBackTexture)
    self.menuHeader:SetTexturePixelCoordinates(0, 0, combat_GUIMarineBuyMenu.kMenuWidth, combat_GUIMarineBuyMenu.kResourceDisplayHeight)
    self.menu:AddChild(self.menuHeader) 
    
    self.menuHeaderTitle = GetGUIManager():CreateTextItem()
    self.menuHeaderTitle:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.menuHeaderTitle:SetFontIsBold(true)
    self.menuHeaderTitle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.menuHeaderTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.menuHeaderTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.menuHeaderTitle:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    self.menuHeaderTitle:SetText(Combat_ResolveString("BUY"))
    self.menuHeader:AddChild(self.menuHeaderTitle)    
    
    self.itemButtons = { }
    
    local allUps = GetAllUpgrades("Marine")
    // sort the ups, defined in this file
    sortedList = CombatMarineBuy_GUISortUps(allUps) 

    // get the headlines
    local  headlines = CombatMarineBuy_GetHeadlines()
    local nextHeadline = 1
    
    local selectorPosX = -combat_GUIMarineBuyMenu.kSelectorSize.x + combat_GUIMarineBuyMenu.kPadding
    local fontScaleVector = Vector(0.8, 0.8, 0)
    local itemNr = 1
    local k = 1
    xOffset  = 0
    
    for i, upgrade in ipairs(sortedList) do
    
        if upgrade ~= "nextRow" then
            local itemTechId = upgrade:GetTechId()
            // only 6 icons per column
            if itemTechId then         
                
                local graphicItem = GUIManager:CreateGraphicItem()
                graphicItem:SetSize(combat_GUIMarineBuyMenu.kSmallIconSize)
                graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
                graphicItem:SetPosition(Vector((-combat_GUIMarineBuyMenu.kSmallIconSize.x/ 2) + xOffset, combat_GUIMarineBuyMenu.kIconTopOffset + (combat_GUIMarineBuyMenu.kSmallIconSize.y) * itemNr - combat_GUIMarineBuyMenu.kSmallIconSize.y, 0))
                // set the tecture file for the icons
                graphicItem:SetTexture(combat_GUIMarineBuyMenu.kSmallIconTexture)
                 // set the pixel coordinate for the icon
                graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(itemTechId))

                local graphicItemActive = GUIManager:CreateGraphicItem()
                graphicItemActive:SetSize(combat_GUIMarineBuyMenu.kSelectorSize)          
                graphicItemActive:SetPosition(Vector(selectorPosX, -combat_GUIMarineBuyMenu.kSelectorSize.y / 2, 0))
                graphicItemActive:SetAnchor(GUIItem.Right, GUIItem.Center)
                graphicItemActive:SetTexture(combat_GUIMarineBuyMenu.kMenuSelectionTexture)
                graphicItemActive:SetIsVisible(false)
                
                graphicItem:AddChild(graphicItemActive)
                
                local costIcon = GUIManager:CreateGraphicItem()
                costIcon:SetSize(Vector(combat_GUIMarineBuyMenu.kResourceIconWidth * 0.8, combat_GUIMarineBuyMenu.kResourceIconHeight * 0.8, 0))
                costIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
                costIcon:SetPosition(Vector(5, -combat_GUIMarineBuyMenu.kResourceIconHeight, 0))
                costIcon:SetTexture(combat_GUIMarineBuyMenu.kResourceIconTexture)
                costIcon:SetColor(combat_GUIMarineBuyMenu.kTextColor)
                
                local selectedArrow = GUIManager:CreateGraphicItem()
                selectedArrow:SetSize(Vector(combat_GUIMarineBuyMenu.kArrowWidth, combat_GUIMarineBuyMenu.kArrowHeight, 0))
                selectedArrow:SetAnchor(GUIItem.Left, GUIItem.Center)
                selectedArrow:SetPosition(Vector(-combat_GUIMarineBuyMenu.kArrowWidth - combat_GUIMarineBuyMenu.kPadding, -combat_GUIMarineBuyMenu.kArrowHeight * 0.5, 0))
                selectedArrow:SetTexture(combat_GUIMarineBuyMenu.kArrowTexture)
                selectedArrow:SetColor(combat_GUIMarineBuyMenu.kTextColor)
                selectedArrow:SetTextureCoordinates(unpack(combat_GUIMarineBuyMenu.kArrowTexCoords))
                selectedArrow:SetIsVisible(false)
                
                graphicItem:AddChild(selectedArrow) 
                
                local itemCost = GUIManager:CreateTextItem()
                itemCost:SetFontName(combat_GUIMarineBuyMenu.kFont)
                itemCost:SetFontIsBold(true)
                itemCost:SetAnchor(GUIItem.Right, GUIItem.Center)
                itemCost:SetPosition(Vector(0, 0, 0))
                itemCost:SetTextAlignmentX(GUIItem.Align_Min)
                itemCost:SetTextAlignmentY(GUIItem.Align_Center)
                itemCost:SetScale(fontScaleVector)
                itemCost:SetColor(combat_GUIMarineBuyMenu.kTextColor)
                itemCost:SetText(ToString(upgrade:GetLevels()))
				
				if upgrade:GetHardCapScale() > 0 then
					local hardCapCount = GUIManager:CreateTextItem()
					hardCapCount:SetFontName(combat_GUIMarineBuyMenu.kFont)
					hardCapCount:SetFontIsBold(true)
					hardCapCount:SetAnchor(GUIItem.Left, GUIItem.Top)
					hardCapCount:SetPosition(Vector(combat_GUIMarineBuyMenu.kSmallIconSize.x - combat_GUIMarineBuyMenu.kHardCapOffsetX, combat_GUIMarineBuyMenu.kHardCapOffsetY, 0))
					hardCapCount:SetTextAlignmentX(GUIItem.Align_Max)
					hardCapCount:SetTextAlignmentY(GUIItem.Align_Center)
					hardCapCount:SetScale(fontScaleVector)
					hardCapCount:SetColor(combat_GUIMarineBuyMenu.kTextColor)
					hardCapCount:SetText(GetHardCapText(upgrade))
					graphicItem:AddChild(hardCapCount) 
				end
                
                costIcon:AddChild(itemCost)  
                
                graphicItem:AddChild(costIcon)   
                
                self.menu:AddChild(graphicItem)
                table.insert(self.itemButtons, { Button = graphicItem, Highlight = graphicItemActive, TechId = itemTechId, Cost = itemCost, ResourceIcon = costIcon, Arrow = selectedArrow, HardCapCount = hardCapCount, Upgrade = upgrade} )
                  
                itemNr = itemNr +1
            end
        else
            // if its first next row, only set the headline
            if i > 1 then
                itemNr = 1
                xOffset = xOffset + combat_GUIMarineBuyMenu.kSmallIconOffset_x
            end
            
            // set the headline
            local graphicItemHeading = GUIManager:CreateTextItem()
            graphicItemHeading:SetFontName(combat_GUIMarineBuyMenu.kFont)
            graphicItemHeading:SetFontIsBold(true)
            graphicItemHeading:SetAnchor(GUIItem.Middle, GUIItem.Top)
            graphicItemHeading:SetPosition(Vector((-combat_GUIMarineBuyMenu.kSmallIconSize.x/ 2) + xOffset, 5 + (combat_GUIMarineBuyMenu.kSmallIconSize.y) * itemNr - combat_GUIMarineBuyMenu.kSmallIconSize.y, 0))
            graphicItemHeading:SetTextAlignmentX(GUIItem.Align_Min)
            graphicItemHeading:SetTextAlignmentY(GUIItem.Align_Min)
            graphicItemHeading:SetColor(combat_GUIMarineBuyMenu.kTextColor)
            graphicItemHeading:SetText(headlines[nextHeadline] or "nothing")
            self.menu:AddChild(graphicItemHeading)
            
            nextHeadline = nextHeadline + 1
            
        end
    
    end
    
    // to prevent wrong display before the first update
    self:_UpdateItemButtons(0)

end

combat_GUIMarineBuyMenu.kEquippedMouseoverColor = Color(1,1,1,1)
combat_GUIMarineBuyMenu.kEquippedColor = Color(0.5, 0.5, 0.5, 0.5)

function combat_GUIMarineBuyMenu:_UpdateEquipped(deltaTime)

    self.hoverItem = nil
    for i, equipped in ipairs(self.equipped) do
    
        if self:_GetIsMouseOver(equipped.Graphic) then
            self.hoverItem = equipped.TechId
            equipped.Graphic:SetColor(combat_GUIMarineBuyMenu.kEquippedMouseoverColor)
        else
            equipped.Graphic:SetColor(combat_GUIMarineBuyMenu.kEquippedColor)
        end    
    
    end
    
end

local gResearchToWeaponIds = nil
local function GetItemTechId(researchTechId)

    if not gResearchToWeaponIds then
    
        gResearchToWeaponIds = {}
        gResearchToWeaponIds[kTechId.ShotgunTech] = kTechId.Shotgun
        gResearchToWeaponIds[kTechId.GrenadeLauncherTech] = kTechId.GrenadeLauncher
        gResearchToWeaponIds[kTechId.WelderTech] = kTechId.Welder
        gResearchToWeaponIds[kTechId.MinesTech] = kTechId.LayMines
        gResearchToWeaponIds[kTechId.FlamethrowerTech] = kTechId.Flamethrower
        gResearchToWeaponIds[kTechId.JetpackTech] = kTechId.Jetpack
        gResearchToWeaponIds[kTechId.ExosuitTech] = kTechId.Exosuit
    
    end
    
    return gResearchToWeaponIds[researchTechId]

end

function combat_GUIMarineBuyMenu:_UpdateItemButtons(deltaTime)

    if self and self.itemButtons then
        for i, item in ipairs(self.itemButtons) do
        
            if self:_GetIsMouseOver(item.Button) then	    
                item.Highlight:SetIsVisible(true)
                self.hoverItem = item.TechId
                self.hoverUpgrade = item.Upgrade
            else 
               item.Highlight:SetIsVisible(false)
           end
           
           local gotRequirements = self.player:GotRequirements(item.Upgrade)           
           local useColor = Color(1,1,1,1)

            // set grey if player doesn'T have the needed other Up
            if not gotRequirements then
            
				useColor = Color(1, 0, 0, 1)
               
            // set it blink when we got the upp already
            elseif  self.player:GotItemAlready(item.Upgrade) then
                
                local anim = math.cos(Shared.GetTime() * 9) * 0.4 + 0.6
                useColor = Color(1, 1, anim, 1)
                    
            // set red if can't afford
            elseif PlayerUI_GetPlayerResources() < item.Upgrade:GetLevels() then
            
                useColor = Color(0.5, 0.5, 0.5, 1) 
               
            end
            
            item.Button:SetColor(useColor)
            item.Highlight:SetColor(useColor)
            item.Cost:SetColor(useColor)
            item.ResourceIcon:SetColor(useColor)
            item.Arrow:SetIsVisible(self.selectedItem == item.TechId)
			if (item.HardCapCount) then
				item.HardCapCount:SetText(GetHardCapText(item.Upgrade))
			end
            
        end
    end

end

function combat_GUIMarineBuyMenu:_UninitializeItemButtons()

/*
    for i, item in ipairs(self.itemButtons) do
        GUI.DestroyItem(item.Button)
    end
    self.itemButtons = nil
    */

end

function combat_GUIMarineBuyMenu:_InitializeContent()

    self.itemName = GUIManager:CreateTextItem()
    self.itemName:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.itemName:SetFontIsBold(true)
    self.itemName:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.itemName:SetPosition(Vector((-combat_GUIMarineBuyMenu.kSmallIconSize.x/ 2) - 60, combat_GUIMarineBuyMenu.kIconTopOffset + (combat_GUIMarineBuyMenu.kSmallIconSize.y) * (smallIconRows + 1.5) - combat_GUIMarineBuyMenu.kSmallIconSize.y, 0))
    self.itemName:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemName:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemName:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    self.itemName:SetText("no selection")
    
    self.content:AddChild(self.itemName)
    
    self.itemDescription = GetGUIManager():CreateTextItem()
    self.itemDescription:SetFontName(combat_GUIMarineBuyMenu.kDescriptionFontName)
    //self.itemDescription:SetFontIsBold(true)
    self.itemDescription:SetFontSize(combat_GUIMarineBuyMenu.kDescriptionFontSize)
    self.itemDescription:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.itemDescription:SetPosition(Vector((-combat_GUIMarineBuyMenu.kSmallIconSize.x/ 2) - 200, combat_GUIMarineBuyMenu.kIconTopOffset + (combat_GUIMarineBuyMenu.kSmallIconSize.y) * (smallIconRows + 1.8) - combat_GUIMarineBuyMenu.kSmallIconSize.y, 0))
    self.itemDescription:SetTextAlignmentX(GUIItem.Align_Min)
    self.itemDescription:SetTextAlignmentY(GUIItem.Align_Min)
    self.itemDescription:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    self.itemDescription:SetTextClipped(true, combat_GUIMarineBuyMenu.kItemDescriptionSize.x - 2* combat_GUIMarineBuyMenu.kPadding, combat_GUIMarineBuyMenu.kItemDescriptionSize.y - combat_GUIMarineBuyMenu.kPadding)
    
    self.content:AddChild(self.itemDescription)
    
end

function combat_GUIMarineBuyMenu:_UpdateContent(deltaTime)

    local techId = self.hoverItem
    if not self.hoverItem then
        techId = self.selectedItem
    end
    
    if techId then
    
        local researched = self.player:GotRequirements(self.hoverUpgrade)                
        local itemCost = ConditionalValue(self.hoverUpgrade, self.hoverUpgrade:GetLevels(), 0)
        local upgradesCost = 0
        local canAfford = PlayerUI_GetPlayerResources() >= itemCost + upgradesCost

        // the discription text under the buttons
        self.itemName:SetText(GetDisplayNameForTechId(techId))
        self.itemDescription:SetText(CombatMarineBuy_GetWeaponDescription(techId))
        self.itemDescription:SetTextClipped(true, combat_GUIMarineBuyMenu.kItemDescriptionSize.x - 2* combat_GUIMarineBuyMenu.kPadding, combat_GUIMarineBuyMenu.kItemDescriptionSize.y - combat_GUIMarineBuyMenu.kPadding)

    end
    
    local contentVisible = techId ~= nil and techId ~= kTechId.None

    self.itemName:SetIsVisible(contentVisible)
    self.itemDescription:SetIsVisible(contentVisible)
    
end

function combat_GUIMarineBuyMenu:_UninitializeContent()

    GUI.DestroyItem(self.itemName)

end

function combat_GUIMarineBuyMenu:_InitializeResourceDisplay()
    
    self.resourceDisplayBackground = GUIManager:CreateGraphicItem()
    self.resourceDisplayBackground:SetSize(Vector(combat_GUIMarineBuyMenu.kBackgroundWidth, combat_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetPosition(Vector(0, -combat_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.resourceDisplayBackground:SetTexture(combat_GUIMarineBuyMenu.kContentBgBackTexture)
    self.resourceDisplayBackground:SetTexturePixelCoordinates(0, 0, combat_GUIMarineBuyMenu.kBackgroundWidth, combat_GUIMarineBuyMenu.kResourceDisplayHeight)
    self.content:AddChild(self.resourceDisplayBackground)
    
    self.resourceDisplayIcon = GUIManager:CreateGraphicItem()
    self.resourceDisplayIcon:SetSize(Vector(combat_GUIMarineBuyMenu.kResourceIconWidth, combat_GUIMarineBuyMenu.kResourceIconHeight, 0))
    self.resourceDisplayIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplayIcon:SetPosition(Vector(-combat_GUIMarineBuyMenu.kResourceIconWidth * 2.2, -combat_GUIMarineBuyMenu.kResourceIconHeight / 2, 0))
    self.resourceDisplayIcon:SetTexture(combat_GUIMarineBuyMenu.kResourceIconTexture)
    self.resourceDisplayIcon:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    self.resourceDisplayBackground:AddChild(self.resourceDisplayIcon)

    self.resourceDisplay = GUIManager:CreateTextItem()
    self.resourceDisplay:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.resourceDisplay:SetFontIsBold(true)
    self.resourceDisplay:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.resourceDisplay:SetPosition(Vector(-combat_GUIMarineBuyMenu.kResourceIconWidth , 0, 0))
    self.resourceDisplay:SetTextAlignmentX(GUIItem.Align_Min)
    self.resourceDisplay:SetTextAlignmentY(GUIItem.Align_Center)
    
    self.resourceDisplay:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    //self.resourceDisplay:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    
    self.resourceDisplay:SetText("")
    self.resourceDisplayBackground:AddChild(self.resourceDisplay)
    
    self.currentDescription = GUIManager:CreateTextItem()
    self.currentDescription:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.currentDescription:SetFontIsBold(true)
    self.currentDescription:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.currentDescription:SetPosition(Vector(-combat_GUIMarineBuyMenu.kResourceIconWidth * 3 , combat_GUIMarineBuyMenu.kResourceIconHeight, 0))
    self.currentDescription:SetTextAlignmentX(GUIItem.Align_Max)
    self.currentDescription:SetTextAlignmentY(GUIItem.Align_Center)
    self.currentDescription:SetColor(combat_GUIMarineBuyMenu.kTextColor)
    self.currentDescription:SetText(Combat_ResolveString("CURRENT"))
    
    self.resourceDisplayBackground:AddChild(self.currentDescription) 

end

function combat_GUIMarineBuyMenu:_UpdateResourceDisplay(deltaTime)

    self.resourceDisplay:SetText(ToString(PlayerUI_GetPlayerResources()))
    
end

function combat_GUIMarineBuyMenu:_UninitializeResourceDisplay()

    GUI.DestroyItem(self.resourceDisplay)
    self.resourceDisplay = nil
    
    GUI.DestroyItem(self.resourceDisplayIcon)
    self.resourceDisplayIcon = nil
    
    GUI.DestroyItem(self.resourceDisplayBackground)
    self.resourceDisplayBackground = nil
    
end

function combat_GUIMarineBuyMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.closeButton:SetSize(Vector(combat_GUIMarineBuyMenu.kButtonWidth, combat_GUIMarineBuyMenu.kButtonHeight, 0))
    self.closeButton:SetPosition(Vector(-combat_GUIMarineBuyMenu.kButtonWidth, combat_GUIMarineBuyMenu.kPadding, 0))
    self.closeButton:SetTexture(combat_GUIMarineBuyMenu.kButtonTexture)
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.closeButton)
    
    self.closeButtonText = GUIManager:CreateTextItem()
    self.closeButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.closeButtonText:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.closeButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.closeButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.closeButtonText:SetText("EXIT")
    self.closeButtonText:SetFontIsBold(true)
    self.closeButtonText:SetColor(combat_GUIMarineBuyMenu.kCloseButtonColor)
    self.closeButton:AddChild(self.closeButtonText)
    
end

function combat_GUIMarineBuyMenu:_UpdateCloseButton(deltaTime)

    if self:_GetIsMouseOver(self.closeButton) then
        self.closeButton:SetColor(Color(1, 1, 1, 1))
    else
        self.closeButton:SetColor(Color(0.5, 0.5, 0.5, 1))
    end

end

function combat_GUIMarineBuyMenu:_UninitializeCloseButton()
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function combat_GUIMarineBuyMenu:_InitializeRefundButton()
    self.refundButton = GUIManager:CreateGraphicItem()
    self.refundButton:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.refundButton:SetSize(Vector(combat_GUIMarineBuyMenu.kButtonWidth, combat_GUIMarineBuyMenu.kButtonHeight, 0))
    self.refundButton:SetPosition(Vector(-combat_GUIMarineBuyMenu.kButtonWidth*2 - combat_GUIMarineBuyMenu.kPadding, combat_GUIMarineBuyMenu.kPadding, 0))
    self.refundButton:SetTexture(combat_GUIMarineBuyMenu.kButtonTexture)
    self.refundButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.refundButton)
    
    self.refundButtonText = GUIManager:CreateTextItem()
    self.refundButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.refundButtonText:SetFontName(combat_GUIMarineBuyMenu.kFont)
    self.refundButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.refundButtonText:SetTextAlignmentY(GUIItem.Align_Center)
	self.refundButtonText:SetText(Combat_ResolveString("COMBAT_REFUND_MARINE"))
    self.refundButtonText:SetFontIsBold(true)
    self.refundButtonText:SetColor(combat_GUIMarineBuyMenu.kCloseButtonColor)
    self.refundButton:AddChild(self.refundButtonText)
end

function combat_GUIMarineBuyMenu:_UpdateRefundButton(deltaTime)

    if self:_GetIsMouseOver(self.refundButton) then
        self.refundButton:SetColor(Color(1, 1, 1, 1))
        // the discription text under the buttons
		self.itemName:SetText(Combat_ResolveString("COMBAT_REFUND_TITLE_MARINE"))
        self.itemDescription:SetText(Combat_ResolveString("COMBAT_REFUND_DESCRIPTION_MARINE"))
        self.itemDescription:SetTextClipped(true, combat_GUIMarineBuyMenu.kItemDescriptionSize.x - 2* combat_GUIMarineBuyMenu.kPadding, combat_GUIMarineBuyMenu.kItemDescriptionSize.y - combat_GUIMarineBuyMenu.kPadding)
		self.itemName:SetIsVisible(true)
		self.itemDescription:SetIsVisible(true)
    else
        self.refundButton:SetColor(Color(0.5, 0.5, 0.5, 1))
    end

end

function combat_GUIMarineBuyMenu:_ClickRefundButton()

    Shared.ConsoleCommand("co_refundall")
	
end

function combat_GUIMarineBuyMenu:_UninitializeRefundButton()
    GUI.DestroyItem(self.refundButton)
    self.refundButton = nil
end

/**
 * Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
 */
function combat_GUIMarineBuyMenu:_GetIsMouseOver(overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end

function combat_GUIMarineBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then

        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
                    
            inputHandled, closeMenu = self:_HandleItemClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                // Check if the close button was pressed.
                if self:_GetIsMouseOver(self.closeButton) then
                    closeMenu = true
                    inputHandled = true
                    self:OnClose()
                end
				
				// Check if the close button was pressed.
				if not closeMenu then
					if self:_GetIsMouseOver(self.refundButton) then
					self:_ClickRefundButton()
					closeMenu = true
                    inputHandled = true
                    self:OnClose()
					end
				end
            end
        end
        
    end
    
    if InputKey.Escape == key and not down then
        closeMenu = true
        inputHandled = true
        self:OnClose()
    end

    if closeMenu then
        self.closingMenu = true
        self:OnClose()
    end
    
    return inputHandled
    
end

function combat_GUIMarineBuyMenu:_SetSelectedItem(techId)

    self.selectedItem = techId
    MarineBuy_OnItemSelect(techId)

end

function combat_GUIMarineBuyMenu:_HandleItemClicked(mouseX, mouseY)

    for i, item in ipairs(self.itemButtons) do
    
        if self:_GetIsMouseOver(item.Button) then
        
            local researched = self.player:GotRequirements(item.Upgrade)
            local itemCost = item.Upgrade:GetLevels()
            local upgradesCost = self:_GetSelectedUpgradesCost()
            local canAfford = PlayerUI_GetPlayerResources() >= itemCost + upgradesCost 
            local hasItem = self.player:GotItemAlready(item.Upgrade)
            
            if researched and canAfford and not hasItem then
            
                self.player:Combat_PurchaseItemAndUpgrades(item.Upgrade:GetTextCode())
                self:OnClose()
                
                return true, true
                
            end
            
        end 
        
    end
    
    return false, false
    
end

function combat_GUIMarineBuyMenu:_GetSelectedUpgradesCost()

    local upgradeCosts = 0
    
    for k, upgrade in ipairs(self.selectedUpgrades) do
    
        //upgradeCosts = upgradeCosts + MarineBuy_GetCosts(upgrade)
    
    end
    
    return upgradeCosts
    
end