--!strict

--[=[
    An iterator that loops through all the values inside of the table instead of the table itself.
    Only works on tables with 1 level of nesting, does not descend to last level.

    **Example**:
    ```lua
    t1 = { y = { 70,1,4 }, x = { 5,7,9 } }
    t2 = { 70,1,4,5,7,9 }
    ```
    t1 is looped through as if it was t2

    @param useCounter -- Set to true if index should be a counter that goes from 1 to total element count
]=]
local function nestedNext(useCounter: boolean?)
    local prevParent = nil
    local prevChild = nil
    local count = 0

    local nextFunc
    nextFunc = function (t): (any?, any?)
        local parent, parentValue = next(t, prevParent)
        if parent == nil then return nil, nil end
        
        local child, childValue = next(parentValue, prevChild)
        
        if child == nil then
            prevParent = parent
            prevChild = nil
            return nextFunc(t)
        end
        
        prevChild = child
        count += 1
        
        return useCounter and count or child, childValue
    end
    return nextFunc
end

--[=[
    @class PluginInstanceList

    A table of Plugin UIDs and their associated, globally stored instances/metatables
]=]
local PluginInstanceList = { public = {} }

type UID = string | number

function PluginInstanceList.new()
    return setmetatable({}, {
        __index = PluginInstanceList.public,
        __iter = function(self)
            return nestedNext(false), self
        end,
        __len = function(self)
            local count = 0
            for _, pluginId in self do
                for _, instance in pluginId do
                     count += 1
                end
            end
            return count
        end
    })
end

function PluginInstanceList.public.Get<Type>(self: InstanceList<Type>, pluginUID: UID, instanceUID: UID): Type?
    local pluginList = self[pluginUID]
    if not pluginList then return nil end
    
    return pluginList[instanceUID]
end

function PluginInstanceList.public.Set<Type>(self: InstanceList<Type>, pluginUID: UID, instanceUID: UID, value: Type)
    if not self[pluginUID] then
        self[pluginUID] = {}
    end

    self[pluginUID][instanceUID] = value
end

type InstanceList<Type> = typeof(setmetatable({}, {} :: { __index: typeof(PluginInstanceList.public) }))

export type T<Type> = InstanceList<Type>

return PluginInstanceList