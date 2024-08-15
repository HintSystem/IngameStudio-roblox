local Explorer = require(script.Parent.Parent.Parent.PluginProxy.Services.Explorer)
local Selection = require(script.Parent.Parent.Parent.PluginProxy.Services.Selection)
local React = require(script.Parent.Parent.Parent.Packages.react)

local Components = script.Parent.Parent.Parent.Components

local Common = require(Components.Common)
local Label = require(Components.Label)
local Icon = require(Components.Icon)

type ChildInfo = {
    hasChildren: boolean,
    orderedList: {Instance}
}

local activatedDropdowns = {}

-- If no instance is specified then it is considered to be the root
local function ExplorerItem(props: {
    Instance: Instance?,
    Depth: number?,
    Order: number?
})
    local theme = Common.useTheme()

    local IsRoot = (props.Instance == nil)
    local Instance = props.Instance or Explorer.GetRoot()
    local Depth = props.Depth or 0
    local UID = `{props.Depth}_{props.Order or Instance.Name}`

    local hasChildren, setHasChildren = React.useState(#Instance:GetChildren() > 0)
    local orderedChild, setOrderedChild = React.useState({})
    local childrenChanged = React.useRef(true)

    local childComponents = {}
    for i, v in orderedChild do
        table.insert(childComponents, React.createElement(ExplorerItem, {
            key = v.Name,
            Instance = v,
            Depth = props.Depth and props.Depth + 1 or 0,
            Order = i
        }))
    end

    local active, setActiveState = React.useState(activatedDropdowns[UID] or IsRoot)
    local function setActive(value: boolean)
        if props.Depth then
            activatedDropdowns[UID] = value and true or nil
        end

        setActiveState(value)
    end

    React.useEffect(function()
        if active and childrenChanged.current then
            childrenChanged.current = false

            setOrderedChild(Explorer.GetSortedObjectList(Instance))
        end
    end, {active})

    React.useEffect(function()
        local function updateChildren()
            if active then
                setOrderedChild(Explorer.GetSortedObjectList(Instance))
            else
                childrenChanged.current = true
            end
        end

        local Added = Instance.ChildAdded:Connect(function()
            if not hasChildren then setHasChildren(true) end
            updateChildren()
        end)
        local Removed = Instance.ChildRemoved:Connect(function()
            if #Instance:GetChildren() == 0 then setHasChildren(false) end
            updateChildren()
        end)

        return function()
            Added:Disconnect()
            Removed:Disconnect()
        end
    end, {props.Instance})

    if IsRoot then
        -- Root only renders the child elements
        return React.createElement(React.Fragment, nil, childComponents)
    else
        local selected, setSelected = React.useState(Selection:IsSelected(Instance))
        local hovered, setHovered = React.useState(false)

        React.useEffect(function()
            local selectDisconnect = Selection.onSelectionChanged(Instance, function(isSelected)
                setSelected(isSelected)
            end)

            return selectDisconnect
        end, {props.Instance})

        local highlightColor
        if selected then
            highlightColor = theme:GetColor(theme.StudioStyleGuideColor.Item, theme.StudioStyleGuideModifier.Selected)
        elseif hovered then
            highlightColor = theme:GetColor(theme.StudioStyleGuideColor.Item, theme.StudioStyleGuideModifier.Hover)
        end


        local textSize = Common.getTextSize(Instance.Name)
        local tabOffset = 20 * Depth
        local iconOffset = 20
        local itemHeight = 16 + 2
        local highlightWidth = 10000 -- highlight should span the size of the window
        local itemWidth = tabOffset + (iconOffset * 2 + textSize.X)
        return React.createElement('Frame', {
            key = Instance.Name,
            Size = UDim2.fromOffset(itemWidth, itemHeight),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = props.Order
        }, {
            Dropdown = hasChildren and React.createElement(Icon, {
                Icon = active and 'ArrowDown' or 'ArrowRight',
                Position = UDim2.fromOffset(tabOffset, 0),
                AnchorPoint = Vector2.zero,
                ZIndex = 2,
                OnActivated = function()
                    setActive(not active)
                end
            }),
            Icon = React.createElement(Icon, {
                ClassIcon = Instance.ClassName,
                Position = UDim2.fromOffset(tabOffset + iconOffset, 0),
                AnchorPoint = Vector2.new(0, 0),
                ZIndex = 2
            }),
            Name = React.createElement(Label, {
                Text = Instance.Name,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.fromOffset(tabOffset + (iconOffset * 2), 0),
                Size = UDim2.fromOffset(textSize.X, itemHeight),
                ZIndex = 2,
                StyleGuide = {
                    Modifier = selected and theme.StudioStyleGuideModifier.Selected
                }
            }),
            Highlighter = React.createElement('Frame', {
                Size = UDim2.fromOffset(highlightWidth, itemHeight),
                BackgroundColor3 = highlightColor,
                BackgroundTransparency = highlightColor and 0 or 1,
                BorderSizePixel = 0,
                
                [React.Event.InputBegan] = function(self: Frame, input: InputObject)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        setHovered(true)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
                            Selection:Add({Instance})
                            return
                        end
                        Selection:Set({Instance})
                    end
                end,
                [React.Event.InputEnded] = function(self: Frame, input: InputObject)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        setHovered(false)
                    end
                end
            }),

            Children = active and hasChildren and React.createElement('Frame', {
                Position = UDim2.fromOffset(0, itemHeight),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1
            }, {
                UIList = React.createElement('UIListLayout', {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    [React.Change.AbsoluteContentSize] = function(self)
                        local ListSize = self.AbsoluteContentSize
                        local Item = self.Parent.Parent
                        Item.Size = UDim2.fromOffset(math.max(ListSize.X, itemWidth), Item.Size.Y.Offset)
                    end
                }),
                React.createElement(React.Fragment, nil, childComponents)
            })
        })
    end
end

return ExplorerItem