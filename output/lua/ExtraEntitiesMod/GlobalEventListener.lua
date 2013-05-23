//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________


// hook game viz to get the event
originalPostGameViz = PostGameViz
function PostGameViz(msg, targetEntity)
    originalPostGameViz(msg, targetEntity)
    SendEventToListeners(msg, targetEntity)
end


// send the event to all listeners
function SendEventToListeners(msg, targetEntity)
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("LogicEventListener")) do
        ent:OnEvent(msg, targetEntity)
    end
end