local React = require(script.Parent.Packages.react)

local Common = require(script.Parent.Components.Common)
local TabContainer = require(script.Parent.Components.TabContainer)
local RibbonGroup = require(script.RibbonGroup)
local RibbonButton = require(script.RibbonButton)

local pluginInterface = require(script.Parent.PluginProxy.plugin.Interface)
local RibbonTools = require(script.Parent.PluginProxy.RibbonTools)

local GuiService = game:GetService('GuiService')

local RIBBON_TAB_HEIGHT = 26

local function pluginToolbars()
    local toolbarComponents, setToolbarComponents = React.useState(nil)

    React.useEffect(function()
        function pluginInterface.Toolbar.ListChanged(toolbarList)
            local components = {}

            for i, toolbar in toolbarList do
                local childComponents = {}
                for i, toolbarButton in toolbar.Buttons do
                    table.insert(childComponents,
                        React.createElement(RibbonButton, {
                            Text = toolbarButton.Text,
                            IconProps = toolbarButton.Image ~= "" and {
                                Image = toolbarButton.Image,
                                ImageRectOffset = toolbarButton.ImageRectOffset,
                                ImageRectSize = toolbarButton.ImageRectSize
                            },
                            Activated = toolbarButton.Active,
                            OnActivated = function() toolbarButton._events.Click:Fire() end
                        })
                    )
                end

                table.insert(components, 
                    React.createElement(RibbonGroup, {
                        Text = toolbar.Title,
                        LayoutOrder = toolbar.LayoutOrder
                    }, childComponents)
                )
            end

            setToolbarComponents( components )
        end

        return function() pluginInterface.Toolbar:Unbind('ListChanged') end
    end, {})

    return React.createElement(React.Fragment, nil, toolbarComponents)
end

return function()
    local theme = Common.useTheme()
    print('ribbon render')
    local selectedTab, setSelectedTab = React.useState('MODEL')
    local topBarInset, setTopBarInset = React.useState(Rect.new())
    local ribbonTool, setRibbonTool = React.useState(Enum.RibbonTool.None)

    local RibbonContentRef = React.useRef(nil)
    
    React.useEffect(function()
        local guiConnection = GuiService:GetPropertyChangedSignal('TopbarInset'):Connect(function()
            setTopBarInset(GuiService.TopbarInset)
        end)

        return function() guiConnection:Disconnect() end
    end, {})

    local DynamicPadding = { PaddingLeft = UDim.new(0, topBarInset.Min.X + 10) }

    local function ToolButton(ToolName: string, ToolEnum: Enum.RibbonTool, Icon: Common.IconProps?)
        return React.createElement(RibbonButton, {
            Text = ToolName,
            IconProps = Icon,
            Activated = (ToolEnum == ribbonTool),
            OnActivated = function()
                local newEnum = ToolEnum
                if RibbonTools.GetSelected() == ToolEnum then newEnum = Enum.RibbonTool.None end

                RibbonTools.Select(newEnum)
                if RibbonTools.GetSelected() == newEnum then setRibbonTool(newEnum) end
            end
        })
    end

    return React.createElement(React.Fragment, nil,
        React.createElement('Frame', {
            key = 'TabTopBar',
            BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.RibbonTab),
            BorderColor3 = theme:GetColor(theme.StudioStyleGuideColor.Border),
            Size = UDim2.new(1, 0, 0, RIBBON_TAB_HEIGHT),
            ZIndex = 2
        }, {
            Padding = React.createElement('UIPadding', DynamicPadding),

            Tabs = React.createElement(TabContainer, {
                Size = UDim2.fromScale(0.5, 1),
                SelectedTab = selectedTab,
                ContentContainer = RibbonContentRef,
                OnTabSelected = setSelectedTab
            }, {
                ['MODEL'] = {
                    LayoutOrder = 1,
                    Content = React.createElement(RibbonGroup, { Text = 'Tools' }, {
                        ToolButton('Select', Enum.RibbonTool.Select, theme:GetIcon('Select', 'Large')),
                        ToolButton('Move', Enum.RibbonTool.Move, theme:GetIcon('Move', 'Large')),
                        ToolButton('Scale', Enum.RibbonTool.Scale, theme:GetIcon('Scale', 'Large')),
                        ToolButton('Rotate', Enum.RibbonTool.Rotate, theme:GetClassIcon('Rotate', 'Large'))
                    })
                },
                ['VIEW'] = {
                    LayoutOrder = 2
                },
                ['PLUGINS'] = {
                    LayoutOrder = 3,
                    Content = React.createElement(pluginToolbars)
                }
            })
        }),

        React.createElement('Frame', {
            ref = RibbonContentRef,
            key = 'Ribbon',
            BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.TabBar),
            BorderColor3 = theme:GetColor(theme.StudioStyleGuideColor.Border),
            Position = UDim2.new(0, 0, 0, RIBBON_TAB_HEIGHT),
            Size = UDim2.new(1, 0, 0, 100),
        }, {
            Padding = React.createElement('UIPadding', {
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = DynamicPadding.PaddingLeft
            }),
            ListLayout = React.createElement('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal
            })
        })
    )
end