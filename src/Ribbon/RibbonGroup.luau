local React = require(script.Parent.Parent.Packages:FindFirstChild('react'))

local Common = require(script.Parent.Parent.Components.Common)
local Label = require(script.Parent.Parent.Components.Label)

return function(props: {
    Text: string,
    LayoutOrder: number?,
    Disabled: boolean?,
    Compact: boolean?,
    children: React.ReactNode
})
    local theme = Common.useTheme()

    local textSize = Common.getTextSize(props.Text)
    local textHeight = Common.Constants.DefaultTextSize

    local contentWidth, setContentWidth = React.useState(100)

    -- Prevent flashing when switching tabs
    local UIListLayout = React.useRef(nil)
    React.useLayoutEffect(function()
        setContentWidth(UIListLayout.current.AbsoluteContentSize.X)
    end, { UIListLayout })
    
    return React.createElement('Frame', {
        key = props.Text or 'Group',
        Size = UDim2.new(0, contentWidth + 10, 1, 0),
        BackgroundTransparency = 1,
        LayoutOrder = props.LayoutOrder or 0
    }, {
        MinSize = React.createElement('UISizeConstraint', {
            MinSize = Vector2.new(textSize.X + 10, 0)
        }),

        Seperator = React.createElement('Frame', {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.fromScale(1, 0),
            BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.Border),
            BorderSizePixel = 0
        }),

        GroupContents = React.createElement('Frame', {
            Size = UDim2.new(1, 0, 1, -textHeight),
            BackgroundTransparency = 1
        }, {
            React.createElement('UIPadding', {
                key = 'Padding',
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4)
            }),
            React.createElement('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 2),
                ref = UIListLayout,
                [React.Change.AbsoluteContentSize] = function(el)
                    setContentWidth(el.AbsoluteContentSize.X)
                end
            }),
        }, props.children),

        Label = React.createElement(Label, {
            Text = props.Text,
            Size = UDim2.new(0, textSize.X, 0, textHeight),
            Position = UDim2.fromScale(0.5, 1),
            AnchorPoint = Vector2.new(0.5, 1),
            TextColor3 = theme:GetColor(theme.StudioStyleGuideColor.TitlebarText),
        })
    })
end
