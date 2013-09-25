//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcSkulkMixin = CreateMixin( NpcSkulkMixin )
NpcSkulkMixin.type = "NpcSkulk"

NpcSkulkMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcSkulkMixin.expectedCallbacks =
{
}


NpcSkulkMixin.networkVars =  
{
}


function NpcSkulkMixin:__initmixin()   
    // can use leap    
    self.twoHives = true 
    self.threeHives = true 
    
    // some skulks will use xeno
    if math.random(1, 100) <= 10 then                    
        self.canUseXenocid  = true
    end
    
end


function NpcSkulkMixin:CheckImportantEvents()
end


function NpcSkulkMixin:EngagementPointOverride(target)
    // attack exos at origin
    if target:isa("Exo") then
        return target:GetOrigin()
    end
end


// use leap step sometimes
function NpcSkulkMixin:AiSpecialLogic(deltaTime)

    local order = self:GetCurrentOrder()
    if order then
        if self.points and self.index and #self.points >= self.index then
            if ((self:GetOrigin() - self.points[self.index]):GetLengthXZ() > 2 ) then
                if not self.usedLeap then
                    // shadow step will bring you faster forward
                    // only random
                    if math.random(1, 100) <= 5 then                    
                        self.usedLeap = true
                    end
                end
            else     
                self.usedLeap = false
                if  self.canUseXenocid then                    
                    self.useXenocid = true
                end
            end
        end
        
        if self.usedLeap and not self.inTargetRange then
            self:PressButton(Move.SecondaryAttack)
            // unlimited leap :-)
            self.secondaryAttackLastFrame = false
        end
        
    end
end


function NpcSkulkMixin:AttackOverride(activeWeapon) 

    if activeWeapon:isa("XenocideLeap") then
        self:UpdateXenocide(activeWeapon)
    end
    
    local attack = true
    // wait if we got 3rd weapon rdy
    if (self.useXenocid) then
        if not activeWeapon:isa("XenocideLeap") then
            attack = false
            self:PressButton(Move.Weapon3)
            self.useXenocid = false
        end
    end
    
    if attack then
        self:PressButton(Move.PrimaryAttack)        
    end

end


// normal xeno update doesnt work so do it here
function NpcSkulkMixin:UpdateXenocide(activeWeapon)

    if not activeWeapon.xenocideTimeLeft then
        activeWeapon.xenocideTimeLeft  = 0
    end
    activeWeapon.xenocideTimeLeft = math.max(activeWeapon.xenocideTimeLeft - self.move.time, 0)    
    if activeWeapon.xenocideTimeLeft == 0 and self:GetIsAlive() then    
        self:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})        
        local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kXenocideRange)
        RadiusDamage(hitEntities, self:GetOrigin(), kXenocideRange, kXenocideDamage, activeWeapon)        
        self.spawnReductionTime = 12        
        self:SetBypassRagdoll(true)        
        self:Kill()
        
    end

end



function NpcSkulkMixin:GetHasSecondary(player)
    return true
end    
