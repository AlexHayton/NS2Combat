//
//   Created by:   fsfod
//
--[[
3 hook types:


Standard Pre:
  Are called before the orignal function is called
  any value they return will be ignored


---------------------------------------
Raw Hooks:
  Are processed first before Standard hooks
  Can Modify paramaters sent to the orignal function
  Must return the new parameters or the orignals if it did not change any e.g. function hook(objself, a1, a2 ,a3) return a1, a2 ,a3 end 
    the objself paramter doesnt have tobe returned
  
Post Hooks:
  called after Standard hooks and after the orignal function is called
  can get the return value that the orignal function returned with HookHandle:GetReturn

All Hook:
  Can set return value of the hook with HookHandle:SetReturn(retvalue)



TODO
need to have hook priorty/ordering system based on hooker id system
hooks can request ordering based on the id of other hookers i.e. before and after also we should throw an error if 2 tooks both request tobe before/after each other
be able to remove and reorder hooks without issue
]]--

local NormalHook = 0
local PostHook = 1
local RawHook = 2
local ReplaceHook = 3

HookType = {
  Normal = NormalHook,
  Post = PostHook,
  Raw = RawHook,
  Replace = ReplaceHook,
}

local HookNumToString = {
  [NormalHook] = "Normal",
  [PostHook] = "Post",
  [RawHook] = "Raw",
  [ReplaceHook] = "Replace",
}

PassHookHandle = 1
InstantHookFlag = 2
HookHasMultiReturns = 4

if(not FakeNil) then
  FakeNil = {}
end

local Original_Class

local HotReload = ClassHooker
local ReloadInprogress = false

if(not HotReload) then

ClassHooker = {
  ClassObjectToName = {},

  ChildClass = {Entity = {}},
  LinkedClass = {},
  
  ClassDeclaredCb = {},
  ClassFunctionHooks = {},
  
  LibaryHooks = {},
  FunctionHooks = {},
  
  SelfTableToId = {},
  
  FileNameToObject = {},
  CreatedIn = {},
  
  LuabindTables = {},
  
  MainLuaLoadingFinished = false,
  InstantHookLibs = {
    //["Client"] = true, 
    ["Server"] = true, 
    ["Shared"] = true
  }
}

  ClassHooker.Original_Class = _G.class
  
  _G.class = function(...) 
    return ClassHooker:Class_Hook(...)
  end
end

Script.Load("lua/DispatchBuilder.lua")

ClassHooker.ClassObjectToName[Entity] = "Entity"

local function EmptyFunction()
end

local HookHandleMT, HookHandleMT_PassHandle, SelfFuncHookHandleMT, SelfFuncHookHandleMT_PassHandle


--[1] is the hook function
--[2] is the self arg
--[3] is the global hook table for the hooked function
local HookHandleFunctions = {
  SetReturn = function(self, a1)
    self[3].ReturnValue = a1 or FakeNil
  end,

  GetReturn = function(self)
    
    if(self[3].ReturnValue == FakeNil) then
      return nil
    end
    
    return self[3].ReturnValue 
  end,
  
  SetReturnMulti = function(self, ...)
    self[3].ReturnValue = {...}
  end,

  GetReturnMulti = function(self)
    if(self[3].ReturnValue) then
      return unpack(self[3].ReturnValue)
    end
  end,
  
  SetPassHandle = function(self, passHandle)
   local CurrentMT = getmetatable(self)
   local newMT

    if(passHandle) then
      if(CurrentMT == SelfFuncHookHandleMT) then
        newMT = SelfFuncHookHandleMT_PassHandle
      elseif(CurrentMT == HookHandleMT) then
        newMT = HookHandleMT_PassHandle
      end
    else
      if(CurrentMT == SelfFuncHookHandleMT_PassHandle) then
        newMT = SelfFuncHookHandleMT
      elseif(CurrentMT == HookHandleMT_PassHandle) then
        newMT = HookHandleMT
      end
    end
    
    if(newMT) then
      setmetatable(self, newMT)
    end
    
    return self
  end,
  
  BlockOrignalCall = function(self, continuousBlock)
    
    local hookData = self[3]

    if(not continuousBlock) then
      if(not hookData.CachedOrignalReset) then
        hookData.CachedOrignalReset = function() hookData.Orignal = hookData.ReplacedOrignal or hookData.RealOrignal end
      end

      hookData.Orignal = hookData.CachedOrignalReset
    else
      hookData.Orignal = EmptyFunction
      hookData.ContinuousBlockOrignal = true
    end
    
    return self
  end,

  EnableCallOrignal = function(self)
    local hookData = self[3]
    hookData.ContinuousBlockOrignal = false
    hookData.Orignal = hookData.ReplacedOrignal or hookData.RealOrignal
  end,

  IsBlockCallOrignalActive = function(self)
    return not self[3].RealOrignal or self[3].Orignal ~= self[3].RealOrignal
  end,
}

