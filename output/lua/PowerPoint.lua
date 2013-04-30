// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\PowerPoint.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Every room has a power point in it, which starts built. It is placed on the wall, around
// head height. When a power point is taking damage, lights nearby flicker. When a power point 
// is at 35% health or lower, the lights cycle dramatically. When a power point is destroyed, 
// the lights go completely black and all marine structures power down 5 long seconds later, the 
// aux. power comes on, fading the lights back up to ~%35. When down, the power point has 
// ambient electricity flowing around it intermittently, hinting at function. Marines can build 
// the power point by +using it, MACs can build it as well. When it comes back on, all 
// structures power back up and start functioning again and lights fade back up.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/PowerSourceMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

local kDefaultUpdateRange = 100

if Client then

    // The default update range; if the local player is inside this range from the powerpoint, the
    // lights will update. As the lights controlled by a powerpoint can be located quite far from the powerpoint,
    // and the area lit by the light even further, this needs to be set quite high.
    // The powerpoint cycling is also very efficient, so there is no need to keep it low from a performance POV.
    local kDefaultUpdateRangeSq = kDefaultUpdateRange * kDefaultUpdateRange
    
    function UpdatePowerPointLights()
    
        PROFILE("PowerPoint:UpdatePowerPointLights")
        
        // Now update the lights every frame
        local player = Client.GetLocalPlayer()
        if player then
        
            local playerPos = player:GetOrigin()
            local powerPoints = Shared.GetEntitiesWithClassname("PowerPoint")
            
            for index, powerPoint in ientitylist(powerPoints) do
            
                // PowerPoints are always loaded but in order to avoid running the light modification stuff
                // for all of them at all times, we restrict it to powerpoints inside the updateRange. The
                // updateRange should be long enough that players can't see the lights being updated by the
                // powerpoint when outside this range, and short enough not to waste too much cpu.
                local inRange = (powerPoint:GetOrigin() - playerPos):GetLengthSquared() < kDefaultUpdateRangeSq
                
                // Ignore range check if the player is a commander since they are high above
                // the lights in a lot of cases and see through ceilings and some walls.
                if inRange or player:isa("Commander") then
                    powerPoint:UpdatePoweredLights()
                end
                
            end
            
        end
        
    end
    
end

class 'PowerPoint' (ScriptActor)

if Client then
    Script.Load("lua/PowerPoint_Client.lua")
end

PowerPoint.kMapName = "power_point"

local kUnsocketedSocketModelName = PrecacheAsset("models/system/editor/power_node_socket.model")
local kUnsocketedAnimationGraph = nil

local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")

local kDamagedEffect = PrecacheAsset("cinematics/common/powerpoint_damaged.cinematic")
local kOfflineEffect = PrecacheAsset("cinematics/common/powerpoint_offline.cinematic")

local kTakeDamageSound = PrecacheAsset("sound/NS2.fev/marine/power_node/take_damage")
local kDamagedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/damaged")
local kDestroyedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed")
local kDestroyedPowerDownSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed_powerdown")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

Shared.PrecacheSurfaceShader("shaders/PowerNode_emissive.surface_shader")

local kDamagedPercentage = 0.4

// Re-build only possible when X seconds have passed after destruction (when aux power kicks in)
local kDestructionBuildDelay = 15

// The amount of time that must pass since the last time a PP was attacked until
// the team will be notified. This makes sure the team isn't spammed.
local kUnderAttackTeamMessageLimit = 5

// max amount of "attack" the powerpoint has suffered (?)
local kMaxAttackTime = 10

PowerPoint.kPowerState = enum( { "unsocketed", "socketed", "destroyed" } )

