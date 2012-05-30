//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_ConsoleCommands.lua



function OnCommandSpendLvl(client, type)
        
    local player = client:GetControllingPlayer() 
        
    if type then
         if player:isa("Marine") then
            for i,v in ipairs(UpsList.Marine.Weapons) do 
                // do a WeaponUpgrade
                if v == type then
                    // Call the UpgradeFunction              
                    player:CoCheckUpgradeWeapon(type)                    
                    break
                end
            end
            
            for i,v in ipairs(UpsList.Marine.others) do 
                // do another up
                if v == type then
                    // Call the UpgradeFunction              
                    player:CoCheckUpgradeOther(type)                    
                    break
                end
            end
            
        elseif player:isa("Alien") then
            for i,v in ipairs(UpsList.Alien) do 
                // type is valid
                if v == type then
                    // Call the UpgradeFunction
                    player:CoCheckUpgrade(type)
                    break
                else 
                    Shared.Message(type .. " is no vaild Upgrade")
                end
            end
        end
    else
        Shared.Message("No type defined, usage is: co_spendlvl type")
    end
        
    
    

end

function OnCommandAddXp(client, amount)

        local player = client:GetControllingPlayer()        
        if Shared.GetCheatsEnabled() then
            if amount then            
                player:AddXp(amount)
            else
                player:AddXp(1)
            end
	    end
end

function OnCommandShowXp(client)

        local player = client:GetControllingPlayer()        
        print(player:GetXp())

end

function OnCommandShowLvl(client)

        local player = client:GetControllingPlayer()        
        print(player:GetLvl())

end
 
 
Event.Hook("Console_co_spendlvl",                OnCommandSpendLvl)

Event.Hook("Console_co_addxp",                OnCommandAddXp)
Event.Hook("Console_co_showxp",                OnCommandShowXp)
Event.Hook("Console_co_showlvl",                OnCommandShowLvl)
