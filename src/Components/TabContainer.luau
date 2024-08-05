--!strict
local React = require(script.Parent.Parent.Packages.react)
local ReactRoblox = require(script.Parent.Parent.Packages["react-roblox"])

local Common = require(script.Parent.Common)

local function TabButton(props: {
	Size: UDim2,
	Text: string,
	LayoutOrder: number,
	Selected: boolean,
	OnActivated: () -> (),
	Disabled: boolean?,
    children: React.ReactNode?
})
	local theme = Common.useTheme()
	local hovered, setHovered = React.useState(false)

	local modifier = theme.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = theme.StudioStyleGuideModifier.Disabled
	elseif props.Selected then
		modifier = theme.StudioStyleGuideModifier.Selected
	elseif hovered then
		modifier = theme.StudioStyleGuideModifier.Hover
	end

	return React.createElement("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.RibbonTab, modifier),
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		Text = props.Text,
		Font = Enum.Font.SourceSans,
		TextColor3 = theme:GetColor(theme.StudioStyleGuideColor.MainText, modifier),
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 14,
		[React.Event.InputBegan] = function(_, input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                setHovered(true)
            end
        end,
		[React.Event.InputEnded] = function(_, input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                setHovered(false)
            end
        end,
		[React.Event.Activated] = function()
			if not props.Disabled then
				props.OnActivated()
			end
		end,
	}, {
		Indicator = props.Selected and React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.RibbonTabTopBar),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2),
		}),
		Under = props.Selected and React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.RibbonTab, modifier),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromScale(0, 1),
		}),
	}, props.children)
end

type Tab = {
	Content: React.ReactNode,
	LayoutOrder: number,
	Disabled: boolean?
}

local TAB_HEIGHT = 30

local function TabContainer(props: {
	SelectedTab: string,
	OnTabSelected: ((name: string) -> ())?,
    -- Ref type for react-lua is broken for some reason, so '& {current: GuiObject}' must be added to not get an error when accessing the key 'current'
	ContentContainer: (React.Ref<GuiObject> & {current: GuiObject})?, 
	children: { [string]: Tab }?
} & Common.CommonProps)

	local children = props.children :: { [string]: Tab }
	local tabButtons: { [string]: React.ReactNode } = {}
    local tabContainerWidth, setTabContainerWidth = React.useState(0)

    local count = 0
    for _, _ in children do count += 1 end

	for name, tab in children do
		local isSelectedTab = props.SelectedTab == name
        local textWidth = Common.getTextSize(name).X + 25

		tabButtons[name] = React.createElement(TabButton, {
			Size = UDim2.new(0, textWidth, 1, 0),
			LayoutOrder = tab.LayoutOrder,
			Text = name,
			Selected = isSelectedTab,
			Disabled = tab.Disabled == true or props.Disabled == true,
			OnActivated = function()
				if props.OnTabSelected then
					props.OnTabSelected(name)
				end
			end,
		}, {
            MaxSize = React.createElement('UISizeConstraint', {
                MaxSize = Vector2.new(tabContainerWidth / count, math.huge)
            })
        })
	end

	local tab = children[props.SelectedTab]
	local tabContent = tab and tab.Content

	local ContentContainer: nil | GuiObject = props.ContentContainer and props.ContentContainer.current

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
        [React.Change.AbsoluteSize] = function(self)
            setTabContainerWidth(self.AbsoluteSize.X)
        end
	}, {
		Top = React.createElement("Frame", {
			ZIndex = 2,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			TabsContainer = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}),
			}, tabButtons),
		}),
		Content = ContentContainer and ReactRoblox.createPortal(tabContent, ContentContainer) or React.createElement("Frame", {
			ZIndex = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, -TAB_HEIGHT - 1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, tabContent),
	})
end

return TabContainer