local networkVars =
{
    lightMode = "enum kLightMode",
    powerState = "enum PowerPoint.kPowerState",
    timeOfLightModeChange = "time",
    timeOfDestruction  = "time",
    attackTime = "float (0 to " .. (kMaxAttackTime + 0.1) .. " by 0.01"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(PowerSourceMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function PowerPoint:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PowerSourceMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.lightMode = kLightMode.Normal
    self.powerState = PowerPoint.kPowerState.unsocketed
end

local function SetupWithInitialSettings(self)

    if self.startSocketed then

        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetConstructionComplete()
        self:SetLightMode(kLightMode.Normal)
        self:SetPoweringState(true)
    
    else

        self:SetModel(kUnsocketedSocketModelName, kUnsocketedAnimationGraph)
        
        self.lightMode = kLightMode.Normal
        self.powerState = PowerPoint.kPowerState.unsocketed
        self.timeOfDestruction = 0
        
        if Server then
        
            self.startsBuilt = false
            self.attackTime = 0.0
            
        elseif Client then 
        
            self.unchangingLights = { }
            self.lightFlickers = { }
            
        end
    
    end
    
end

function PowerPoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    SetupWithInitialSettings(self)
    
    if Server then
    
        // PowerPoints always belong to the Marine team.
        self:SetTeamNumber(kTeam1Index)
        
        self:SetRelevancyDistance(kDefaultUpdateRange + 20)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end
    
end

function GetPowerPointRecentlyDestroyed(self)
    return (self.timeOfDestruction + kDestructionBuildDelay) > Shared.GetTime()
end

function PowerPoint:GetReceivesStructuralDamage()
    return true
end

function PowerPoint:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function PowerPoint:GetCanPower(consumer)
    return self:GetLocationId() == consumer:GetLocationId()
end

function PowerPoint:GetCanTakeDamageOverride()
    return self.powerState ~= PowerPoint.kPowerState.unsocketed and self:GetIsBuilt() and self:GetHealth() > 0
end

/**
 * Only allow nano shield on the PowerPoint when it is socketed.
 */
function PowerPoint:GetCanBeNanoShieldedOverride(resultTable)
    resultTable.shieldedAllowed = resultTable.shieldedAllowed and self:GetPowerState() == PowerPoint.kPowerState.socketed
end

function PowerPoint:GetWeldPercentageOverride()

    if self:GetPowerState() == PowerPoint.kPowerState.unsocketed then
        return 0
    end
    
    return self:GetHealthScalar()
    
end

local kPowerPointHealthbarOffset = Vector(0, 0.8, 0)
function PowerPoint:GetHealthbarOffset()
    return kPowerPointHealthbarOffset
end 

function PowerPoint:GetCanBeHealedOverride()
    return self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed
end    

function PowerPoint:GetTechButtons()

    local techButtons = { }
    
    if self:GetPowerState() == PowerPoint.kPowerState.unsocketed then
        techButtons = { kTechId.SocketPowerNode }
    end
    
    return techButtons
    
end

function PowerPoint:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.SocketPowerNode then
    
        self:SocketPowerNode()
        return true, true
        
    end
    
    return false, true
    
end

function PowerPoint:SocketPowerNode()

    assert(self.powerState == PowerPoint.kPowerState.unsocketed)
    
    self.buildFraction = 0
    self.constructionComplete = false
    self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
    self:TriggerEffects("commander_create", { isalien = false })
    
    if GetGamerules():GetAutobuild() then
        self:SetConstructionComplete()
    end
    
end

function PowerPoint:GetPowerState()
    return self.powerState
end

function PowerPoint:GetCanConstructOverride(player)
    return not self:GetIsBuilt() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed and GetAreFriends(player,self)
end

function PowerPoint:GetIsDisabled()
    return self:GetPowerState() == PowerPoint.kPowerState.destroyed
end

function PowerPoint:GetIsSocketed()
    return self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed
end

function PowerPoint:SetLightMode(lightMode)
    
    if self:GetIsDisabled() then
        lightMode = kLightMode.NoPower
    end

    // Don't change light mode too often or lights will change too much
    if self.lightMode ~= lightMode or (not self.timeOfLightModeChange or (Shared.GetTime() > (self.timeOfLightModeChange + 1.0))) then
            
        self.lightMode = lightMode
        self.timeOfLightModeChange = Shared.GetTime()
        
    end
    
end

function PowerPoint:GetIsMapEntity()
    return true
end

function PowerPoint:GetLightMode()
    return self.lightMode
end

function PowerPoint:GetTimeOfLightModeChange()
    return self.timeOfLightModeChange
end

function PowerPoint:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = not GetPowerPointRecentlyDestroyed(self) and self.powerState ~= PowerPoint.kPowerState.unsocketed and (not self:GetIsBuilt() or (self:GetIsBuilt() and self:GetHealthScalar() < 1))
end

function PowerPoint:GetCanBeUsedConstructed()
    return self.powerState == PowerPoint.kPowerState.destroyed
end    

function PowerPoint:OverrideVisionRadius()
    return 2
end

function PowerPoint:GetAttackTime()
    return self.attackTime
end

/**
 * This PowerPoint should only check vision for nearby enemies when recently under attack.
 */
function PowerPoint:OverrideCheckVision()
    return self:GetAttackTime() ~= 0
end

function PowerPoint:GetCanBeWeldedOverride(player)
    return not GetPowerPointRecentlyDestroyed(self) and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed and self:GetHealthScalar() < 1, true
end

function PowerPoint:GetRecentlyRepaired()
    return self.timeOfNextBuildWeldEffects ~= nil and (math.abs(Shared.GetTime() - self.timeOfNextBuildWeldEffects) < 5)
end

function PowerPoint:GetTechAllowed(techId, techNode, player)
    return true, true
end

function PowerPoint:OnUse(player, elapsedTime, useSuccessTable)

    local success = false
    if player:isa("Marine") and self:GetIsBuilt() and self:GetHealthScalar() < 1 then
    
        if Server then
            self:OnWeld(player, elapsedTime)
        end
        success = true
        
        if player.OnConstructTarget then
            player:OnConstructTarget(self)
        end
        
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess or success
    
end

if Server then

    local function PowerUp(self)
    
        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetLightMode(kLightMode.Normal)
        self:StopSound(kAuxPowerBackupSound)
        self:TriggerEffects("fixed_power_up")
        self:SetPoweringState(true)
        
    end
    
    // Repaired by marine with welder or MAC 
    function PowerPoint:OnWeldOverride(entity, elapsedTime)
    
        local welded = false
        
        // Marines can repair power points
        if entity:isa("Welder") then

            local amount = kWelderPowerRepairRate * elapsedTime
            welded = (self:AddHealth(amount) > 0)            
            
        elseif entity:isa("MAC") then
        
            welded = self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime) > 0 
            
        else
        
            local amount = kBuilderPowerRepairRate * elapsedTime
            welded = (self:AddHealth(amount) > 0)
        
        end
        
        if self:GetHealthScalar() > kDamagedPercentage then
        
            self:StopDamagedSound()
            
            if self:GetLightMode() == kLightMode.LowPower and self:GetIsPowering() then
                self:SetLightMode(kLightMode.Normal)
            end
            
        end
        
        if self:GetHealthScalar() == 1 and self:GetPowerState() == PowerPoint.kPowerState.destroyed then
        
            self:StopDamagedSound()
            
            self.health = kPowerPointHealth
            self.armor = kPowerPointArmor
            
            self.maxHealth = kPowerPointHealth
            self.maxArmor = kPowerPointArmor
            
            self.alive = true
            
            PowerUp(self)
            
        end
        
        if welded then
            self:AddAttackTime(-0.1)
        end
        
    end
    
    function PowerPoint:OnConstructionComplete()

        self:StopDamagedSound()
        
        self.health = kPowerPointHealth
        self.armor = kPowerPointArmor
        
        self.maxHealth = kPowerPointHealth
        self.maxArmor = kPowerPointArmor
        
        self.alive = true
        
        PowerUp(self)
        
    end
    
    function PowerPoint:SetInternalPowerState(powerState)
    
        // Let the team know if power is back online.
        if self.powerState == PowerPoint.kPowerState.destroyed and powerState == PowerPoint.kPowerState.socketed then
        
            SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerRestored, self:GetLocationId())
            self:MarkBlipDirty()
            
        end
        
        self.powerState = powerState
        
        local modelToLoad = kSocketedModelName
        local graphToLoad = kSocketedAnimationGraph
        
        if powerState == PowerPoint.kPowerState.unsocketed then
        
            modelToLoad = kUnsocketedSocketModelName
            graphToLoad = kUnsocketedAnimationGraph
            
        end
        
        self:SetModel(modelToLoad, graphToLoad)
        
    end
    
    function PowerPoint:StopDamagedSound()
    
        if self.playingLoopedDamaged then
        
            self:StopSound(kDamagedSound)
            self.playingLoopedDamaged = false
            
        end
        
    end
    
    // send a message every kUnderAttackTeamMessageLimit seconds when a base power node is under attack
    local function CheckSendDamageTeamMessage(self)

        if not self.timePowerNodeAttackAlertSent or self.timePowerNodeAttackAlertSent + kUnderAttackTeamMessageLimit < Shared.GetTime() then

            // Check if there is a built Command Station in the same location as this PowerPoint.
            local foundStation = false
            local stations = GetEntitiesForTeam("CommandStation", self:GetTeamNumber())
            for s = 1, #stations do
            
                local station = stations[s]
                if station:GetIsBuilt() and station:GetLocationName() == self:GetLocationName() then
                    foundStation = true
                end
                
            end
            
            // Only send the message if there was a CommandStation found at this same location.
            if foundStation then
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerPointUnderAttack, self:GetLocationId())
                self:GetTeam():TriggerAlert(kTechId.MarineAlertStructureUnderAttack, self, true)
            end
            
            self.timePowerNodeAttackAlertSent = Shared.GetTime()
            
        end
        
    end
    
    function PowerPoint:OnTakeDamage(damage, attacker, doer, point)
    
        if self:GetIsPowering() then
        
            self:PlaySound(kTakeDamageSound)
            
            local healthScalar = self:GetHealthScalar()
            
            if healthScalar < kDamagedPercentage then
            
                self:SetLightMode(kLightMode.LowPower)
                
                if not self.playingLoopedDamaged then
                
                    self:PlaySound(kDamagedSound)
                    self.playingLoopedDamaged = true
                    
                end
                
            else
                self:SetLightMode(kLightMode.Damaged)
            end
            
            CheckSendDamageTeamMessage(self)
            
        end
        
        self:AddAttackTime(0.9)
        
    end
    
    local function PlayAuxSound(self)
    
        if not self:GetIsDisabled() then
            self:PlaySound(kAuxPowerBackupSound)
        end
        
    end
    
    function PowerPoint:OnKill(attacker, doer, point, direction)
    
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        
        self:StopDamagedSound()
        
        self:MarkBlipDirty()
        
        self:PlaySound(kDestroyedSound)
        self:PlaySound(kDestroyedPowerDownSound)
        
        self:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
        
        self:SetLightMode(kLightMode.NoPower)
        
        // Remove effects such as parasite when destroyed.
        self:ClearGameEffects()
        
        if attacker and attacker:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == attacker:GetTeamNumber() then
            attacker:AddScore(self:GetPointValue())
        end
        
        // Let the team know the power is down.
        SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerLost, self:GetLocationId())
        
        // A few seconds later, switch on aux power.
        self:AddTimedCallback(PlayAuxSound, 4)
        self.timeOfDestruction = Shared.GetTime()
        
    end
    
    function PowerPoint:Reset()
    
        SetupWithInitialSettings(self)
        
        ScriptActor.Reset(self)
        
        self:MarkBlipDirty()
        
    end
    
    function PowerPoint:GetSendDeathMessageOverride()
        return self:GetIsPowering()
    end
    
    function PowerPoint:AddAttackTime(value)
        self.attackTime = Clamp(self.attackTime + value, 0, kMaxAttackTime)
    end
    
