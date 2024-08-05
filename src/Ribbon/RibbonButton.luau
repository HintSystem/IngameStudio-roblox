--!strict
local React = require(script.Parent.Parent.Packages:FindFirstChild('react'))

local Common = require(script.Parent.Parent.Components.Common)
local BaseButton = require(script.Parent.Parent.Components.BaseButton)
local Label = require(script.Parent.Parent.Components.Label)
local Icon = require(script.Parent.Parent.Components.Icon)

return function(props: {
    Text: string,
    IconProps: Common.IconProps?,
    Activated: boolean?,
    OnActivated: (() -> ())?
})
    local theme = Common.useTheme()

    local textSize = Common.getTextSize(props.Text)
    local textHeight = (Common.Constants.DefaultTextSize * 2) + 5

    return React.createElement(BaseButton, {
        Size = UDim2.fromScale(0.5, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Activated = props.Activated,
        OnActivated = props.OnActivated,
        StyleGuide = {
            BackgroundColor = theme.StudioStyleGuideColor.RibbonButton,
            BorderColor = theme.StudioStyleGuideColor.RibbonButton
        }
    }, {
        MinSize = React.createElement('UISizeConstraint', {
            MinSize = Vector2.new(textSize.X + 4, 0)
        }),

        Frame = React.createElement('Frame', {
            Size = UDim2.new(1, 0, 1, -textHeight),
            BackgroundTransparency = 1
        }, {
            Padding = React.createElement('UIPadding', {
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2)
            }),

            Icon = props.IconProps and React.createElement(Icon, {
                Size = UDim2.fromOffset(32, 32),
                IconProps = props.IconProps
            }),
        }),

        Label = React.createElement(Label, {
            Text = props.Text,
            TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.new(0, textSize.X, 0, textHeight),
            AnchorPoint = Vector2.new(0.5, 1),
            StyleGuide = {
                TextColor = theme.StudioStyleGuideColor.ButtonText
            }
        })
    })
end
