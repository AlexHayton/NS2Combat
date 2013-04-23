//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/Class.lua")
Script.Load("lua/Order.lua")

// original network variables are not deleted
local networkVars =
{
    // to get rid of that stupid order param ist out of .. error
    orderParam = "integer (-1 to 9999)",
}


Class_Reload("Order", networkVars)