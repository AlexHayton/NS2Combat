// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Devour.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com) and
//                  Urwalek Andreas (andi@unknownworlds.com)
//
// Basic goring attack. Can also be used to smash down locked or welded doors.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")

class 'Devour' (Ability)

Devour.kMapName = "devour"

local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")

Devour.waitTime = 1
Devour.devourTime = 5
Devour.damage = 40
Devour.healingRate = 15
// when hitting marine his aim is interrupted
Devour.kAimInterruptDuration = 0.7

local kAttackRadius = 1.2
local kAttackOriginDistance = 1.8
local kAttackRange = 2
local kDevourEnergyCost = 40

local networkVars =
{
    attackButtonPressed = "boolean",
    eatingPlayerId = "entityid",
    devouringPercentage = "integer (0 to 100)"
}

local function DevourAttack(self, player, hitTarget, excludeTarget)

    local trace = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + player:GetViewCoords().zAxis * kAttackOriginDistance, CollisionRep.Damage, PhysicsMask.Melee, EntityFilterAll())
    local attackOrigin = trace.endPoint
    local didHit = false
    
    local targets = GetEntitiesWithMixinForTeamWithinRange ("Live", GetEnemyTeamNumber(player:GetTeamNumber()), attackOrigin, kAttackRadius)
    
    if hitTarget and HasMixin(hitTarget, "Live") and hitTarget:GetIsVisible() and hitTarget:GetCanTakeDamage() then
        table.insertunique(targets, hitTarget)
    end

    local tableparams = {}
    tableparams[kEffectFilterSilenceUpgrade] = GetHasSilenceUpgrade(player)
    
    for index, target in ipairs(targets) do
        
        if target:isa("Player") and not target:isa("Exo") then
            // ToDo: eat nearest target
            if not Shared.GetCheatsEnabled() and (target:GetTeamNumber() ~= self:GetTeamNumber()) then
                didHit = true      
                self.eatingPlayerId = target:GetId()
                if Server then
                    target:BlockMove()
                    self:DevourPlayer(target)
                end
                break
            end
        end
    
    end
    
    // since gore is aoe we need to manually trigger possibly hit effects
    if not didHit and trace.fraction ~= 1 then
        TriggerHitEffects(self, nil, trace.endPoint, trace.surface, tableparams)
    end
    
    return didHit, attackOrigin
    
end

local function UpdateDevour(self)

    local onos = self:GetParent()    
    if onos and not onos:GetIsAlive() then
    
        self:ClearPlayer()
        return false
   
    else
        if self.eatingPlayerId ~= 0 then
            local player = Shared.GetEntity(self.eatingPlayerId)            
            if player then
                local coords = onos:GetCoords()
                player:SetCoords(coords)                
                
                if Shared.GetTime() >= self.lastDevourTime then
                    
                    if player:GetIsAlive() then
                        local healRate = 0
                        local damage =  math.min((player:GetMaxHealth() / Devour.devourTime), Devour.damage)
                        self.lastDevourTime = Shared.GetTime() + Devour.waitTime
                        player:DeductHealth(damage, onos) 
                        self.devouringPercentage = math.ceil(player:GetMaxHealth() - player:GetHealth())
                        player.devouringPercentage = self.devouringPercentage
     
                        if onos:GetMaxHealth() > onos:GetHealth() then
                            healRate = math.max(Devour.healingRate, damage)
                        end
                        onos:AddHealth(healRate)   
                    else
                        self.devouringPercentage = 0
                        self.eatingPlayerId = 0
                        self.lastDevourTime = 0
                    end
                end
            else
                self.eatingPlayerId = 0
            end
        end 
    end   
    // Keep on updating
    return true
    
end


function Devour:OnCreate()

    Ability.OnCreate(self)
    
    self.devouringPercentage = 0
    self.eatingPlayerId = 0
    
    if Server then
        self.lastDevourTime = 0
        self:AddTimedCallback(UpdateDevour, 0.1)
    end
    
    if Client then
        if self.guiDevourOnos == nil then
            self.guiDevourOnos = GetGUIManager():CreateGUIScriptSingle("Hud/GUIDevourOnos")
        end
    end
    
