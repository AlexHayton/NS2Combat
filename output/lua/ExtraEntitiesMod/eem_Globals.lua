//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

kFallDamage = false

local function AddMinimapBlipType(blipType)
	
	// We have to reconstruct the kTechId enum to add values.
	local enumTable = {}
	for index, value in ipairs(kMinimapBlipType) do
		table.insert(enumTable, value)
	end
	
	table.insert(enumTable, blipType)
	
	kMinimapBlipType = enum(enumTable)
	
end

AddMinimapBlipType("NpcManagerTunnel")