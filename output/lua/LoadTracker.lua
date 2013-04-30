//
//   Created by:   fsfod
//

local HotReload = LoadTracker

if(not LoadTracker) then
  LoadTracker = {
  	LoadStack = {},
  	LoadedScripts = {},
  	
  	LoadAfterScripts = {},
  	LoadedFileHooks = {},
  	OverridedFiles = {},
  }

  LoadTracker.NormalizePath = NormalizePath
  
  local Script_Load = Script.Load
  
  Script.Load = function(scriptPath)
  	//just let the real script.load bomb on bad paramters
  	if(not scriptPath or type(scriptPath) ~= "string") then
  		Script_Load(scriptPath)
  	end
  	
  	local normPath = NormalizePath(scriptPath)
  	local NewPath = LoadTracker:ScriptLoadStart(normPath, scriptPath)
  	
  	local ret
  	
  	if(NewPath and NewPath ~= "") then
  		ret = Script_Load(NewPath)
  	end
  	
  	assert(ret ==  nil)
  	
  	LoadTracker:ScriptLoadFinished(normPath)
  end

end

function LoadTracker:LuaReloadStarted()
  self.LoadedScripts = {}
end

function LoadTracker:ScriptLoadStart(normalizedsPath, unnormalizedsPath)
	table.insert(self.LoadStack, normalizedsPath)
	
	--store the stack index so we can be sure were not reacting to a double load of the same file
	if(not self.LoadedScripts[normalizedsPath]) then
		self.LoadedScripts[normalizedsPath] = #self.LoadStack
		
		local FileOverride = self.OverridedFiles[normalizedsPath]
		
		if(FileOverride) then
			if(type(FileOverride) ~= "table") then
			  return FileOverride
			else
				RunScriptFromSource(FileOverride[1], FileOverride[2])
			 return false
			end
		end
	else
		--block a double load of an override
		if(self.OverridedFiles[normalizedsPath]) then
			return false
		end
	end
	
	return unnormalizedsPath
end

function LoadTracker:HookFileLoadFinished(scriptPath, selfOrFunc, funcName)
	
	local path = NormalizePath(scriptPath)
	
	if(self.LoadedScripts[tobeNorm]) then
		error("cannot set FileLoadFinished hook for "..scriptPath.." because the file is already loaded")
	end

	local tbl = self.LoadedFileHooks[path]

	if(not tbl) then
		tbl = {}
		self.LoadedFileHooks[path] = tbl
	end

	if(funcName) then
    table.insert(tbl, function() selfOrFunc[funcName](selfOrFunc) end)
  else
    table.insert(tbl, selfOrFunc)
  end

end

function LoadTracker:LoadScriptAfter(scriptPath, afterScriptPath, afterScriptSource)

	local normPath = NormalizePath(scriptPath)
	
	if(self.LoadedScripts[normPath]) then
		error("cannot set LoadScriptAfter for "..scriptPath.." because the file is already loaded")
	end

	local entry = afterScriptPath

	if(afterScriptSource) then
		entry = {afterScriptSource, afterScriptPath}
	end
	
	local loadAfterList = self.LoadAfterScripts[normPath] 
	
	if(not loadAfterList) then
	  loadAfterList = {}
	  self.LoadAfterScripts[normPath] = loadAfterList
	end
	
	 loadAfterList[#loadAfterList+1] = entry
end


function LoadTracker:SetFileOverride(tobeReplaced, overrider, overriderSource)
	
	local tobeNorm = NormalizePath(tobeReplaced)
	
	if(self.LoadedScripts[tobeNorm]) then
		error("cannot set file override for "..tobeReplaced.." because the file is already loaded")
	end
	
	if(self.OverridedFiles[tobeNorm]) then
		error(string.format("Cannot override %s because its already been overriden by %s", tobeReplaced, self.OverridedFiles[tobeReplaced]))
	end
	
	local entry = overrider
	
	if(overriderSource) then
		entry = {overriderSource, overrider}
	end
	
	self.OverridedFiles[tobeNorm] = entry
end

function LoadTracker:ScriptLoadFinished(normalizedsPath)

	--make sure that were not getting a nested double load of the same file
	if(self.LoadedScripts[normalizedsPath] == #self.LoadStack) then
		if(self.LoadedFileHooks[normalizedsPath]) then
			for _,hook in ipairs(self.LoadedFileHooks[normalizedsPath]) do
				hook()
			end
		end

		local LoadAfter = self.LoadAfterScripts[normalizedsPath]

		if(LoadAfter) then
		  for _,entry in ipairs(LoadAfter) do
				if(type(entry) ~= "table") then
		  	  Script.Load(entry)
	      else
		      RunScriptFromSource(entry[1], entry[2])
		    end
			end
    end
    
    if(ClassHooker) then
			ClassHooker:ScriptLoadFinished(normalizedsPath)
		end
		
		self.LoadedScripts[normalizedsPath] = true
	end

	table.remove(self.LoadStack)
end


function LoadTracker:SetFileInjection(targetfile, inject, class)

  if(not class or type(class) == "string") then
    self.InjectedFiles[targetfile] = {inject, nil, class}
  else
    
  end
end

function LoadTracker:CheckInject(className, mapname)
  local currentfile = LoadTracker.LoadStack[#self.LoadStack]
  
  local Injector = currentfile and self.InjectedFiles[currentfile]

  if(Injector and Injector[3] == className) then
    if(not Injector[2]) then
			Script.Load(Injector[1])
	  else
			RunScriptFromSource(Injector[2], Injector[1])
		end
  end
end

if(not HotReload) then
  
  --Hook Shared.LinkClassToMap so we know when we can insert any hooks for a class
  local OrginalLinkClassToMap = Shared.LinkClassToMap
  
  Shared.LinkClassToMap = function(...)
   
    local classname, entityname = ...
    
    --let the orignal function spit out an error if we don't have the correct args
    if(classname and entityname) then
      ///LoadTracker:CheckInject(...)
  	  ClassHooker:LinkClassToMap(...)
    end
  	
  	OrginalLinkClassToMap(...)
  end

end

function LoadTracker:GetCurrentLoadingFile()
	return self.LoadStack[#self.LoadStack]
end