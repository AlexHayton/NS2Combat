//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_DisorientableMixin.lua

function DisorientableMixin:GetDisorientedAmount()
	if self:isa("DevouredPlayer") then
		return 4
	else
		return self.disorientedAmount
	end
end