local Highlight = {}

Highlight.DefaultProps = {
    FillColor = Color3.fromRGB(69, 98, 228),
    OutlineColor = Color3.fromRGB(179, 196, 241),
    FillTransparency = 0.85,
    OutlineTransparency = 0,
    Transparency = 0
}
type HighlightProps = typeof(Highlight.DefaultProps)

-- Transparency effects both OutlineTransparency and FillTransparency, which is calculated here
-- The closer Transparency is to 1 the closer both of the other props will be to 1 as well
local function multiplyTransp(current: number, target: number): number
    return current + target * (1 - current)
end


local calcProps = {} :: { [string]: (any, Highlight) -> () }
function calcProps.FillTransparency(props, instance)
    instance.FillTransparency = multiplyTransp(props.FillTransparency, props.Transparency)
end

function calcProps.OutlineTransparency(props, instance)
    instance.OutlineTransparency = multiplyTransp(props.OutlineTransparency, props.Transparency)
end

-- If Transparency is used then both must be recalculated
function calcProps.Transparency(props, instance)
    calcProps.OutlineTransparency(props, instance)
    calcProps.FillTransparency(props, instance)
end


function Highlight.new(target: Instance, highlightProps: HighlightProps)
    local instances: {Instance} = {} -- anything that needs cleaning up

    local HighlightInstance = Instance.new('Highlight')

    -- Roblox doesn't render Highlights unless they're fully opaque, so to avoid that we have to use glass, which renders Highlights even when transparent
    if target:IsA('BasePart') and target.Transparency > 0 then
        local p = Instance.new('Part')
        p.Size = target.Size - Vector3.new(0.001, 0.001, 0.001) -- Part must be smaller to avoid z-fighting
        p.Material = Enum.Material.Glass
        p.CFrame = target.CFrame
        p.Transparency = 1
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.Anchored = true
        p.Parent = target

        HighlightInstance.Adornee = p
        table.insert(instances, p)
    else
        HighlightInstance.Adornee = target
        table.insert(instances, HighlightInstance)
    end
    HighlightInstance.Parent = workspace -- TODO: parent to a folder that is hidden to explorer?

    local self = setmetatable({
        _highlight = HighlightInstance,
        _instances = instances,
        _props = { FillTransparency = highlightProps.FillTransparency, OutlineTransparency = highlightProps.OutlineTransparency} }, {
        __index = Highlight,
        __newindex = function(self, i, v)
            if Highlight.DefaultProps[i] and self._highlight then
                if self._props[i] == v then return end
                self._props[i] = v

                if calcProps[i] ~= nil then 
                    calcProps[i](self._props, self._highlight) 
                    return
                end
                self._highlight[i] = v
            end
        end
    })

    -- Transparency dependencies will be loaded and calculated by Transparency prop, so they must be present beforehand
    local filteredProps = {
        FillTransparency = true,
        OutlineTransparency = true
    }

    -- All other properties should be triggered by __newindex so the highlight gets updated
    for i, v in highlightProps :: HighlightProps do
        if filteredProps[i] then continue end
        self[i] = v
    end

    return self
end

function Highlight:Destroy()
    for _, h in self._instances do h:Destroy() end
    table.clear(self._instances)
end

local HighlightManager = { public = {} }
type HighlightManager = typeof(setmetatable({} :: any, {})) & typeof(HighlightManager.public)

function HighlightManager.new()
    return setmetatable({
        Highlights = {},
        Properties = table.clone(Highlight.DefaultProps)
    }, {
        __newindex = function(self, i, v)
            if self.Properties[i] then
                self.Properties[i] = v

                for _, Highlight in self.Highlights do
                    Highlight[i] = v
                end
            end
        end,
        __index = function(self, i)
            local Property = self.Properties[i]
            if Property then return Property end

            return HighlightManager.public[i]
        end
    }) :: HighlightManager & HighlightProps
end

function HighlightManager.public:SetTargets(parents: {Instance})
    for _, Highlight in self.Highlights do
        Highlight:Destroy()
    end
    table.clear(self.Highlights)
    
    for i, parent in parents do
        if not (parent:IsA("PVInstance") or parent:IsA('Folder')) then continue end
        if not (parent:FindFirstAncestorOfClass('Workspace') or parent:FindFirstAncestorOfClass('ViewportFrame')) then continue end

        table.insert(self.Highlights, Highlight.new(parent, self.Properties))
    end
end

HighlightManager.Hover = HighlightManager.new() :: HighlightManager
return HighlightManager