HookHandleMT = {
  __call = function(self, ...)
    return self[1](...)
  end,
  __index = HookHandleFunctions,
}

HookHandleMT_PassHandle = {
  __call = function(self, ...)
    return self[1](self, ...)
  end,

  __index = HookHandleFunctions,
}

SelfFuncHookHandleMT = {
  __call = function(self, ...)
    return self[1](self[2], ...)
  end,
  __index = HookHandleFunctions
}

SelfFuncHookHandleMT_PassHandle = {
  __call = function(self, ...)
    return self[1](self[2], self, ...)
  end,
  
  __index = HookHandleFunctions,
}

if(HotReload) then
  HookHandleMT, HookHandleMT_PassHandle, SelfFuncHookHandleMT, SelfFuncHookHandleMT_PassHandle = unpack(ClassHooker.HandleFuncs)
else
  ClassHooker.HandleFuncs = {HookHandleMT, HookHandleMT_PassHandle, SelfFuncHookHandleMT, SelfFuncHookHandleMT_PassHandle}
end

function ClassHooker:GetLuabindTables(class)
  
  local classtbl = self.LuabindTables[class]
  
  if(not classtbl) then
    classtbl = _G[class]
    
    if(not static) then
      error("Couldn't get class tables for "..class)
    end

    self.LuabindTables[class] = classtbl
  end
  
  return classtbl
end

function ClassHooker:PropergateHookToSubClass(class, funcName, hook, oldFunc)

  local classtbl = _G[class]
    
  if(not classtbl) then
    error(string.format("ClassHooker:PropergateHookToSubClass class %s no longer seems to exist", class))
  end
 
  local static = classtbl[funcName]

  if(not static) then
    error(string.format("ClassHooker:PropergateHookToSubClass class %s no longer has a function called %s", class, funcName))
  end

  if(static == oldFunc) then
    classtbl[funcName] = hook
  end

  if(self.ChildClass[class]) then
    for _,name in pairs(self.ChildClass[class]) do
      self:PropergateHookToSubClass(name, funcName, hook, oldFunc)
    end
  end
end

local function CheckSetOrignal(hookData, OrignalFunction)
  
  --don't write to Orignal if a hook has called BlockOrignalCall already which changes Orignal to an empty funtion
  if(not hookData.Orignal) then
    hookData.Orignal = OrignalFunction
  end

  if(not ReloadInprogress) then
    --we have this so we have a second copy for when a hook disable calling the orignal by replacing Orignal with a dummy function through BlockCallOr
    hookData.RealOrignal = OrignalFunction
   return
  end
  
  //update hookData.Orignal if its not set to a replacer or blocker hook function
  if(hookData.Orignal == hookData.RealOrignal) then
    hookData.Orignal = OrignalFunction
  end
  
  hookData.RealOrignal = OrignalFunction

  if(hookData.ReplacedOrignal) then
   // hookData.ReplacedOrignal = OrignalFunction
  end
