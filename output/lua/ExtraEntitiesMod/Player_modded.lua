//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/Class.lua")
Script.Load("lua/Player.lua")

// original network variables are not deleted
local networkVars =
{
    gravityTrigger = "entityid",
    // add this to all players so they see the teleport effect
    timeOfLastPhase = "private time",
}


// Modifications for the npc
// every player needs order mixin so we can give them orders etc
Script.Load("lua/OrdersMixin.lua")
AddMixinNetworkVars(OrdersMixin, networkVars)

// override for the gravity trigger
function Player:AdjustGravityForceOverride(gravity)
    if self.gravityTrigger and self.gravityTrigger ~= 0 then
        local ent = Shared.GetEntity(self.gravityTrigger)
        if ent then
            gravity = ent:GetGravityOverride(gravity) 
        end
    end
    return gravity
end

local overridePlayerOnInitialized = Player.OnInitialized
function Player:OnInitialized()
    overridePlayerOnInitialized(self)
    //InitMixin(self, NpcMixin)
    if not HasMixin(self, "Orders") then
        InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    end
end

local originalScriptActorProcessMove = ScriptActor.OnProcessMove
function ScriptActor:OnProcessMove(input)
	if self.isaNpc then
		// Do nothing
		// fsfod: Entity_OnProcessMove doesn't actrully do anything atm so its call could be skipped
	else
		originalScriptActorProcessMove(self, input)
	end
end

if Server then
    // don't call normal OnKill function for bots
    local overridePlayerOnKill = Player.OnKill
    function Player:OnKill(killer, doer, point, direction)
        if not self.isaNpc then
            overridePlayerOnKill(self, killer, doer, point, direction)
        else
			if (self.viewModelId ~= Entity.invalidId) then
				DestroyEntity(self:GetViewModelEntity())
				self.viewModelId = Entity.invalidId
			end
			// call radgdoll mixin so it will be a ragdoll
			RagdollMixin.OnKill(self, attacker, doer, point, direction)
        end
    end
    
    
    // cheap trick to get rid of an error that appears when npcs are shooting before client is there
    Player.hitRegEnabled = false

    local originalPlayerGetClient
    originalPlayerGetClient = Class_ReplaceMethod( "Player", "GetClient", 
        function(self)     
            return self.client or self
        end
    )

elseif Client then

    // to fix the bug when theres no minimap frame
    function Player:ShowMap(showMap, showBig, forceReset)
        
        if ClientUI.GetScript("GUIMinimapFrame") then        
            self.minimapVisible = showMap and showBig
            ClientUI.GetScript("GUIMinimapFrame"):ShowMap(showMap)
            ClientUI.GetScript("GUIMinimapFrame"):SetBackgroundMode((showBig and GUIMinimapFrame.kModeBig) or GUIMinimapFrame.kModeMini, forceReset)
        end
        
    end

end


Class_Reload("Player", networkVars)