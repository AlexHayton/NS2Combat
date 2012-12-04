//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

Script.Load("lua/Class.lua")


kFindEntitiesAfterLoad = {}

// overrides OnUpdate so we can find the entity ids for the entitys after map has loaded
local originalNS2GamerulesOnUpdate
originalNS2GamerulesOnUpdate = Class_ReplaceMethod( "NS2Gamerules", "OnUpdate", 
	function(self, timePassed)

            
            if self:GetMapLoaded() then
                if #kFindEntitiesAfterLoad > 0 then
                    for i, entity in ipairs(kFindEntitiesAfterLoad) do
                        Shared.GetEntity(entity):FindEntitys()                        
                    end   
                    kFindEntitiesAfterLoad = {}
                end
                
            end
            originalNS2GamerulesOnUpdate(self, timePassed)

    end
)