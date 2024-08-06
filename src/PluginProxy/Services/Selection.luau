--!strict

local Selection = {}

local Highlight = require(script.Parent.Parent.HighlightManager).new()
Highlight.OutlineColor = Color3.fromRGB(32, 110, 226)
Highlight.FillTransparency = 1

local SelectionChanged = Instance.new('BindableEvent')
Selection.SelectionChanged = SelectionChanged.Event

type Objects = {[number]: Instance}
local selectedObjects: Objects = {}

local function updateSelection(Changed: boolean)
    if not Changed then return end

    Highlight:SetTargets(selectedObjects)

    SelectionChanged:Fire()
end

function Selection:Get(): Objects
    return selectedObjects
end

function Selection:Set(selection: Objects)
    selectedObjects = selection
    updateSelection(true)
end

function Selection:Add(instancesToAdd: Objects)
    local Changed
    for _, Instance in instancesToAdd do
        if not table.find(selectedObjects, Instance) then
            Changed = true
            table.insert(selectedObjects, Instance)
        end
    end
    updateSelection(Changed)
end

function Selection:Remove(instancesToRemove: Objects)
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

return Selection