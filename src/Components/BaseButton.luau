--!strict
local React = require(script.Parent.Parent.Packages.react)

local Common = require(script.Parent.Parent.Components.Common)

type ButtonStyleGuide = {
    defaultTransparent: boolean?,
    BackgroundColor: Common.StudioStyleGuideColor?,
    BorderColor: Common.StudioStyleGuideColor?,
    Modifier: Common.StudioStyleGuideModifier?
}

return function(props: {
    Activated: boolean?,
    OnActivated: (() -> ())?,
    BorderSizePixel: number?,
    AutomaticSize: Enum.AutomaticSize?,
    children: React.ReactNode?,
    StyleGuide: ButtonStyleGuide?
} & Common.CommonProps)
    local theme = Common.useTheme()

    local StyleGuide: ButtonStyleGuide = props.StyleGuide or {}
    local BackgroundColor = StyleGuide.BackgroundColor or theme.StudioStyleGuideColor.Button
    local BorderColor = StyleGuide.BorderColor or theme.StudioStyleGuideColor.ButtonBorder

    local hovered, setHovered = React.useState(false)
    local pressed, setPressed = React.useState(false)

    local modifier = theme.StudioStyleGuideModifier.Default
    if props.Activated then modifier = theme.StudioStyleGuideModifier.Pressed end
    
    if pressed and hovered then
        modifier = theme.StudioStyleGuideModifier.Pressed
    elseif hovered then modifier = theme.StudioStyleGuideModifier.Hover end

    if StyleGuide.Modifier then modifier = StyleGuide.Modifier end

    return React.createElement('Frame', {
        Active = true,
        Size = props.Size or UDim2.fromOffset(100, 25),
        BackgroundTransparency = (modifier.Value == 0 and StyleGuide.defaultTransparent) and 1 or 0,
        BorderSizePixel = props.BorderSizePixel or 1,
        BackgroundColor3 = theme:GetColor(BackgroundColor, modifier),
        BorderColor3 = theme:GetColor(BorderColor, modifier),
        [React.Event.InputBegan] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not props.Disabled then
				setPressed(true)
                if props.OnActivated then props.OnActivated() end
			end
		end,
		[React.Event.InputEnded] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(false)
			end
		end,

        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        SizeConstraint = props.SizeConstraint,
        LayoutOrder = props.LayoutOrder,
        ZIndex = props.ZIndex,
        AutomaticSize = props.AutomaticSize
    }, props.children)
end