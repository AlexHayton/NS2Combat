//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_TechTree.lua

// Provide a deep copy function for the tech tree.
function TechTree:CopyDataFrom(techTree)
	self.nodeList = {}
	// Deep clone the node list.
	local index, oldTechNode = next(techTree.nodeList, nil)
	while index do
		local techId = oldTechNode:GetTechId()
		local newTechNode = TechNode()
		newTechNode:CopyDataFrom(oldTechNode)
		self.nodeList[techId] = newTechNode
		index, oldTechNode = next(techTree.nodeList, index)
	end
    
    self.techChanged = techTree.techChanged
    self.complete = techTree.complete
    
    // No need to add to team
    self.teamNumber = techTree.teamNumber
    
    if Server then
        self.techNodesChanged = {}
		self.upgradedTechIdsSupporting = {}
		
		// Deep clone the supporting techId list.
		for i,v in pairs(techTree.upgradedTechIdsSupporting) do
			table.insert(self.upgradedTechIdsSupporting, i, techTree.upgradedTechIdsSupporting[i])
		end	
    end
end