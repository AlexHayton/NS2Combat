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
	self.clientTimeStopped = 0
	self.serverTimeStopped = 0
	self.triggered = false
	
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
	
		local guiDialogue = ClientUI.GetScript(LogicDialogue.kGUIScript)
		// Initialise the GUI part
		if self.showOnScreen then
			guiDialogue:SetPortraitText(self.characterName)
			guiDialogue:SetDialogueText(self.text)
			guiDialogue:SetPortraitTexture(self.iconDisplay)
			guiDialogue:StartFadeIn(self.fadeIn)
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
				local guiDialogue = ClientUI.GetScript(LogicDialogue.kGUIScript)
				guiDialogue:StartFadeOut(self.fadeOut)
			end
		end
	end

end

function LogicDialogue:GetOutputNames()
    return {self.output1}
end

// Add the dialogue script to all players
if Client and AddClientUIScriptForTeam then
	AddClientUIScriptForTeam("all", LogicDialogue.kGUIScript)
end

Shared.LinkClassToMap("LogicDialogue", LogicDialogue.kMapName, networkVars)