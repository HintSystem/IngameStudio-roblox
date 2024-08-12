local React = require(script.Parent.Packages.react)

local PluginProxy = require(script.Parent.PluginProxy)
local pluginInterface = require(script.Parent.PluginProxy.plugin.Interface)

local Ribbon = require(script.Parent.Ribbon)
local DockableWidget = require(script.Parent.Components.DockableWidget)

local PlayerGui = game:GetService('Players').LocalPlayer.PlayerGui
local WidgetGuiCollector = PlayerGui:FindFirstChild('StudioWidgets')

if not WidgetGuiCollector or (not WidgetGuiCollector:IsA('LayerCollector')) then
    WidgetGuiCollector = Instance.new('ScreenGui')
    WidgetGuiCollector.Name = 'StudioWidgets'
    WidgetGuiCollector.ResetOnSpawn = false
    WidgetGuiCollector.Parent = PlayerGui
end

PluginProxy.SetDockWidgetParentGui(WidgetGuiCollector)

local function pluginWidgets()
    local windowComponents, setWindowComponents = React.useState(nil)

    React.useEffect(function()
        function pluginInterface.DockWidget.ListChanged(widgetList)
            local components = {}
            for i, window in widgetList do
                table.insert(components, React.createElement(DockableWidget, {
                    key = window.Gui.Name,
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

local StudioWidgets = {}
for _, Widget in script.Parent.Widgets:GetChildren() do
    if Widget:IsA('ModuleScript') then
        local gui = Instance.new('ScreenGui')
        gui.Name = Widget.Name
        gui.ResetOnSpawn = false
        gui.Parent = WidgetGuiCollector

        table.insert(StudioWidgets, React.createElement(require(Widget), {
            key = Widget.Name,
            Parent = gui
        }))
    end
end

return function()
    return React.createElement(React.Fragment, nil,
        React.createElement(Ribbon),    
        React.createElement(pluginWidgets),
        React.createElement(React.Fragment, { Parent = WidgetGuiCollector }, StudioWidgets)
    )
end