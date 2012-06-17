//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_TechTree.lua

// Provide a deep copy function for the tech tree.
function TechTree:CopyDataFrom(techTree)
	self.nodeList = {}
	// Deep clone the node list.
	for i,v in pairs(techTree.nodeList) do
		table.insert(self.nodeList, i, TechNode())
		self.nodeList[i]:CopyDataFrom(techTree.nodeList[i])
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