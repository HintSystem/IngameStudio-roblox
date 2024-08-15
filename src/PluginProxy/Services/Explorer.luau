local Explorer = {}

local ReflectionService = require(script.Parent.ReflectionService)

local SharedView = {
    Workspace = true,
    Players = true,
    Lighting = true,
    MaterialService = true,
    ReplicatedFirst = true,
    ReplicatedStorage = true,
    StarterGui = true,
    StarterPack = true,
    StarterPlayer = true,
    Teams = true,
    SoundService = true,
    Chat = true,
    TextChatService = true
}

local ServerView = {
    ServerScriptService = true,
    ServerStorage = true,
}

local ClientView = {
    CoreGui = true,
    PluginGuiService = true,
    RobloxPluginGuiService = true,
}

--- Gets the current root, could be a DataModel from server / client
function Explorer.GetRoot()
    return game
end

local function getOrder(Object: Instance)
    local meta = ReflectionService:GetMetadata(Object.ClassName)
    local order = meta and meta.ExplorerOrder

    if not order then return -1 end
    return order
end

--- If no parent is specified, then gets the objects from GetRoot / DataModel
function Explorer.GetSortedObjectList(parent: Instance?)
    local Parent = parent or Explorer.GetRoot()

    local ObjectList
    if Parent.ClassName == "DataModel" then
        ObjectList = {}
        for _, Object in Parent:GetChildren() do
            if SharedView[Object.ClassName] or ClientView[Object.ClassName] then
                table.insert(ObjectList, Object)
            end
        end
    else
        ObjectList = Parent:GetChildren()
    end

    table.sort(ObjectList, function(a, b)
        local aOrder = getOrder(a)
        local bOrder = getOrder(b)

        if aOrder == bOrder and a.ClassName ~= b.ClassName then
            return a.Name < b.Name
        end

        return aOrder < bOrder
    end)

    return ObjectList
end

return Explorer