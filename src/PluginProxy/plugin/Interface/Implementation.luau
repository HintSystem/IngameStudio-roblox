--!strict

local Implementor = { private = {} }

local Implementation = {}
Implementation.__index = Implementor

local PluginInstanceList = require(script.Parent.PluginInstanceList)

type func = (...any) -> (...any)

type Implementation<Type> = typeof(setmetatable({} :: {
    InstanceList: PluginInstanceList.T<Type>,
    _cachedValues: { [string]: any },
    _functions: { [string]: any },
    _currentChangeThread: thread?
}, {} :: typeof({ __index = Implementor.private }) ))

export type internal<Type> = Implementation<Type>

type interfacedClass<Type> = {
    Interface: any,
    public: { ClassName: string } | any,
    new: (...any) -> Type
}

function Implementation.new<Type>(interfacedClass: interfacedClass<Type>)
    local internalSelf = setmetatable({
        InstanceList = PluginInstanceList.new() :: PluginInstanceList.T<Type>,
        _cachedValues = {},
        _functions = {},
        _currentChangeThread = nil
    }, { __index = Implementor.private }) :: Implementation<Type>

    interfacedClass.Interface = internalSelf 

    local public = {}

    --- Runs when anything in the list of metatables changes
    function public.ListChanged(classInstanceList: {[UID]: Type}) end

    --[=[
        @unreleased TODO: implement destruction

        Runs when a new instance/metatable of this type is created.
        Use this to create your component and do not forget to provide the destructor function.

        @return () -> () -- Must return a destructor function, which destroys the created instance
    ]=]
    function public.Created(classInstance: Type): () -> ()
        return function() end
    end

    --- Runs when the properties of a instance/metatable change
    function public.Changed(classInstance: Type) end

    local function bindFunc(funcName: string?, callback: func?)
        if not funcName then
            error(`Can not bind to this function as it is not part of the bindable functions for class interface '{interfacedClass.public.ClassName}'. Supported functions are: {public}`, 3)
        end 

        internalSelf._functions[funcName] = callback
        if not callback then return end
        
        local cache = internalSelf._cachedValues[funcName]
        if cache then callback(cache) end
    end

    local function findFunc(func): string?
        local funcName
        for Name, publicFunc in public :: {[string]: any} do
            if publicFunc == func then funcName = Name end
        end
        return funcName
    end

    local methods = {}

    --[=[
        Binds a function

        **Example**:
        ```lua
        Interface.Toolbar:Bind(Interface.Toolbar.ListChanged, function(toolbarList)
            print('The toolbar list changed', toolbarList)
        end)
        ```

        Also possible without this method:

        ```lua
        function Interface.Toolbar.ListChanged(toolbarList)
            print('The toolbar list changed', toolbarList)
        end
        ```
        
        @param functionToBind -- example function present in this interface (ListChanged, Created, Changed), can not be a string
        @param callback -- function to call when the event is triggered, all the parameters present in functionToBind will be passed to callback
    ]=]
    function methods:Bind<FunctionType>(functionToBind: FunctionType, callback: FunctionType)
        local funcName = findFunc(functionToBind)

        if type(callback) ~= 'function' then
            error(`Can not bind a callback which is not a function for class interface '{interfacedClass.public.ClassName}'`, 2)
        end

        bindFunc(funcName, callback)
    end

    --[=[
        Unbinds a function when you no longer want to track changes

        **Example**:
        ```lua
        Interface.Toolbar:Unbind(Interface.Toolbar.ListChanged)
        ```
        or
        ```lua
        Interface.Toolbar:Unbind('ListChanged')
        ```
    ]=]
    function methods:Unbind(functionToUnbind: string | func)
        local funcName
        if type(functionToUnbind) == 'function' then
            funcName = findFunc(functionToUnbind)
        else funcName = functionToUnbind end

        if funcName and public[funcName] then bindFunc(funcName, nil) end
    end

    return setmetatable(methods, {
        __index = public,
        __newindex = function(self, i, func)
            if not public[i] or type(func) ~= 'function' then return end

            bindFunc(i, func)
        end
    })
end

local function callImplementation(self, functionName: string, ...)
    local impl = self._functions[functionName]

    if impl then impl(...) end
    self._cachedValues[functionName] = ...
end

type UID = string | number

--- Called by an internal class to trigger a deferred ListChanged call, to reduce function spam
function Implementor.private.ListChanged<Type>(self: Implementation<Type>)
    if self._currentChangeThread then return end

	self._currentChangeThread = task.defer(function()
		callImplementation(self, 'ListChanged', self.InstanceList)
		self._currentChangeThread = nil
	end)
end

--- Called by an internal class to trigger the Created function in the interface, and add the metatable to PluginInstanceList
function Implementor.private.Created<Type>(self: Implementation<Type>, classInstance: Type, pluginUID: UID, instanceUID: UID)
    self.InstanceList:Set(pluginUID, instanceUID, classInstance)
    self:ListChanged()
end

--- Called by an internal class to trigger the Changed function in the interface
function Implementor.private.Changed<Type>(self: Implementation<Type>, classInstance: Type)
    self:ListChanged()
end

--- Runs the desctructor functions in the interface and removes metatable from PluginInstanceList
function Implementor.private.Destroy<Type>(self: Implementation<Type>, classInstance: Type, pluginUID: UID, instanceUID: UID)
    self.InstanceList:Set(pluginUID, instanceUID, nil)
    self:ListChanged()
end

return Implementation