end

local function CreateEffects(self)

    // Create looping cinematics if we're low power or no power
    local lightMode = self:GetLightMode() 
    
    if lightMode == kLightMode.LowPower and not self.lowPowerEffect then
    
        self.lowPowerEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.lowPowerEffect:SetCinematic(kDamagedEffect)        
        self.lowPowerEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.lowPowerEffect:SetCoords(self:GetCoords())
        self.timeCreatedLowPower = Shared.GetTime()
        
    elseif lightMode == kLightMode.NoPower and not self.noPowerEffect then
    
        self.noPowerEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.noPowerEffect:SetCinematic(kOfflineEffect)
        self.noPowerEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.noPowerEffect:SetCoords(self:GetCoords())
        self.timeCreatedNoPower = Shared.GetTime()
        
    end
    
    if self:GetPowerState() == PowerPoint.kPowerState.socketed and self:GetIsBuilt() and self:GetIsVisible() then
    
        if self.lastImpulseEffect == nil then
            self.lastImpulseEffect = Shared.GetTime() - PowerPoint.kImpulseEffectFrequency
        end
        
        if self.lastImpulseEffect + PowerPoint.kImpulseEffectFrequency < Shared.GetTime() then
        
            self:CreateImpulseEffect()
            self.createStructureImpulse = true
            
        end
        
        if self.lastImpulseEffect + 1 < Shared.GetTime() and self.createStructureImpulse == true then
        
            self:CreateImpulseStructureEffect()
            self.createStructureImpulse = false
            
        end
        
    end
    