end

function ClassHooker:RuntimeHookClass(className, funcname, hookData)
  
  local classTable = _G[className]

  local OrignalFunction = classTable[funcname]
  
  if(not OrignalFunction) then
    error(string.format("ClassHooker:RuntimeHookClass function \"%s\" in class %s does not exist", funcname, class))
  end
  
  --don't write to Orignal if a hook has called BlockOrignalCall already which changes Orignal to an empty funtion
  CheckSetOrignal(hookData, OrignalFunction)
  
  hookData.Class = className
  hookData.Name = funcname

  hookData.Dispatcher  = DispatchBuilder:CreateDispatcher(hookData, true)
  
  self:PropergateHookToSubClass(className, funcname, hookData.Dispatcher, OrignalFunction)
end

function ClassHooker:CreateAndSetHook(hookData, funcname)

  local Container = _G
  
  if(hookData.Library) then
    Container = _G[hookData.Library]
    
    if(not Container) then
      error(string.format("Library \"%s\" does not exist%s", hookData.Library))
    end
  end
  
  local OrignalFunction = Container[funcname]
  
  if(not OrignalFunction) then
    error(string.format("function \"%s\" does not exist%s", funcname, (hookData.Library and "in library ") or ""))
  end
  
  //we do allow the crazy edge case of table with a call __call operator but not userdata because it could be a class
  if(type(OrignalFunction) ~= "function" and (type(OrignalFunction) ~= "table" or getmetable(OrignalFunction).__call == nil)) then
    error(string.format("function \"%s\"%s is not valid hook target because its not a function", funcname, (hookData.Library and (" in library "..hookData.Library)) or ""))
  end

  --don't write to Orignal if a hook has called BlockOrignalCall already which changes Orignal to an empty funtion
  CheckSetOrignal(hookData, OrignalFunction)

  hookData.Dispatcher  = DispatchBuilder:CreateDispatcher(hookData)
  hookData.Name = funcname
  
  Container[funcname] = hookData.Dispatcher
end

function ClassHooker:CreateAndSetClassHook(hookData, class, funcname)

  local OrignalFunction = _G[class][funcname]
  
  if(not OrignalFunction) then
    error(string.format("ClassHooker:CreateAndSetClassHook function \"%s\" in class %s does not exist", funcname, class))
  end
  
  if(hookData.Dispatcher == OrignalFunction) then
    OrignalFunction = hookData.RealOrignal
  end

  CheckSetOrignal(hookData, OrignalFunction)

  hookData.Dispatcher = DispatchBuilder:CreateDispatcher(hookData, true)

  _G[class][funcname] = hookData.Dispatcher
end

local function CheckCreateHookTable(hookTable, functionName, hookType)

  if(not hookTable[functionName]) then
    hookTable[functionName] = {Name = functionName}
  end
  
  hookTable = hookTable[functionName]
  
  if(hookType) then
    if(hookType == RawHook) then
      if(not hookTable.Raw) then
        hookTable.Raw = {}
      end
    elseif(hookType == PostHook) then
      if(not hookTable.Post) then
        hookTable.Post = {}
      end
    end
  end
  
  return hookTable
end

function ClassHooker:CheckCreateClassHookTable(classname, functioname, hookType)
  local hookTable = self.ClassFunctionHooks[classname]

  if(not hookTable) then
    hookTable = {}
    self.ClassFunctionHooks[classname] = hookTable
  end

  local tbl = CheckCreateHookTable(hookTable, functioname, hookType)

  tbl.Class = classname

  return tbl
end

--args classname functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:RawHookClassFunction(classname, ...)
  return self:HookClassFunctionType(RawHook, ...)
end

--args classname functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:HookClassFunction(...)
  return self:HookClassFunctionType(NormalHook, ...)
end

