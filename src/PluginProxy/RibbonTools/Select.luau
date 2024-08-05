local RibbonTool = require(script.Parent.Type)

local Select = {} :: RibbonTool.T

local HighlightManager = require(script.Parent.Parent.HighlightManager)
local Selection = require(script.Parent.Parent.Services.Selection)

local function FindLastAncestorOfClass(instance: Instance?, className: string)
    if not instance then return nil end

    local lastInstance = instance
    while true do
        local found = lastInstance:FindFirstAncestorOfClass(className)
        if not found then return lastInstance end

        lastInstance = found
    end
end

local mouseTarget = nil -- The last target that was hovered by mouse
local currentTarget = nil -- The last indirectTarget, could be a part or a model

function Select.Clicked(input)
    if input:IsModifierKeyDown(Enum.ModifierKey.Shift) then
        Selection:Add({currentTarget})
        return
    end

    Selection:Set({currentTarget})
end

function Select.Deselected()
    HighlightManager.Hover:SetTargets({})
end

function Select.MouseTargetChanged(target, input)
    mouseTarget = target

    -- Holding alt selects parts instead of models
    local indirectTarget
    if not input:IsModifierKeyDown(Enum.ModifierKey.Alt) then
        indirectTarget = FindLastAncestorOfClass(target, 'Model')
    end

    currentTarget = indirectTarget or target
    HighlightManager.Hover:SetTargets({currentTarget})
end

local function updateTarget(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    Select.MouseTargetChanged(mouseTarget, input)
end

Select.InputBegan = updateTarget
Select.InputEnded = updateTarget

return Select