end

local function DeleteEffects(self)

    local lightMode = self:GetLightMode() 
    
    // Delete old effects when they shouldn't be played any more, and also every three seconds
    local kReplayInterval = 3
    
    if (lightMode ~= kLightMode.LowPower and self.lowPowerEffect) or (self.timeCreatedLowPower and (Shared.GetTime() > self.timeCreatedLowPower + kReplayInterval)) then
    
        Client.DestroyCinematic(self.lowPowerEffect)
        self.lowPowerEffect = nil
        self.timeCreatedLowPower = nil
        
    end
    
    if (lightMode ~= kLightMode.NoPower and self.noPowerEffect) or (self.timeCreatedNoPower and (Shared.GetTime() > self.timeCreatedNoPower + kReplayInterval)) then
    
        Client.DestroyCinematic(self.noPowerEffect)
        self.noPowerEffect = nil
        self.timeCreatedNoPower = nil
        
    end
    
end

function PowerPoint:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
	if Client then
	
	    CreateEffects(self)
	    DeleteEffects(self)
	    
	else
	
	    self:AddAttackTime(-0.1)
	    
	    if self:GetLightMode() == kLightMode.Damaged and self:GetAttackTime() == 0 then
	        self:SetLightMode(kLightMode.Normal)
	    end
	    
	end
    
end

function PowerPoint:CanBeWeldedByBuilder()
    return self:GetHealthScalar() < 1 and self.powerState == PowerPoint.kPowerState.destroyed
end

function PowerPoint:GetCanBeUsedDead()
    return true
end

function PowerPoint:GetShowUnitStatusForOverride()
    return (self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed)
end

local kPowerPointTargetOffset = Vector(0, 0.3, 0)
function PowerPoint:GetEngagementPointOverride()
    return self:GetCoords():TransformPoint(kPowerPointTargetOffset)
end

Shared.LinkClassToMap("PowerPoint", PowerPoint.kMapName, networkVars)
