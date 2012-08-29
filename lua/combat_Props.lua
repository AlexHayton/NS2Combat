//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// how to get the origin (different from the editor)

// coord Editor (513) / 39,36 = 13,03 (spark choord), for x, y and z choord

//pairs for spawn

combatSpawnList = {}

// ns2_tram
/*combatSpawnList.ns2_tram = {}
table.insert(combatSpawnList.ns2_tram,   
    {
    Spawn = {"Shipping", "Repair Room"},
    Props = {
            {Vector(-2833, -112, 2809.24), Angles(0, 0, 0), Vector(3.73, 3.64, 0.66)},
            {Vector(-2411, -46, 2826), Angles(0, 0, 0), Vector(1.96, 1.04, 0.46)},
            {Vector(-768, -112, 1690), Angles(0, 0, 0), Vector(5, 3.31, 1)},
            {Vector(-253.42, -121.28, 1281), Angles(0, 0, 0), Vector(1, 3.71, 5.5)},
            {Vector(-272.79, -76, 321), Angles(0, 0, 0), Vector(0.35, 2.82, 4.58)},
            {Vector(-399, 71.12, -535), Angles(0, 0, 0), Vector(1.88, 1, 0.27)}
            }
    })

    
table.insert(combatSpawnList.ns2_tram,   
{
    Spawn = {"Shipping", "Elevator Transfer"},
    Props = {
            {Vector(-253.42, -121.28, 1281), Angles(0, 0, 0), Vector(1, 3.71, 5.5)},
            {Vector(-727, -144, 929.38), Angles(0, 0, 0), Vector(4.19, 4.01, 1.79)},
            {Vector(-368, -144, 929.38), Angles(0, 0, 0), Vector(4.19, 4.01, 1.79)},           
            {Vector(-380, -32, 3609.68), Angles(0, 0, 0), Vector(2.85, 2.66, 0.6)},
            {Vector(149.4, 266, 2710), Angles(0, 0, 0), Vector(0.75, 1.16, 2)},
            {Vector(-2245.82, 20, 451), Angles(0, 0, 0), Vector(1, 3.31, 3.35)},
            {Vector(-2769, 28, -336), Angles(0, 0, 0), Vector(2.81, 1.51, 1.54)},
            }
    })
   

table.insert(combatSpawnList.ns2_tram,   
{
    Spawn = {"Repair Room", "Warehouse"},
    Props = {
            {Vector(-1333, -138, 1324), Angles(0, 0, 0), Vector(0.65, 3.76, 3.46)},            
            {Vector(-762, -114.67, 1706.68), Angles(0, 0, 0), Vector(5.31, 3.57, 1.26)},            
            {Vector(-1309, -76, -55), Angles(0, 0, 0), Vector(0.65, 2.9, 5.42)}, 
            {Vector(571, -126.86, 2298.47), Angles(0, 0, 0), Vector(3.73, 3.74, 1)},            
            {Vector(607, -216, 2275.12), Angles(0, 0, 0), Vector(2.04, 1, 0.74)},
            }
    }) 
*/
  
  /*
                {"Elevator Transfer", "Server"}
                }

*/



combatSpawnCombo = nil
combatSpawnComboIndex = nil
CombatPropList = {}

function CombatGetSpawns()

    // get the current map
    local mapName = Shared.GetMapName() 
    
    if not combatSpawnCombo then    
        // only do something when the map is in the List
        if combatSpawnList[mapName] then
        // get a random number an pick the spawn combo
            
            local randomNrSpawnCombo = math.random(1, table.maxn(combatSpawnList[mapName]))
            
            local randomNrSpawnTeam1 = ConditionalValue(math.random() < .5, 1, 2)
            local randomNrSpawnTeam2 = ConditionalValue(randomNrSpawnTeam1 == 2, 1, 2)
            
            local spawnTeam1Location = combatSpawnList[mapName][randomNrSpawnCombo]["Spawn"][randomNrSpawnTeam1]
            local spawnTeam2Location = combatSpawnList[mapName][randomNrSpawnCombo]["Spawn"][randomNrSpawnTeam2]            
                        
            combatSpawnCombo = {spawnTeam1Location, spawnTeam2Location}
            combatSpawnComboIndex = randomNrSpawnCombo
            
            return spawnTeam1Location, spawnTeam2Location
        end
    else     
        return combatSpawnCombo[1],  combatSpawnCombo[2]     
    end

end

function CombatInitProps()
    // TODO: maybe create an effect, too
    local mapName = Shared.GetMapName() 
    if combatSpawnList[mapName] and combatSpawnComboIndex then
        for index, prop in ipairs (combatSpawnList[mapName][combatSpawnComboIndex]["Props"]) do
            CombatCreateProp(prop[1], prop[2], prop[3])
        end
    end
end

function CombatCreateProp(origin, angels, scale)

    // addept Editor values to engine values
    local sparkFactor = (1 / 39.36)
    
    origin = origin * sparkFactor  
    //scale = scale * sparkFactor  
  
    local coords = angels:GetCoords(origin)
    
    coords.xAxis = coords.xAxis * scale.x
    coords.yAxis = coords.yAxis * scale.y
    coords.zAxis = coords.zAxis * scale.z

    local renderModelCommAlpha = 0
    local blocksPlacement = true
    //local CollisionObject.Static = 1
    
    // the model ist just the source, need to be a quadratic or circle model
    local model = "models/props/generic/generic_crate_01.model"
    
    // Create the physical representation of the prop.
    local physicsModel = Shared.CreatePhysicsModel(model, false, coords, nil) 
    physicsModel:SetPhysicsType(1)
    
    // Make it not block selection and structure placement (GetCommanderPickTarget)
    if renderModelCommAlpha < 1 or blocksPlacement then
        physicsModel:SetGroup(PhysicsGroup.CommanderPropsGroup)
    end

    table.insert(CombatPropList, physicsModel)
        if Client then
    
            // Create the visual representation of the prop.
            // All static props can be instanced.
            local renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)       
            renderModel:SetModel(model)
            
            renderModel:SetCastsShadows(true)
            
            renderModel:SetCoords(coords)
            renderModel:SetIsStatic(true)
            renderModel:SetIsInstanced(true)
            renderModel:SetGroup("")
            
            renderModel.commAlpha = renderModelCommAlpha
            
            table.insert(Client.propList, {renderModel, physicsModel})
        
        end

end

function CombatUpdatePropEffect(team)

    for i, prop in ipairs(CombatPropList) do  
         // get the middle of the prop
         local coords = prop:GetCoords()
         local middle = coords.origin + (coords.yAxis / 2)
         
		 // Spawn an effect, just a dummy entity cause its getting destroyed after the effect (you can just play a effect you need an entity first)
		 propEntity = CreateEntity(EtherealGate.kMapName, middle, team:GetTeamNumber())	 

		 // play the effect and destroy the entity
		 propEntity:TriggerEffects(kPropEffect)
		 DestroyEntity(propEntity)

		 // Old way of sending the prop effect, with a message.
		 //team:PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, 0, middle , 20)
    end

end

function CombatDeleteProps()

    for i, prop in ipairs(CombatPropList) do
         Shared.DestroyCollisionObject(prop)
    end

    CombatPropList = {}
end
