//
//   Created by:   fsfod
//

DispatchBuilder = DispatchBuilder or {}
 
local RawDispatcherI, RawClassDispatcherI

local function handleResults(hookData, ...)
  
  local retvalue = hookData.ReturnValue
  
  if(retvalue) then
    hookData.ReturnValue = nil
    return unpack(retvalue)
  else
    return ...
  end
end



--maybe we could create all these dispatchers as closeure
function DispatchBuilder:CreateNormal(hookData)

  local hook = hookData[1]
  
  if(not hookData.MultiReturn) then
	  return function(...)
	    hook(...)
    
	    local retvalue = hookData.Orignal(...)
    
	    	if(hookData.ReturnValue) then
	    		retvalue = hookData.ReturnValue
	    		hookData.ReturnValue = nil
      
	    		if(retvalue == FakeNil) then
	    			retvalue = nil
	    		end
	    	end
      
	    return retvalue
	  end
	else
	  
	  return function(...)
	    hook(...)
    
      return handleResults(hookData, hookData.Orignal(...))
	  end
	end
end

function DispatchBuilder:CreateSingleClassRaw(hookData)

  local dispatcher
  
  if(not hookData.MultiReturn) then
    
    dispatcher = function(self, ...) 
      local retvalue = hookData.Orignal(self, ...) 
      
      if(hookData.ReturnValue) then
	    		retvalue = hookData.ReturnValue
	    		hookData.ReturnValue = nil
	    		
	    		if(retvalue == FakeNil) then
	    			retvalue = nil
	    		end
	    end
	    
	    return retvalue
    end
	else
    
    dispatcher = function(...)  
      return handleResults(hookData, hookData.Orignal(...))
    end
	end


  local hook = hookData.Raw[1]

  return function(self, ...)
	  return dispatcher(self, hook(self, ...))
  end
  
end

function DispatchBuilder:CreateSingleRaw(hookData)
  
  local dispatcher

  if(not hookData.MultiReturn) then
  
    dispatcher = function(...) 
      local retvalue = hookData.Orignal(...) 
      
      if(hookData.ReturnValue) then
	    		retvalue = hookData.ReturnValue
	    		hookData.ReturnValue = nil
	    		
	    		if(retvalue == FakeNil) then
	    			retvalue = nil
	    		end
	    end
    
	    return retvalue
    end
  
  else
    
    dispatcher = function(...)  
      return handleResults(hookData, hookData.Orignal(...))
    end
    
  end

  local hook = hookData.Raw[1]

  return function(...)
	  return dispatcher(hook(...))
  end
end

function DispatchBuilder:CreateSinglePost(hookData)

  local hook = hookData.Post[1]
  
	if(not hookData.MultiReturn) then
	  return function(...)
	    --Store the return value in our hookinfo so the post hook can read it if it wants
	    hookData.ReturnValue = hookData.Orignal(...)
	    hook(...)
      
	    local retvalue = hookData.ReturnValue
	    hookData.ReturnValue = nil
      
      if(retvalue == FakeNil) then
		  	retvalue = nil
		  end
      
	    return retvalue
	  end
	  
	else
	  
	  return function(...)
	    --Store the return values in our hookinfo so the post hook can read it if it wants
	    hookData.ReturnValue = {hookData.Orignal(...)}
	    
	    hook(...)
	    
	    local retvalue = hookData.ReturnValue
      hookData.ReturnValue = nil
      
		  return unpack(retvalue)
	  end
	end

end

function DispatchBuilder:CreateDispatcher(hookData, isClassFunction)

  local Normal = #hookData
  local Raw = hookData.Raw ~= nil and #hookData.Raw
  local Post = hookData.Post ~= nil and #hookData.Post

	if(Normal == 1 and not Raw and not Post) then
		return self:CreateNormal(hookData)
	end

	if(Normal == 0) then
		if(Raw == 1 and not Post) then
		  
			if(hookData.Class) then
				return self:CreateSingleClassRaw(hookData)
			else
			  return self:CreateSingleRaw(hookData)
			end
			
		elseif(Post == 1 and not Raw) then
			return self:CreateSinglePost(hookData)
		else
		  
		  if(not Post and not Raw) then
		    
		    if(hookData.ReplacedOrignal) then
		      local hook = hookData.ReplacedOrignal
			   return function(...) return hook(...) end
			  else
			    return nil
			  end
			  
			end
		end
	end

	if(hookData.Class) then
		return self:CreateMultiHookClassDispatcher(hookData)
	else
		return self:CreateMultiHookDispatcher(hookData)
	end
end

