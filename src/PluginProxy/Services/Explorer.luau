local Explorer = {}

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

--- If no parent is specified, then gets the objects from DataModel
function Explorer.GetSortedObjectList(parent: Instance?, filterDataModel: boolean?)
    if filterDataModel == nil then filterDataModel = true end
    local Parent = parent or game

    local ObjectList
    if filterDataModel then
        ObjectList = {}
        for _, Object in Parent:GetChildren() do
            if SharedView[Object.ClassName] or ClientView[Object.ClassName] then
                table.insert(ObjectList, Object)
            end
        end
    else
        ObjectList = Parent:GetChildren()
    end

    return ObjectList
end

return Explorer