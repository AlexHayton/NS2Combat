//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_TechNode.lua

function TechNode:CopyDataFrom(techNode)

	self.techId             = techNode.techId
	self.techType           = techNode.techType
	self.prereq1            = techNode.prereq1
	self.prereq2            = techNode.prereq2
	self.addOnTechId        = techNode.addOnTechId
	self.cost               = techNode.cost
	self.available          = techNode.available
	self.time               = techNode.time
    self.researchProgress 	= techNode.researchProgress
    self.prereqResearchProgress = techNode.prereqResearchProgress
	self.researched         = techNode.researched
	self.researching        = techNode.researching
	self.hasTech            = techNode.hasTech
	self.requiresTarget     = techNode.requiresTarget
        
end