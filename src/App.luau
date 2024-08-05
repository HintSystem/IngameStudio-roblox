local React = require(script.Parent.Packages.react)

local Ribbon = require(script.Parent.Ribbon)
local DockableWidget = require(script.Parent.Components.DockableWidget)

local pluginInterface = require(script.Parent.PluginProxy.plugin.Interface)

local function windowProcessor()
    local windowComponents, setWindowComponents = React.useState(nil)

    React.useEffect(function()
        function pluginInterface.DockWidget.ListChanged(widgetList)
            local components = {}
            for i, window in widgetList do
                table.insert(components, React.createElement(DockableWidget, {
                    Title = window.Title,
                    Size = Vector2.new(window.Info.FloatingXSize, window.Info.FloatingYSize),
                    minSize = Vector2.new(window.Info.MinWidth, window.Info.MinHeight),
                    Parent = window.Gui,
                    Content = window.Content
                }))
            end
            setWindowComponents(components)
        end

        return function() pluginInterface.DockWidget:Unbind('ListChanged') end
    end, {})

    return React.createElement(React.Fragment, nil, windowComponents)
end

return function()
    return React.createElement(React.Fragment, nil,
        React.createElement(Ribbon),    
        React.createElement(windowProcessor)
    )
end