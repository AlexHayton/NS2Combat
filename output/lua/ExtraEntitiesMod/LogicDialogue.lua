//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// LogicDialogue.lua
// Base entity for LogicDialogue things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicDialogue' (Entity)

LogicDialogue.kMapName = "logic_dialogue"
LogicDialogue.kGUIScript = "ExtraEntitiesMod/GUIDialogue"

LogicDialogue.kMaxNameLength = kMaxNameLength
LogicDialogue.kMaxTextLength = 1000
LogicDialogue.kMaxIconDisplayLength = 255

local networkVars =
{
	timeStarted = "time",
	timeToStop = "time",
	showOnScreen = "boolean",
	fadeIn = "boolean",
	fadeOut = "boolean",
	characterName = "string (" .. LogicDialogue.kMaxNameLength .. ")",
	text = "string (" .. LogicDialogue.kMaxTextLength .. ")",
	iconDisplay = "string (" .. LogicDialogue.kMaxIconDisplayLength .. ")",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicDialogue:OnCreate()

    Entity.OnCreate(self)
	self:Reset()
	
	// Late-precache the sound
	if Client then
		if self.sound ~= nil and self.sound ~= "" then
			self.soundAsset = PrecacheAsset(self.sound)
		end
	end

end


function LogicDialogue:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
    end
	self:SetUpdates(true)
    
end

function LogicDialogue:Reset()

	self.timeStarted = 0
	self.clientTimeStarted = 0
	self.timeToStop = 0
	self.displayTime = self.displayTime or 0
	self.clientTimeStopped = 0
	self.serverTimeStopped = 0
	self.triggered = false
	
	// Stop the GUI hanging around if it is active between round resets.
	if g_GUIDialogue then
		GetGUIManager():DestroyGUIScript(g_GUIDialogue)
		g_GUIDialogue = nil
	end
	
end


function LogicDialogue:OnLogicTrigger(player)

    if Server and not self.triggered then
		self.timeStarted = Shared.GetTime()
		self.timeToStop = Shared.GetTime() + self.displayTime
		if not self.repeats then
			self.triggered = true
		end
	end
    
end

function LogicDialogue:OnUpdate(deltaTime)
	
	// Client: if timeStarted changes, treat this as a trigger to start the dialogue.
	if Client and self.timeStarted ~= self.clientTimeStarted then
		self.clientTimeStarted = self.timeStarted 
	
		if not g_GUIDialogue then
			g_GUIDialogue = GetGUIManager():CreateGUIScript(LogicDialogue.kGUIScript)
		end
		
		// Initialise the GUI part
		if self.showOnScreen then
			g_GUIDialogue:SetPortraitText(self.characterName)
			g_GUIDialogue:SetDialogueText(self.text)
			g_GUIDialogue:SetPortraitTexture(self.portraitTexture)
			g_GUIDialogue:StartFadeIn(self.fadeIn)
		end
		
		// Play the sound we precached earlier
		if self.soundAsset then
			StartSoundEffect(self.soundAsset)
		end
	end
	
	// Server: Trigger logic after the dialogue has played
	if Server and self.timeToStop ~= self.serverTimeStopped then
		self.serverTimeStopped = self.timeToStop
		self:OnTriggerAction()
	end
	
	// Client: Hide the dialogue GUI after a certain time
	if Client and self.timeToStop ~= self.clientTimeStopped then
		if self.timeToStop <= Shared.GetTime() then
			self.clientTimeStopped = self.timeToStop
			
			if self.showOnScreen then
				g_GUIDialogue:StartFadeout(self.fadeOut)
			end
		end
	end

end

function LogicDialogue:GetOutputNames()
    return {self.output1}
end

Shared.LinkClassToMap("LogicDialogue", LogicDialogue.kMapName, networkVars)