--args classname functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:ReplaceClassFunction(...)
  return self:HookClassFunctionType(ReplaceHook, ...)
end

--args classname functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:PostHookClassFunction(...)
  return self:HookClassFunctionType(PostHook, ...)
end

--args functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:RawHookFunction(...)
  if(type(select(2, ...)) == "string") then
    return self:HookLibraryFunctionType(RawHook, ...)
  else
    return self:HookFunctionType(RawHook, ...)
  end
end

--args  functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:HookFunction(...)
  if(type(select(2, ...)) == "string") then
    return self:HookLibraryFunctionType(NormalHook, ...)
  else
    return self:HookFunctionType(NormalHook, ...)
  end
end

--args functioName, FuncOrSelf, [callbackFuncName]
function ClassHooker:PostHookFunction(...)
  if(type(select(2, ...)) == "string") then
    return self:HookLibraryFunctionType(PostHook, ...)
  else
    return self:HookFunctionType(PostHook, ...)
  end
end

local function CreateHookEntry(hookType, HookData, FuncOrSelf, callbackFuncName)
  
  local hookTable = HookData
  
  if(hookType == RawHook) then
    hookTable = HookData.Raw
  elseif(hookType == PostHook) then
    hookTable = HookData.Post
  end

  local handle

  if(type(FuncOrSelf) == "function") then
    handle = setmetatable({FuncOrSelf, nil, HookData}, HookHandleMT)
  else
    handle = setmetatable({FuncOrSelf[callbackFuncName], FuncOrSelf, HookData}, SelfFuncHookHandleMT)
  end
  
  if(hookType ~= ReplaceHook) then
    table.insert(hookTable, handle)
  else
    if(hookTable.Orignal) then
      if(hookTable.ReplacedOrignal) then
        --could make the second replace a normal hook with a wrapper around to it catch the return value and translate it to a SetReturn
        error("Cannot have 2 replace hooks")
      end
    end

    hookTable.Orignal = handle
    hookTable.ReplacedOrignal = handle
  end

  return handle
end

function ClassHooker:ProcessHookEntryFlags(handle, flags)

  if(flags) then
    if(bit.band(flags, PassHookHandle) ~= 0) then
      handle:SetPassHandle(true)
    end
    
    if(bit.band(flags, HookHasMultiReturns) ~= 0) then
      handle[3].MultiReturn = true
    end
    
    if(bit.band(flags, InstantHookFlag) ~= 0) then
      return true
    end
  end
  
  return false
end


//if the library is either Shared, Client or Server then hook will instantly be set
function ClassHooker:HookLibraryFunctionType(hookType, libName, functionName, FuncOrSelf, callbackFuncName, flags)

  local LibHookList = self.LibaryHooks[libName]
  
  if(not LibHookList) then
    LibHookList = {}
    self.LibaryHooks[libName] = LibHookList
  end

  local HookData = LibHookList[functionName]
  
  if(not HookData) then
    HookData = {Library = libName, Name = functionName}
    LibHookList[functionName] = HookData
  end
  
  if(hookType == RawHook) then
    if(not HookData.Raw) then
      HookData.Raw = {}
    end
  elseif(hookType == PostHook) then
    if(not HookData.Post) then
      HookData.Post = {}
    end
  end

  local handle = CreateHookEntry(hookType, HookData, FuncOrSelf, callbackFuncName or functionName)

  if(self:ProcessHookEntryFlags(handle, flags) or self.MainLuaLoadingFinished or self.InstantHookLibs[libName]) then

    if(HookData.Dispatcher) then
      self:UpdateDispatcher(HookData)
    else
      self:CreateAndSetHook(HookData, functionName)
    end
  end
  
  return handle
end

