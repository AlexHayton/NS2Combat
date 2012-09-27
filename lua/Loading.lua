Script.Load("lua/Utility.lua")
Script.Load("lua/GUIUtility.lua")
Script.Load("lua/Table.lua")

local modeText =
    {
        ["starting local server"] = "STARTING LOCAL SERVER",
        ["attempting connection"] = "ATTEMPTING CONNECTION",
        ["authenticating"]        = "AUTHENTICATING",
        ["connection"]            = "CONNECTING",
        ["loading"]               = "LOADING",
        ["waiting"]               = "WAITING FOR SERVER",
        ["downloading level"]     = "DOWNLOADING LEVEL"
    }

local spinnerBottom
local spinnerTop
local statusText
local dotsText

function OnUpdateRender()

    local spinnerSpeed  = 7
    local dotsSpeed     = 0.5
    local maxDots       = 4
    
    local time = Shared.GetTime()

    if spinnerBottom ~= nil then
        local angle = -(time * spinnerSpeed)
        spinnerBottom:SetRotation( Vector(0, 0, angle) )
    end
	
	/*if spinnerTop ~= nil then
        local angle = -time * spinnerSpeed
        spinnerTop:SetRotation( Vector(0, 0, angle) )
    end*/
    
    if statusText ~= nil then
        
        local mode = Client.GetModeDescription()
        local text = modeText[mode]
        if text == nil then
            text = "LOADING"
        end
        
        statusText:SetText(text)
        
        // Add animated dots to the text.
        local numDots = math.floor(time / dotsSpeed) % (maxDots + 1)
        dotsText:SetText(string.rep(".", numDots))
        
    end
    
end

function OnLoadComplete()

    local randomizer = Randomizer()
    randomizer:randomseed(Shared.GetSystemTime())

    local backgroundAspect = 1.8

    local ySize = Client.GetScreenHeight()
    local xSize = ySize * backgroundAspect
    
    local background = GUI.CreateItem()
    background:SetSize( Vector( xSize, ySize, 0 ) )
    background:SetPosition( Vector( (Client.GetScreenWidth() - xSize) / 2, (Client.GetScreenHeight() - ySize) / 2, 0 ) )

    // Choose a random background image.    
    local backgroundFileNames = { }
    Shared.GetMatchingFileNames("screens/combat*.jpg", true, backgroundFileNames)
    
    local numBackgrounds = #backgroundFileNames
    if numBackgrounds > 0 then       
        background:SetTexture( backgroundFileNames[math.floor(randomizer:random(1, numBackgrounds))] )
    end
    
    local spinnerSize   = GUIScale(150)
    local spinnerOffsetX = GUIScale(100)
	local spinnerOffsetY = GUIScale(50)

    spinnerBottom = GUI.CreateItem()
    spinnerBottom:SetTexture("ui/loading/loading_bottom.dds")
    spinnerBottom:SetSize( Vector( spinnerSize, spinnerSize, 0 ) )
    spinnerBottom:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffsetX, Client.GetScreenHeight() - spinnerSize - spinnerOffsetY, 0 ) )
    spinnerBottom:SetBlendTechnique( GUIItem.Add )
	
	/* at the new icon no top file is needed
	spinnerTop = GUI.CreateItem()
    spinnerTop:SetTexture("ui/loading/loading_top.dds")
    spinnerTop:SetSize( Vector( spinnerSize, spinnerSize, 0 ) )
    spinnerTop:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffsetX, Client.GetScreenHeight() - spinnerSize - spinnerOffsetY, 0 ) )
    //spinnerTop:SetBlendTechnique( GUIItem.Add )
    */
    
    local statusOffset = GUIScale(80)
        
    statusText = GUI.CreateItem()
    statusText:SetOptionFlag(GUIItem.ManageRender)
    statusText:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffsetX - statusOffset, Client.GetScreenHeight() - spinnerSize / 2 - spinnerOffsetY, 0 ) )
    statusText:SetTextAlignmentX(GUIItem.Align_Max)
    statusText:SetTextAlignmentY(GUIItem.Align_Center)
    statusText:SetFontName("fonts/AgencyFB_large.fnt")
    
    dotsText = GUI.CreateItem()
    dotsText:SetOptionFlag(GUIItem.ManageRender)
    dotsText:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffsetX - statusOffset, Client.GetScreenHeight() - spinnerSize / 2 - spinnerOffsetY, 0 ) )
    dotsText:SetTextAlignmentX(GUIItem.Align_Min)
    dotsText:SetTextAlignmentY(GUIItem.Align_Center)
    dotsText:SetFontName("fonts/AgencyFB_large.fnt")
    
end

Event.Hook("LoadComplete", OnLoadComplete)
Event.Hook("UpdateRender", OnUpdateRender)