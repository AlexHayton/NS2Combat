//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Hydra.lua

  CombatHydra = CombatHydra or {}
  ClassHooker:Mixin("CombatHydra")

    
function CombatHydra:OnLoad()
   
    self:PostHookClassFunction("Hydra", "OnUpdate", "OnUpdate_Hook")
    
end


// Implement lvl and XP
function CombatHydra:OnUpdate_Hook(self, deltaTime)
    // check if the owner is still a gorge
    if self.hydraParentId then
        local owner = Shared.GetEntity(self.hydraParentId)
        if owner then
            if not owner:isa("Gorge") then
                // start a timer, if the player is still no gorge when the timer is 0, kill the hydras
                if not self.killTime then
                    self.killTime = Shared.GetTime() + kHydraKillTime
                end
                
                if Shared.GetTime() >= self.killTime then
                    self:Kill()
                end
                
            else
                self.killTime = nil
            end 
        else
            self:Kill()
        end   
    end
end


if (not HotReload) then
	CombatHydra:OnLoad()
end