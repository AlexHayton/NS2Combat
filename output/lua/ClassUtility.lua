
Script.Load("lua/Class.lua")

local function GetClassCount()

    local classCount = 0
    for c, m in pairs(_G) do
        if type(m) == "table" then
            classCount = classCount + 1
        end
    end
    
    return classCount

end

local copyProgress = 0
local classCount = classCount or GetClassCount()

local function CopyClassTable()

    local copyTable = {}
    
    copyProgress = 0
    local index = 1
    local lastPrint = 0
    local printInterval = 0.25
    local lastPrint = 0
    
    for className, methodTable in pairs(_G) do
        
        if type(methodTable) == "table" then
        
            copyProgress = index / classCount
        
            for methodName, method in pairs(methodTable) do
            
                if type(method) == "function" then
                    if not copyTable[className] then
                        copyTable[className] = {}
                    end
                    copyTable[className][methodName] = method
                end
     
            end
            
            index = index + 1
            
        end
    
    end
    
    return copyTable
    
end

local _Gcopy = _Gcopy or CopyClassTable()

local function ReplaceMethodInDerivedClasses(className, methodName, method, original)

    // only replace the method when it matches with super class (has not been implemented by the derrived class)
	if _G[className][methodName] ~= original then
		return
	end

	_G[className][methodName] = method

	local classes = Script.GetDerivedClasses(className)
	assert(classes ~= nil)
	
	for i, c in ipairs(classes) do
		ReplaceMethodInDerivedClasses(c, methodName, method, original)
	end

end

function Class_Reload(className, networkVars)

    assert(className)
    local methods = _G[className] // this has already been updated for <className>, but needs to be copied to child classes which dont re-implement the function
    local originalMethods = _Gcopy[className]
    local childClasses = Script.GetDerivedClasses(className)
    
    for methodName, method in pairs(methods) do
    
        if type(method) == "function" then
        
            local originalMethod = originalMethods[methodName]
            
            if originalMethod ~= nil and method ~= originalMethod then
                        
                for i, c in ipairs(childClasses) do
                    ReplaceMethodInDerivedClasses(c, methodName, method, originalMethods[methodName])
                end
                
            end
            
        end
        
    end
    
    // needs to be refreshed (in case a mod mods a mod :) )
    _Gcopy = CopyClassTable()
    
    // dont delete old network vars, simply replace them if their type has changed or add them if new
    Shared.LinkClassToMap(className, nil, networkVars)

end