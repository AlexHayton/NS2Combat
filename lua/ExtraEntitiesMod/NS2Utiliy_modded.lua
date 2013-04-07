//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

local originalGetPointBlocksAttachEntities = GetPointBlocksAttachEntities
function GetPointBlocksAttachEntities(origin)
    // y the nobuild area is blocking us
    if Pathing.GetIsFlagSet(origin, Vector(0.5,0.5,0.5), Pathing.PolyFlag_NoBuild) then
        return true
    else
        return originalGetPointBlocksAttachEntities(origin)    
    end
end