function ClassHooker:HookFunctionType(hookType, functionName, FuncOrSelf, callbackFuncName, flags)
  
  local HookData = CheckCreateHookTable(self.FunctionHooks, functionName, hookType)
    
  local handle = CreateHookEntry(hookType, HookData, FuncOrSelf, callbackFuncName or functionName, flags)
  
  local shouldSetHook = self:ProcessHookEntryFlags(handle, flags) or self.MainLuaLoadingFinished
  
  if(shouldSetHook) then
    if(HookData.Dispatcher) then
      self:UpdateDispatcher(HookData)
    else
      self:CreateAndSetHook(HookData, functionName)
    end
  end
  
  return handle
end

function ClassHooker:IsClassHookSet(classname, functionName)
  
  local hook = self.ClassFunctionHooks[classname] and self.ClassFunctionHooks[classname][functionName]

  return (hook and hook.Dispatcher ~= nil) or false
end

function ClassHooker:HookClassFunctionType(hookType, classname, functioName, FuncOrSelf, callbackFuncName, flags)

  local HookData = self:CheckCreateClassHookTable(classname, functioName, hookType)

  local handle = CreateHookEntry(hookType, HookData, FuncOrSelf, callbackFuncName or functionName)
  
  local shouldSetHook = self:ProcessHookEntryFlags(handle, flags) or self.MainLuaLoadingFinished
  
  if(shouldSetHook) then
    if self:IsClassHookSet(classname, functioName) then
      self:UpdateDispatcher(HookData)
    else
      self:RuntimeHookClass(classname, functioName, HookData)
    end
  end
  
  return handle
end

local function CheckRemoveHook(t, hook)
  
  if(not t) then
    return false
  end
  
  for i,entry in ipairs(t) do
    if(hook == entry) then
        table.remove(t, i)
      return true
    end
  end
  
  return false
end

