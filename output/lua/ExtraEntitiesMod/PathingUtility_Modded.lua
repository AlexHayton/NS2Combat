//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// at this point, all entities are loaded, so best way to search others (for train)
// only for server

if Server then

    local overrideInitializePathing = InitializePathing
    function InitializePathing()

        overrideInitializePathing()
        FindTrainEntities()
        
    end

end


function FindTrainEntities()
    local trainEntities = GetEntitiesWithMixin("Train")

    for i, trainEntity in ipairs(trainEntities) do
        trainEntity:CreatePath()
    end
end
