--!strict
local React = require(script.Parent.Parent.Packages.react)

local Common = require(script.Parent.Parent.Components.Common)

type LabelStyleGuide = {
    TextColor: Common.StudioStyleGuideColor?,
	Modifier: Common.StudioStyleGuideModifier?
}

return function(props: {
	Text: string,
	TextWrapped: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
	TextTruncate: Enum.TextTruncate?,
	TextTransparency: number?,
	TextColor3: Color3?,
	RichText: boolean?,
	MaxVisibleGraphemes: number?,
	children: React.ReactNode?,
    StyleGuide: LabelStyleGuide?
} & Common.CommonProps)
	local theme = Common.useTheme()

	local StyleGuide: LabelStyleGuide = props.StyleGuide or {}
	local style = StyleGuide.TextColor or theme.StudioStyleGuideColor.MainText
	local modifier = StyleGuide.Modifier or theme.StudioStyleGuideModifier.Default

	if props.Disabled then
		modifier = theme.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("TextLabel", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Text = props.Text,
		BackgroundTransparency = 1,
		Font = Common.Constants.DefaultFont,
		TextSize = Common.Constants.DefaultTextSize,
		TextColor3 = props.TextColor3 or theme:GetColor(style, modifier),
		TextTransparency = props.TextTransparency,
		TextXAlignment = props.TextXAlignment,
		TextYAlignment = props.TextYAlignment,
		TextTruncate = props.TextTruncate,
		TextWrapped = props.TextWrapped,
		RichText = props.RichText,
		MaxVisibleGraphemes = props.MaxVisibleGraphemes,
	}, props.children)
end