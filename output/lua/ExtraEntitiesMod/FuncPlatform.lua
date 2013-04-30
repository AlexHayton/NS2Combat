//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// FuncPlatform.lua
// Entity for mappers to create drivable trains

Script.Load("lua/ExtraEntitiesMod/FuncTrain.lua")

class 'FuncPlatform' (FuncTrain)

FuncPlatform.kMapName = "func_platform"
FuncPlatform.kMoveSpeed = 15.0
FuncPlatform.kHoverHeight = 0.8

local networkVars =
{    
}

function FuncPlatform:OnCreate() 
    FuncTrain.OnCreate(self)    
end

function FuncPlatform:OnInitialized()
    FuncTrain.OnInitialized(self)
end

function FuncPlatform:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

//**********************************
// Driving things
//**********************************

function FuncPlatform:GetRotationEnabled()
    return false
end

//**********************************
// Viewing things
//**********************************

function FuncPlatform:OnLogicTrigger(player)
    // if the elevator is moving, dont stop him
    if not self.driving then
        self:ChangeDrivingStatus()
    end
end

//**********************************
// Sever and Client only functions
//**********************************

if Server then  
    function FuncPlatform:UpdatePosition(deltaTime)
       
        if self.nextWaypoint then
            // check if the waypoint got a delay
                local done = self:TrainMoveToTarget(PhysicsMask.All, self.nextWaypoint, self:GetSpeed(), deltaTime)                
                //if self:IsTargetReached(hoverWaypont, kAIMoveOrderCompleteDistance) then
                if done then
                    self:ChangeDrivingStatus()
                    self.nextWaypoint = nil
                end
            //end          

        else
            self:GetNextWaypoint()
        end            
    end 
end



Shared.LinkClassToMap("FuncPlatform", FuncPlatform.kMapName, networkVars)