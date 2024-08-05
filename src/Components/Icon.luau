--!strict
local React = require(script.Parent.Parent.Packages.react)

local Common = require(script.Parent.Common)

return function(props: {
    Icon: string?,
    ClassIcon: string?,
    IconProps: Common.IconProps?
} & Common.CommonProps)
    local theme = Common.useTheme()

    local function getIcon()
        if props.Icon then
            return theme:GetIcon(props.Icon)
        elseif props.ClassIcon then
            return theme:GetClassIcon(props.ClassIcon)
        end
        return nil
    end

    local IconProps = props.IconProps or getIcon() or {}

    return React.createElement('ImageLabel', {
        Image = IconProps.Image,
        ImageRectOffset = IconProps.ImageRectOffset,
        ImageRectSize = IconProps.ImageRectSize,
        BackgroundTransparency = 1,

        Size = props.Size or UDim2.fromOffset(IconProps.ImageRectSize.X, IconProps.ImageRectSize.Y),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
        SizeConstraint = props.SizeConstraint,
        LayoutOrder = props.LayoutOrder,
        ZIndex = props.ZIndex,
    })
end
