//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// GUIFuncTrain.lua

class 'GUIFuncTrain' (GUIAnimatedScript)

GUIFuncTrain.kBackgroundTexture = "ui/train_buttons.png"

GUIFuncTrain.kBackgroundWidth = 256
GUIFuncTrain.kBackgroundHeight = 256
GUIFuncTrain.kBackgroundOffsetX = 0
GUIFuncTrain.kBackgroundOffsetY = 0

GUIFuncTrain.kTimeOffset = Vector(0, -10, 0)
GUIFuncTrain.kTimeFontName = "fonts/AgencyFB_large.fnt"
GUIFuncTrain.kTimeFontSize = 25
GUIFuncTrain.kTimeBold = true

GUIFuncTrain.kBgCoords = {14, 0, 140, 256}

GUIFuncTrain.kBackgroundColor = Color(1, 1, 1, 0.7)
GUIFuncTrain.kMarineTextColor = kMarineFontColor
GUIFuncTrain.kAlienTextColor = kAlienFontColor

function GUIFuncTrain:Initialize()    

	GUIAnimatedScript.Initialize(self)
    
	// Used for Global Offset
	self.background = self:CreateAnimatedGraphicItem()
    self.background:SetIsScaling(false)
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetPosition( Vector(0, 0, 0) ) 
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )
	
    // Timer display background
    self.timerBackground = self:CreateAnimatedGraphicItem()
    self.timerBackground:SetSize( Vector(GUIFuncTrain.kBackgroundWidth, GUIFuncTrain.kBackgroundHeight, 0) )
    self.timerBackground:SetPosition(Vector(GUIFuncTrain.kBackgroundOffsetX - (GUIFuncTrain.kBackgroundWidth / 2), GUIFuncTrain.kBackgroundOffsetY, 0))
    self.timerBackground:SetAnchor(GUIItem.Middle, GUIItem.Top) 
    self.timerBackground:SetLayer(kGUILayerPlayerHUD)
    self.timerBackground:SetTexture(GUIFuncTrain.kBackgroundTexture)
    self.timerBackground:SetTexturePixelCoordinates(unpack(GUIFuncTrain.kBgCoords))
	self.timerBackground:SetColor( GUIFuncTrain.kBackgroundColor )
	self.timerBackground:SetIsVisible(true)
	
	// Time remaining
    self.timeRemainingText = self:CreateAnimatedTextItem()
    self.timeRemainingText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timeRemainingText:SetPosition(GUIFuncTrain.kTimeOffset)
	self.timeRemainingText:SetLayer(kGUILayerPlayerHUDForeground1)
	self.timeRemainingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingText:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingText:SetText("")
	self.timeRemainingText:SetColor(Color(1,1,1,1))
	self.timeRemainingText:SetFontSize(GUIFuncTrain.kTimeFontSize)
    self.timeRemainingText:SetFontName(GUIFuncTrain.kTimeFontName)
	self.timeRemainingText:SetFontIsBold(GUIFuncTrain.kTimeBold)
	self.timeRemainingText:SetIsVisible(true)
 
	self.background:AddChild(self.timerBackground)
	self.timerBackground:AddChild(self.timeRemainingText)
    self:Update(0)

end

local function GetTeamType()

	local player = Client.GetLocalPlayer()
	
	if not player:isa("ReadyRoomPlayer") then	
		local teamnumber = player:GetTeamNumber()
		if teamnumber == kAlienTeamType then
			return "Aliens"
		elseif teamnumber == kMarineTeamType then
			return "Marines"
		elseif teamnumber == kNeutralTeamType then 
			return "Spectator"
		else
			return "Unknown"
		end
	else
		return "Ready Room"
	end
	
end

function GUIFuncTrain:Update(deltaTime)

    local player = Client.GetLocalPlayer()
	

end


function GUIFuncTrain:Uninitialize()

	GUI.DestroyItem(self.timeRemainingText)
	GUI.DestroyItem(self.timerBackground)
    GUI.DestroyItem(self.background)

end