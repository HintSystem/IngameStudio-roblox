local RibbonTools = {
    selectedManually = true,
    selected = Enum.RibbonTool.None
}

local ToolType = require(script.Type)
type ToolImplementation = ToolType.T

local toolModule: ToolImplementation?
local toolModuleList = {} :: {[string]: ToolImplementation}
for i, v in script:GetChildren() do
    if v:IsA("ModuleScript") and v.Name ~= "Type" then
        toolModuleList[v.Name] = require(v)
    end
end

local callToolImpl = setmetatable({}, {
    __index = function(self, i)
        return function(...)
            if not toolModule then return end

            if toolModule.useSelect then
                local selectModuleFunc = toolModuleList['Select'][i]
                if selectModuleFunc then selectModuleFunc(...) end
            end

            if toolModule[i] then
                toolModule[i](...)
            end
        end
    end
}) :: typeof(setmetatable({} :: ToolImplementation, {}))

function RibbonTools.GetSelected()
    return RibbonTools.selected
end

local function setTool(newToolEnum: Enum.RibbonTool, newToolModule: ToolImplementation?)
    callToolImpl.Deselected(newToolEnum)
    RibbonTools.selected = newToolEnum
    toolModule = newToolModule
end

function RibbonTools.Select(tool: Enum.RibbonTool, pluginSelected: boolean?)
    if pluginSelected == nil then pluginSelected = false end
    if tool == RibbonTools.selected then return end
    RibbonTools.selectedManually = pluginSelected

    if tool == Enum.RibbonTool.None then
        setTool(tool, nil)
        return
    end

    local FoundTool = toolModuleList[tool.Name]
    if FoundTool then
        local prevTool = RibbonTools.selected

        setTool(tool, FoundTool)
        callToolImpl.Selected(prevTool)
    end
end

-- Method implementation for Tool modules

local InputService = game:GetService('UserInputService')
local Mouse = game:GetService('Players').LocalPlayer:GetMouse()

InputService.InputBegan:Connect(function(input, gameProcessed)
    callToolImpl.InputBegan(input, gameProcessed)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        callToolImpl.Clicked(input)
    end
end)

InputService.InputEnded:Connect(function(input, gameProcessed)
    callToolImpl.InputEnded(input, gameProcessed)
end)

local prevTarget
InputService.InputChanged:Connect(function(input, gameProcessed)
    callToolImpl.InputChanged(input, gameProcessed)

    if input.UserInputType == Enum.UserInputType.MouseMovement and not gameProcessed then
        callToolImpl.MouseMoved(input)
    end

    -- Should this use raycasts instead?
    if prevTarget ~= Mouse.Target then
        prevTarget = Mouse.Target
        callToolImpl.MouseTargetChanged(Mouse.Target, input)
    end
end)

return RibbonTools