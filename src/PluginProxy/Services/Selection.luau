--!strict

local Selection = {}

local Highlight = require(script.Parent.Parent.HighlightManager).new()
Highlight.OutlineColor = Color3.fromRGB(32, 110, 226)
Highlight.FillTransparency = 1

local SelectionChanged = Instance.new('BindableEvent')
Selection.SelectionChanged = SelectionChanged.Event

export type ObjectId = Instance -- might want to use some other kind of id for replication in the future

local selectedObjects = {} :: {Instance}

local objectIds = {} :: {[ObjectId]: boolean}
local addedObjects = {}
local removedObjects = {}

local function updateSelection(Changed: boolean)
    if not Changed then return end
    table.clear(addedObjects)
    table.clear(removedObjects)

    local newObjectIds = {}
    for _, obj: ObjectId in selectedObjects do
        local id = obj
        newObjectIds[id] = true
        if not objectIds[id] then
            table.insert(addedObjects, id)
        end
    end

    for obj in objectIds do
        if not newObjectIds[obj] then
            table.insert(removedObjects, obj)
        end
    end

    objectIds = newObjectIds

    Highlight:SetTargets(selectedObjects)
    SelectionChanged:Fire()
end

function Selection:Get(): {Instance}
    return selectedObjects
end

--- Given a id, returns whether it is selected or not
function Selection:IsSelected(instanceId: ObjectId)
    return objectIds[instanceId] or false
end

--- Gets all instances that were added to Selection since last SelectionChanged event
function Selection:GetAdded()
    return addedObjects
end

--- Gets all instances that were removed from Selection since last SelectionChanged event
function Selection:GetRemoved()
    return removedObjects
end

function Selection:Set(selection: {Instance})
    selectedObjects = selection
    updateSelection(true)
end

function Selection:Add(instancesToAdd: {Instance})
    local Changed
    for _, Instance in instancesToAdd do
        if not table.find(selectedObjects, Instance) then
            Changed = true
            table.insert(selectedObjects, Instance)
        end
    end
    updateSelection(Changed)
end

function Selection:Remove(instancesToRemove: {Instance})
    local Changed
    for _, Instance in instancesToRemove do
        local index = table.find(selectedObjects, Instance)
        if index then
            Changed = true
            table.remove(selectedObjects, index)
        end
    end
    updateSelection(Changed)
end

local selectCallbacks = {}
local selectionEvent
local function connectSelection()
    selectionEvent = Selection.SelectionChanged:Connect(function()
        for _, id in Selection:GetAdded() do
            local callback = selectCallbacks[id]
            if callback then
                callback(true)
            end
        end
    
        for _, id in Selection:GetRemoved() do
            local callback = selectCallbacks[id]
            if callback then
                callback(false)
            end
        end
    end)
end

--- Runs callback whenever the instance is selected / deselected
--- @return function -- Destructor
function Selection.onSelectionChanged(instanceId: ObjectId, callback: (selected: boolean) -> ())
    if not selectionEvent or not selectionEvent.Connected then connectSelection() end

    selectCallbacks[instanceId] = callback
    
    return function()
        selectCallbacks[instanceId] = nil

        if next(selectCallbacks) == nil then
            selectionEvent:Disconnect()
        end
    end
end

return Selection