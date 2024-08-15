local Explorer = require(script.Parent.Parent.PluginProxy.Services.Explorer)
local React = require(script.Parent.Parent.Packages.react)

local Components = script.Parent.Parent.Components
local Common = require(Components.Common)
local DockableWidget = require(Components.DockableWidget)
local ExplorerItem = require(script.Item)

return function(props: {
    Parent: ScreenGui,
})
    local defaultSize = Vector2.new(200, 380)

    return React.createElement(DockableWidget, {
        Title = "Explorer",
        Parent = props.Parent,
        Size = defaultSize
    }, React.createElement('ScrollingFrame', {
        CanvasSize = UDim2.fromOffset(defaultSize.X, defaultSize.Y),
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    }, {
        UIList = React.createElement('UIListLayout', {
            SortOrder = Enum.SortOrder.LayoutOrder,
            [React.Change.AbsoluteContentSize] = function(self)
                local Size = self.AbsoluteContentSize
                self.Parent.CanvasSize = UDim2.fromOffset(Size.X + 40, Size.Y)
            end
        }),
        React.createElement(ExplorerItem)
    }))
end
