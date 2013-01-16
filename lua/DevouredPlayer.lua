// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\DevouredPlayer.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")

class 'DevouredPlayer' (Marine)

DevouredPlayer.kMapName = "DevouredPlayer"

local networkVars =
{
    devouringPercentage = "integer (0 to 100)",
}

function DevouredPlayer:OnCreate()

    Marine.OnCreate(self)
    
 end


function DevouredPlayer:OnInitialized()

    Marine.OnInitialized(self)
    
    self:SetIsVisible(false)       
  
    // Remove physics
    self:DestroyController()    
    // Other players never see a DevouredPlayer.
    self:SetPropagate(Entity.Propagate_Never) 
    
    // due to a bug with MarineActionFinder, this need to be called here
    if Client then
    
        self.actionIconGUI = GetGUIManager():CreateGUIScript("GUIActionIcon")
        self.actionIconGUI:SetColor(kMarineFontColor)
        self.lastMarineActionFindTime = 0
        
    end
    
    self.devouringPercentage = 0
    
end

function DevouredPlayer:OnDestroy()

    Marine.OnDestroy(self)
    
    if self.guiDevouredPlayer then
    
        GetGUIManager():DestroyGUIScriptSingle(self.guiDevouredPlayer)
        self.guiDevouredPlayer = nil
        
    end
    
end

// let the player chat, but but nove
function DevouredPlayer:OverrideInput(input)

    AdjustInputForInversion(input)
    
    ClampInputPitch(input)
    
    // Completely override movement and commands
    input.move.x = 0
    input.move.y = 0
    input.move.z = 0
    
    // Only allow some actions like going to menu, chatting and Scoreboard (not jump, use, etc.)
    input.commands = bit.band(input.commands, Move.Exit) + bit.band(input.commands, Move.TeamChat) + bit.band(input.commands, Move.TextChat) + bit.band(input.commands, Move.Scoreboard) + bit.band(input.commands, Move.ShowMap)
    
    return input
    
end


function DevouredPlayer:GetDevourPercentage()
    return self.devouringPercentage
end

function DevouredPlayer:OnProcessMove(input)


    if Client and not Shared.GetIsRunningPrediction() then

        self:UpdateScoreboardDisplay(input)
        
        self:UpdateCrossHairTarget()
        self:UpdateChat(input)     
        
    end

    self:OnUpdatePlayer(input.time)

end

function DevouredPlayer:GetPlayFootsteps()
    return false
end

function DevouredPlayer:GetMovePhysicsMask()
    return PhysicsMask.All
end

function DevouredPlayer:GetTraceCapsule()
    return 0, 0
end

function DevouredPlayer:GetCanTakeDamageOverride()
    return true
end

function DevouredPlayer:GetCanDieOverride()
    return true
end

function DevouredPlayer:AdjustGravityForce(input, gravity)
    return 0
end

-- ERASE OR REFACTOR
// Handle player transitions to egg, new lifeforms, etc.
function DevouredPlayer:OnEntityChange(oldEntityId, newEntityId)

    if oldEntityId ~= Entity.invalidId and oldEntityId ~= nil then
    
        if oldEntityId == self.specTargetId then
            self.specTargetId = newEntityId
        end
        
        if oldEntityId == self.lastTargetId then
            self.lastTargetId = newEntityId
        end
        
    end
    
end

function DevouredPlayer:GetPlayerStatusDesc()
    return kPlayerStatus.Player
end

function DevouredPlayer:GetTechId()
    return kTechId.Marine
end

if Client then     
        
    function DevouredPlayer:OnInitLocalClient()    
        if self:GetTeamNumber() ~=  kTeamReadyRoom then
            Marine.OnInitLocalClient(self)
            if self.guiDevouredPlayer then    
                GetGUIManager():DestroyGUIScriptSingle(self.guiDevouredPlayer)        
            end
            
            self.guiDevouredPlayer = GetGUIManager():CreateGUIScriptSingle("Hud/GUIDevouredPlayer")                
            // to get chat working
            GetGUIManager():CreateGUIScriptSingle("GUIChat")
        end
    end
  
    function DevouredPlayer:UpdateClientEffects(deltaTime, isLocal)
    
        Marine.UpdateClientEffects(self, deltaTime, isLocal)
        
        self:SetIsVisible(false)
        
        local activeWeapon = self:GetActiveWeapon()
        if activeWeapon ~= nil then
            activeWeapon:SetIsVisible(false)
        end
        
        local viewModel = self:GetViewModelEntity()
        if viewModel ~= nil then
            viewModel:SetIsVisible(false)
        end
        
    end
        
end

Shared.LinkClassToMap("DevouredPlayer", DevouredPlayer.kMapName, networkVars)

if Server then
    local function OnCommandChangeClass(client)
        
        local player = client:GetControllingPlayer()
        if Shared.GetCheatsEnabled() then
            player:Replace(DevouredPlayer.kMapName, player:GetTeamNumber(), false, player:GetOrigin())
        end
        
    end

    Event.Hook("Console_devoured_player", OnCommandChangeClass)
end
