local Explorer = require(script.Parent.Parent.PluginProxy.Services.Explorer)
local React = require(script.Parent.Parent.Packages.react)

local Components = script.Parent.Parent.Components
local Common = require(Components.Common)
local DockableWidget = require(Components.DockableWidget)
local ExplorerItem = require(script.Item)

local function createItems(objList: {Instance})
    local items = {}
    for i, v in objList do
        table.insert(items, React.createElement(ExplorerItem, { Instance = v }))
    end
    return items
end

return function(props: {
    Parent: ScreenGui,
})
    print('explorer load')
    local theme = Common.useTheme()

    local defaultSize = Vector2.new(200, 380)
    local items, setItems = React.useState(createItems(Explorer.GetSortedObjectList()))

    local ListLayout = React.useRef(nil)
    local ScrollingFrame = React.useRef(nil)

    React.useEffect(function()
        local event
        if ListLayout.current then
            event = ListLayout.current:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                local Size = ListLayout.current.AbsoluteContentSize
                if ScrollingFrame.current then
                    ScrollingFrame.current.CanvasSize = UDim2.fromOffset(Size.X + 40, Size.Y)
                end
            end)
        end
        return function()
            if event then event:Disconnect() end
        end
    end, {ListLayout})

    return React.createElement(DockableWidget, {
        Title = "Explorer",
        Parent = props.Parent,
        Size = defaultSize
    }, React.createElement('ScrollingFrame', {
        ref = ScrollingFrame,
        CanvasSize = UDim2.fromOffset(defaultSize.X, defaultSize.Y),
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    }, {
        UIList = React.createElement('UIListLayout', {
            ref = ListLayout
        }),
        React.createElement(React.Fragment, nil, items)
    }))
end
