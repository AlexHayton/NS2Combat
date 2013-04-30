// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PreloadMod.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

SharedLinkClassToMapOriginal = Shared.LinkClassToMap
gModClassMap = gModClassMap or {}
gModClassOrder = gModClassOrder or {}

function Shared.LinkClassToMap(className, mapName, networkVars, compensated)

    if not gModClassMap[className] then
    
        gModClassMap[className] = {}
        table.insert(gModClassOrder, className)
        
    end
    
    local classEntry = gModClassMap[className]
    classEntry.mapName = mapName or classEntry.mapName
    
    if compensated ~= nil then
        classEntry.compensated = compensated
    end
    
    if not classEntry.networkVars then
        classEntry.networkVars = {}
    end
    
    if networkVars then
    
        // overwrite / add variable definitions
        for variableName, type in pairs(networkVars) do            
            classEntry.networkVars[variableName] = type            
        end
    
    end

end