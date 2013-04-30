//
//   Created by:   fsfod
//

local ForwardSlash, BackSlash = string.byte("/"), string.byte("\\")

function NormalizePath(luaFilePath)

	local path = string.gsub(luaFilePath, "\\", "/")
	path = path:lower()
	
	if(string.byte(path) == ForwardSlash) then
	 path =	path:sub(2)
	end

	return path
end

function JoinPaths(path1, path2)

	local firstChar = string.byte(path2) 
	
	if(path1 == "") then
	  return path2
	end
	
	if(firstChar == ForwardSlash or firstChar == BackSlash) then
		local lastChar = string.byte(path1, #path1)
		
		if(lastChar == ForwardSlash or lastChar == BackSlash) then
			return path1..string.sub(path2, 2)
		else
			return path1..path2
		end
	else
		local lastChar = string.byte(path1, #path1)
		
		if(lastChar == ForwardSlash or lastChar == BackSlash) then
			return path1..path2
		else
			return path1.."/"..path2
		end
	end
end

function GetFileNameWithoutExt(path)

	local index = string.find(path, "[%/%\\]([^.]*)$")
  local ext = string.find(path, "%.", -#path)


	if(index and ext) then
		if(index == #path or index+1 == #path or ext > index) then
		  return nil
		end

		return string.sub(path, index+1, ext-1)
	end

	return (ext and string.sub(path, 1, ext-1)) or nil
end

function GetFileNameFromPath(path)
	return string.match(path, "([^%/%\\]*)$") or path
end

function StripExtension(filename)
	return string.match(filename, "(.+)%.[^.]+$") or filename
end

function GetExtension(filename)
  return string.match(filename, "(%.[^.]*)$")
end

local function WriteStackTrace() 
	Shared.Message(debug.traceback())
end

function RunScriptFromSource(source, path)
	
	local ChunkOrError = source:LoadLuaFile(path)

	if(type(ChunkOrError) == "string") then
		Shared.Message(ChunkOrError)
	 return false
	end

	local success = xpcall(ChunkOrError, WriteStackTrace)

	return success
end

function FileExists(file)
  local matchingFiles = {}
  
  Shared.GetMatchingFileNames(file, false, matchingFiles)
  
  local lfile = file:lower()
  
  for _,path in ipairs(matchingFiles) do
    if(path:lower() == lfile) then
      return true
    end
  end
  
  return false
end