--not the fastest but hook removal will not happen often
function ClassHooker:RemoveHook(hook)

  local hookData = hook[3]

  if(not CheckRemoveHook(hookData, hook)) then
    if(CheckRemoveHook(hookData.Post, hook)) then
      if(#hookData.Post == 0) then
        hookData.Post = nil
      end
    elseif(CheckRemoveHook(hookData.Raw, hook)) then
      if(#hookData.Raw == 0) then
        hookData.Raw = nil
      end
    else
      --need to figure out how to handle BlockOrignals interaction here
      if(hookData.ReplacedOrignal == hook) then
        hookData.Orignal = hookData.RealOrignal
        hookData.ReplacedOrignal = nil
      else
        return false
      end
    end
  end

  self:UpdateDispatcher(hookData)

  if(not hookData.Dispatcher) then
    if(hookData.Class) then
      self.ClassFunctionHooks[hookData.Class][hookData.Name] = nil
    elseif(hookData.Library) then
      self.LibaryHooks[hookData.Library][hookData.Name] = nil
    else
      self.FunctionHooks[hookData.Name] = nil
    end
  end

  return true
end

function ClassHooker:UpdateDispatcher(hookData)
   
  if(not hookData.Dispatcher) then
   return
  end
   
  local newDispatcher = DispatchBuilder:CreateDispatcher(hookData) or hookData.RealOrignal

  local FunctionName = hookData.Name 

  assert(FunctionName)

  if(hookData.Class) then
    local classtbl = _G[hookData.Class]
    
    if(not classtbl) then
      error(string.format("ClassHooker:UpdateDispatcher class %s no longer seems to exist", hookData.Class))
    end
    
    local static = classtbl[FunctionName]

    if(not static) then
      error(string.format("ClassHooker:UpdateDispatcher class %s no longer has a function called %s", hookData.Class, FunctionName))
    end

    if(not static == hookData.RealOrignal and static ~= hookData.Dispatcher) then
      error(string.format("ClassHooker:UpdateDispatcher current hook dispatcher for class %s was not the expected value", hookData.Class))
    end

    self:PropergateHookToSubClass(hookData.Class, FunctionName, newDispatcher, hookData.Dispatcher)
  else
    local containerTable = (hookData.Library and _G[hookData.Library]) or _G

    if(containerTable[hookData.Name] ~= hookData.Dispatcher) then
      if(hookData.Library) then
        error(string.format("ClassHooker:UpdateDispatcher current hook dispatcher for library function %s was not the expected value", FunctionName))
      else
        error(string.format("ClassHooker:UpdateDispatcher current hook dispatcher for function %s was not the expected value", FunctionName))
      end
    end

    containerTable[hookData.Name] = newDispatcher
  end
  
  if(newDispatcher ~= hookData.RealOrignal) then
    hookData.Dispatcher = newDispatcher
  else
    hookData.Dispatcher = nil
  end
end

function ClassHooker:ClassDeclaredCallback(classname, FuncOrSelf, callbackFuncName)

  if(self:IsUnsafeToModify(classname)) then
    error(string.format("ClassHooker:ClassDeclaredCallback '%s' has already been defined",classname))
  end

  if(not self.ClassDeclaredCb[classname]) then
    self.ClassDeclaredCb[classname] = {}
  end

  if(callbackFuncName) then
    table.insert(self.ClassDeclaredCb[classname],  {FuncOrSelf, FuncOrThis[callbackFuncName]})
  else
    table.insert(self.ClassDeclaredCb[classname], FuncOrSelf)
  end
end

function ClassHooker:IsUnsafeToModify(classname)
  return self.LinkedClass[classname] and #self.ChildClass[classname] ~= 0
end

function ClassHooker:ClassStage2_Hook(classname, baseClassObject)
  
  if(baseClassObject) then
    local BaseClass = self.ClassObjectToName[baseClassObject]
    
    if(not baseClassObject) then
      --just let luabind spit out an error
      return
    end
    
    table.insert(self.ChildClass[BaseClass], classname)
  end
end


function ClassHooker:Class_Hook(classname)
  
  local stage2 = self.Original_Class(classname)
    
  local mt = getmetatable(_G[classname])

  if(not self.ChildClass[classname]) then
    self.ChildClass[classname] = {}
  end
  
  self.ClassObjectToName[ _G[classname]] = classname
  

  return   function(classObject) 
            stage2(classObject)
            ClassHooker:ClassStage2_Hook(classname, classObject)
          end
end

function ClassHooker:LinkClassToMap(classname, entityname, networkVars)

  if(entityname) then
    self.LinkedClass[classname] = true
  end
  
  self:OnClassFullyDefined(classname, networkVars)
end

function ClassHooker:ScriptLoadFinished(scriptPath)
  
  local objectlist = self.FileNameToObject[scriptPath]
  
  if(objectlist) then
    for _,ObjectName in ipairs(objectlist) do

      if(self.ClassFunctionHooks[ObjectName]) then
        if(not self.LinkedClass[ObjectName]) then
          self:OnClassFullyDefined(ObjectName)
        end
      else
        -- just sanity check that there are any hooks set
        if(self.LibaryHooks[ObjectName]) then
          for funcName,hooktbl in pairs(self.LibaryHooks[ObjectName]) do
            self:CreateAndSetHook(hooktbl, funcName)
          end
        end
      end

    end
  end
end

function ClassHooker:SetClassCreatedIn(class, luafile)
  
  if(not luafile) then
    luafile = "lua/"..class..".lua"
  end
  
  local path = LoadTracker.NormalizePath(luafile)
  //
  if(self.CreatedIn[class]) then
    if(self.CreatedIn[class] ~= path) then
      error(string.format("ClassHooker:SetClassCreatedIn 2 diffent paths have been set for the same class(%s) %s and %s", class, self.CreatedIn[class], path))
    end
   return
  end
  
  if(not self.FileNameToObject[path]) then
    self.FileNameToObject[path] = {class}
  else
    table.insert(self.FileNameToObject[path], class)
  end
  
  self.CreatedIn[class] = path
end
  
function ClassHooker:OnClassFullyDefined(classname, networkVars)
  local ClassDeclaredCb = self.ClassDeclaredCb[classname]
  
  if(ClassDeclaredCb) then
    for _,hook in ipairs(ClassDeclaredCb) do
      if(type(hook) == "table") then
        hook[1](hook[2], classname, networkVars)
      else
        hook(classname, networkVars)
      end
    end
  end
  
  if(self.ClassFunctionHooks[classname]) then
    --Create and insert all the hooks registered for this class
    for funcName,hooktbl in pairs(self.ClassFunctionHooks[classname]) do
      self:CreateAndSetClassHook(hooktbl, classname, funcName)
    end
  end
end

function ClassHooker:OnLuaFullyLoaded()
  
  self.MainLuaLoadingFinished = true
  
  if(ReloadInprogress) then
    self:LuaReloadComplete()
   return
  end
  
  for funcName,hooktbl in pairs(self.FunctionHooks) do
    if(_G[funcName]) then
      self:CreateAndSetHook(hooktbl, funcName)
    else
      RawPrint("ClassHooker: Skipping hook for function \"%s\" because it cannot be found", funcName)
    end
  end
end

function ClassHooker:LuaReloadStarted()
  ReloadInprogress = true
  self.MainLuaLoadingFinished = false
  self.LinkedClass = {}
end

function ClassHooker:LuaReloadComplete()
  
  ReloadInprogress = false
  
  self.MainLuaLoadingFinished = true

  for funcName,hooktbl in pairs(self.FunctionHooks) do
    if(_G[funcName]) then
      local success, msg = pcall(self.CreateAndSetHook, self, hooktbl, funcName, true)

      if(not success) then
        RawPrint("ClassHooker: Failed to reapply hook ", msg)
      end
    else
      RawPrint("ClassHooker: Skipped reapplying hook for function \"%s\" because it cannot be found", funcName)
    end
  end
end

function ClassHooker:ClientLoadComplete()

  self.InstantHookLibs["Client"] = true

  if(not self.LibaryHooks["Client"]) then
    return
  end

  //check for any unset client hooks now that the client library is fully loaded
  for funcName,hooktbl in pairs(self.LibaryHooks["Client"]) do
    if(not hooktbl.Dispatcher) then
      self:CreateAndSetHook(hooktbl, funcName)
    end
  end
end

local function Mixin_HookClassFunctionType(self, hooktype, classname, funcName, callbackFuncName, ...)
  
  --default to the to using a function with the same name as the hooked funcion
  if(not callbackFuncName) then
    callbackFuncName = funcName
  end

  local handle

  if(not self.ClassHooker_NoSelfCall and type(callbackFuncName) == "string") then
    if(not self[callbackFuncName]) then
      error(string.format("ClassHooker:HookClassFunctionType hook callback function \"%s\" does not exist", callbackFuncName))
    end
    
    handle = ClassHooker:HookClassFunctionType(hooktype, classname, funcName, self, callbackFuncName, ...)
  else
    handle = ClassHooker:HookClassFunctionType(hooktype, classname, funcName, callbackFuncName, nil, ...)
    
    handle[2] = self
  end

  table.insert(self.ClassHooker_Hooks, handle)

  return handle
end

local function Mixin_HookFunctionType(self, hooktype, funcName, callbackFuncName, ...)
  
  --default to the to using a function with the same name as the hooked funcion
  if(not callbackFuncName) then
    callbackFuncName = funcName
  end

  local handle
  
  if(not self.ClassHooker_NoSelfCall and type(callbackFuncName) == "string") then
    if(not self[callbackFuncName]) then
      error(string.format("ClassHooker:HookFunctionType hook callback function \"%s\" does not exist", callbackFuncName))
    end
    
    handle = ClassHooker:HookFunctionType(hooktype, funcName, self, callbackFuncName, ...)
  else
    handle = ClassHooker:HookFunctionType(hooktype, funcName, callbackFuncName, nil, ...)
    handle[2] = self
  end

  table.insert(self.ClassHooker_Hooks, handle)

  return handle
end

local function Mixin_HookLibraryFunction(self, hooktype, libName, funcName, callbackFuncName, ...)
  
  --default to the to using a function with the same name as the hooked funcion
  if(not callbackFuncName) then
    callbackFuncName = funcName
  end
  
  local handle
  
  if(type(callbackFuncName) == "string") then
    if(not self[callbackFuncName]) then
      error(string.format("ClassHooker:HookLibraryFunction hook callback function \"%s\" does not exist", callbackFuncName))
    end

    handle = ClassHooker:HookLibraryFunctionType(hooktype, libName, funcName, self, callbackFuncName, ...)
  else
    handle = ClassHooker:HookLibraryFunctionType(hooktype, libName, funcName, callbackFuncName, nil, ...)
    handle[2] = self
  end

  table.insert(self.ClassHooker_Hooks, handle)

  return handle
end

local MixInList = {
  
  HookLibraryFunction = Mixin_HookLibraryFunction,
  
  HookClassFunction = function (self, ...)
    return Mixin_HookClassFunctionType(self, NormalHook, ...)
  end,

  RawHookClassFunction = function (self, ...)
    return Mixin_HookClassFunctionType(self, RawHook, ...)
  end,

  PostHookClassFunction = function (self, ...)
    return Mixin_HookClassFunctionType(self, PostHook, ...)
  end,

  ReplaceClassFunction = function (self, ...)
    return Mixin_HookClassFunctionType(self, ReplaceHook, ...)
  end,
  
  HookFunction = function (self, ...)
    return Mixin_HookFunctionType(self, NormalHook, ...)
  end,
  
  RawHookFunction = function (self, ...)
    return Mixin_HookFunctionType(self, RawHook, ...)
  end,

  PostHookFunction = function (self, ...)
    return Mixin_HookFunctionType(self, PostHook, ...)
  end,

  ReplaceFunction = function (self, ...)
    return Mixin_HookFunctionType(self, ReplaceHook, ...)
  end,
  
  RemoveAllHooks = function(self)
    for _,hook in ipairs(self.ClassHooker_Hooks) do
      ClassHooker:RemoveHook(hook)
    end
    
    self.ClassHooker_Hooks = {}
  end
}

function ClassHooker:Mixin(classTableOrName, IdString, noSelfCall)

  if(not IdString) then
    
    if(type(classTableOrName) == "string") then
      if(not _G[classTableOrName]) then
        error("ClassHooker:Mixin No gobal table named "..classTableOrName)
      end
      
      classTableOrName = _G[classTableOrName]
      IdString = classTableOrName
    else
      error("ClassHooker:Mixin A Id string must be passed to the function")
    end
  end

  if(classTableOrName.ClassHooker_Hooks) then
    RawPrint("either hot loading or double call to ClassHooker:Mixin detected removing all hooks set")
      classTableOrName:RemoveAllHooks()
    return true
  end

  self.SelfTableToId[classTableOrName] = IdString
  
  classTableOrName.ClassHooker_NoSelfCall = noSelfCall
  
  classTableOrName.ClassHooker_Hooks = {}
  
  for name,func in pairs(MixInList) do
    classTableOrName[name] = func
  end
end


if(not HotReload) then
  --Hook Shared.LinkClassToMap so we know when we can insert any hooks for a class
  local OrginalLinkClassToMap = Shared.LinkClassToMap
  
  Shared.LinkClassToMap = function(...)
   
    local classname, entityname = ...
    
    --let the orignal function spit out an error if we don't have the correct args
    if(classname and entityname) then
      ClassHooker:LinkClassToMap(...)
    end
    
    OrginalLinkClassToMap(...)
  end

else
  ClassHooker:LuaReloadStarted()
end