// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PostLoadMod.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// link all class names

for i = 1, #gModClassOrder do

    local className = gModClassOrder[i]
    local classInfo = gModClassMap[className]

    // classes without a mapname should not be mapped.
    if classInfo.mapName then
        if classInfo.compensated == true then
            SharedLinkClassToMapOriginal(className, classInfo.mapName, classInfo.networkVars, true)
        else
            SharedLinkClassToMapOriginal(className, classInfo.mapName, classInfo.networkVars)
        end
    end
    
end