end

function Devour:OnDestroy()
    self:ClearPlayer()
    if self.guiDevourOnos then
        GetGUIManager():DestroyGUIScript(self.guiDevourOnos)
        self.guiDevourOnos = nil
    end
end

function Devour:ClearPlayer()
    local onos = self:GetParent() 
    if onos and self.eatingPlayerId ~= 0 then
        local player = Shared.GetEntity(self.eatingPlayerId)
        if player and player.Replace then
            local oldHealth = player:GetHealth()
            newPlayer = player:Replace(player.previousMapName , player:GetTeamNumber(), false,  onos:GetOrigin())
            newPlayer.health = oldHealth 
            // give him his weapons back
            newPlayer:GiveUpsBack()
        end 
    end
    self.eatingPlayerId = 0
end

function Devour:GetDeathIconIndex()
    return kDeathMessageIcon.Gore
end

function Devour:GetAnimationGraphName()
    return kAnimationGraph
end

function Devour:GetEnergyCost(player)
    return kDevourEnergyCost
end

function Devour:GetHUDSlot()
    return 2
end

function Devour:OnHolster(player)

    Ability.OnHolster(self, player)    
    self:OnAttackEnd()
    
end

function Devour:GetMeleeBase()
    return 1, 1.4
end

function Devour:GetDevourPercentage()
    return self.devouringPercentage
end

function Devour:Attack(player)

    local didHit = false
    local impactPoint = nil
    local target = nil
    
    if self.eatingPlayerId  == 0 then     
        
        didHit, target, impactPoint = AttackMeleeCapsule(self, player, 0, kAttackRange)
        if didHit then
            didHit, impactPoint = DevourAttack(self, player, target)
        end        
        player:DeductAbilityEnergy(self:GetEnergyCost())
    end
    
    return didHit, impactPoint, target
    
end

function Devour:OnTag(tagName)

    PROFILE("Devour:OnTag") 
    local player = self:GetParent()    
    
    if self.attackButtonPressed and player:GetEnergy() >= self:GetEnergyCost() then    

        self:TriggerEffects("gore_attack")  
        local didHit, impactPoint, target = self:Attack(player)        
        // play sound effects
        if didHit then  
        end
   
    else
        self:OnAttackEnd()
    end
    
end

function Devour:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
        self.attackButtonPressed = true
    else
        self:OnAttackEnd()
    end 

end

function Devour:OnPrimaryAttackEnd(player)
    
    Ability.OnPrimaryAttackEnd(self, player)
    self:OnAttackEnd()
    
end

function Devour:OnAttackEnd()
    self.attackButtonPressed = false
end

function Devour:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    
    if self.attackButtonPressed then
        activityString = "taunt"        
    end
    
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function Devour:DevourPlayer(player)

    local oldHealth = player:GetHealth()
    local devouredPlayer = player:Replace(DevouredPlayer.kMapName , player:GetTeamNumber(), true, Vector(player:GetOrigin()))
    devouredPlayer:SetHealth(oldHealth)
    devouredPlayer.previousMapName = player:GetMapName()
    
    // Set all child entities and view model invisible
    function SetInvisible(childEntity) 
        childEntity:SetIsVisible(false)
    end
    
    devouredPlayer:SetIsVisible(false)
    devouredPlayer:ForEachChild(SetInvisible)
    
    if devouredPlayer:GetViewModelEntity() then
        devouredPlayer:GetViewModelEntity():SetModel("")
    end
    
    // Clear game effects on player
    devouredPlayer:ClearGameEffects()  
    devouredPlayer:SetOffsetAngles(Angles(0, 0, 0)) 

    self.eatingPlayerId = devouredPlayer:GetId() 
    
end


Shared.LinkClassToMap("Devour", Devour.kMapName, networkVars)