local function CreateRawTableChain(tableCount, IsClass)

	local str = {}
	local FormatString = (IsClass and "tbl[%i](self,") or "tbl[%i]("

	for z=tableCount,1,-1 do
		str[#str+1] = string.format(FormatString, i)
	end

	str[#str+1] = "..."

	for z=1,tableCount do
		str[#str+1] = ")"
	end

	return table.concat(str, "")
end

local function CreateTblPassingString(entryCoount)

	local str = {}

	for z=entryCoount,1,-1 do
		str[#str+1] = string.format("tbl[%i](...) ", i)
	end

	return table.concat(str, "")
end

function CaptureMultiValueResult(...)

  local count = select('#', ...)

  return count > 1, (count == 1 and ...) or (count > 1 and {...}) or nil
end

local function RawArgsToNormalHooks(hookData, ...)
	if(#hookData) then
		for _,hook in ipairs(hookData) do
			hook(...)
		end
	end

  //have to call this here to work around the lua vm loading Orignal too early when this was called in the multihook dispatcher functions. LuaJIT seems to load it late
	return hookData.Orignal(...)
end

--TODO add exception handling 
function DispatchBuilder:CreateMultiHookClassDispatcher(hookData)

  return function(...)
	  local retvalue
    
	  if(hookData.Raw) then
	  	retvalue = RawArgsToNormalHooks(hookData, select(1, ...), RawClassDispatcherI[#hookData.Raw](hookData.Raw, ...))
	  else
	  	retvalue = RawArgsToNormalHooks(hookData,...)
	  end
    
	  if(hookData.Post) then
	   hookData.ReturnValue = hookData.ReturnValue or retvalue 
    
	  	for _,hook in ipairs(hookData.Post) do
	  		hook(...)
	  	end
	  end

	  if(hookData.ReturnValue) then
	  	retvalue = hookData.ReturnValue
	  	hookData.ReturnValue = nil
	  		
	  	if(retvalue == FakeNil) then
	  		retvalue = nil
	  	end
	  end

   return retvalue
  end
end

function DispatchBuilder:CreateMultiHookDispatcher(hookData)

  return function(...)
	  local retvalue

	  if(hookData.Raw) then
	  	retvalue = RawArgsToNormalHooks(hookData, RawDispatcherI[#hookData.Raw](hookData.Raw, ...))
	  else
	  	retvalue = RawArgsToNormalHooks(hookData, ...)
	  end
    
	  if(hookData.Post) then
	  	hookData.ReturnValue = hookData.ReturnValue or retvalue 
    
	  	for _,hook in ipairs(hookData.Post) do
	  		hook(...)
	  	end
	  end
    
	  if(hookData.ReturnValue) then
	  	retvalue = hookData.ReturnValue
	  	hookData.ReturnValue = nil
	  		
	  	if(retvalue == FakeNil) then
	  		retvalue = nil
	  	end
	  end
	  
   return retvalue
  end
end

function DispatchBuilder.ErrorHandler(err)
	Shared.Message(err)
end

--note luaJITs xpcall can take extra arguments to pass to the function being called
function DispatchBuilder.DebugDispatcher(hookData, ...)

	local args = {...}
	local success

	if(hookData.Raw) then
		local self = select(1, ...)
		
		for _,hook in ipairs(hookData.Raw) do
			local args2 = {xpcall(hook, DispatchBuilder.ErrorHandler, unpack(args))}
			
			--check to see if the captured success return value is true
			if(args2[1] == true) then
				args2[1] = self
				args = args2
			end
		end
	end

	if(#hookData ~= 0) then
		for _,hook in ipairs(hookData) do
			xpcall(hook, DispatchBuilder.ErrorHandler, unpack(args))
		end
	end
	
	hookData.ReturnValue = hookData.Orignal(unpack(args))
	
	if(hookData.Post) then
		for _,hook in ipairs(hookData.Post) do
			xpcall(hook, DispatchBuilder.ErrorHandler, unpack(args))
		end
	end
	
	local retvalue = hookData.ReturnValue
	hookData.ReturnValue = nil
	
	if(retvalue == FakeNil) then
		retvalue = nil
	end
	
	return retvalue
end

function CreateCustom(hookData)
	
	local funcbody = {[[
		local normalDispatcher = DispatcherI[#hookData]
			return function(hookDataArg, ...)
	]]}

	if(hookData.Raw and #hookData) then
		funcbody[#funcbody+1] = [[
				local tbl = hookDataArg.Raw
		]]
		

		funcbody[#funcbody+1] = [[local retvalue = hookDataArg.Orignal(normalDispatcher(hookDataArg, ]]

		funcbody[#funcbody+1] = CreateRawTableChain(#hookData.Raw)
		funcbody[#funcbody+1] = "))\n"
	else
		if(#hookData) then
			--funcbody[#funcbody+1] = CreateTblPassingString(#hookData)
			
			funcbody[#funcbody+1] = [[
				for _,hook in ipairs(hookData) do
					hook(...)
				end
			]]
		elseif(hookData.Raw) then
			funcbody[#funcbody+1] = [[
				local tbl = hookData.Raw
			]]
			funcbody[#funcbody+1] = CreateRawTableChain(#hookData.Raw)
			funcbody[#funcbody+1] = ")\n"
		end
	end
	
	if(hookData.Post) then
		funcbody[#funcbody+1] = [[
			for _,hook in ipairs(hookDataArg.Post) do
				hook(...)
			end
		]]
	end
	
	funcbody[#funcbody+1] = [[
		if(hookDataArg.ReturnValue) then
			retvalue = hookDataArg.ReturnValue
			hookDataArg.ReturnValue = nil
			
			if(retvalue == FakeNil) then
				retvalue = nil
			end
		end
	
	 return retvalue
	end
	]]
end


RawClassDispatcherI = {
	[0] = function(...) return ... end,
	function (tbl, self, ...) return tbl[1](self, ...) end,
	function (tbl, self, ...) return tbl[2](self, tbl[1](self, ...)) end,
	function (tbl, self, ...) return tbl[3](self, tbl[2](self, tbl[1](self, ...))) end,
}

setmetatable(RawClassDispatcherI, {
	__index = function(self, i)
		local func = loadstring("return function (tbl, self, ...) return " .. CreateRawTblPassingString(i, true).."end")()
		 rawset(self, i, func)
		
		return func
	end
})

RawDispatcherI = {
	[0] = function(...) return ... end,
	function (tbl, self, ...) return tbl[1](self, ...) end,
	function (tbl, self, ...) return tbl[2](self, tbl[1](self, ...)) end,
	function (tbl, self, ...) return tbl[3](self, tbl[2](self, tbl[1](self, ...))) end,
}

setmetatable(RawDispatcherI, {
	__index = function(self, i)
		local func = loadstring("return function (tbl, ...) return " .. CreateRawTblPassingString(i).."end")()
		 rawset(self, i, func)
		
		return func
	end
})