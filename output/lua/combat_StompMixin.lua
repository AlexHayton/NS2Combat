//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// changed it from tierthree to tiertwo
function StompMixin:GetHasSecondary(player)
    return GetIsTechUnlocked(player, kTechId.Stomp)
end