--!strict
export type CommonProps = {
	Disabled: boolean?,
	Position: UDim2?,
	Size: UDim2?,
    AnchorPoint: Vector2?,
    SizeConstraint: Enum.SizeConstraint?,
	LayoutOrder: number?,
	ZIndex: number?
}

local Common = {}

Common.Constants = table.freeze({
    --- @within Constants
    --- @prop DefaultFont Font
    --- The default font for text.
    DefaultFont = Enum.Font.SourceSans,

    --- @within Constants
    --- @prop DefaultTextSize number
    --- The default size for text.
    DefaultTextSize = 14,

    --- @within Constants
    --- @prop DefaultButtonHeight number
    --- The default height of buttons.
    DefaultButtonHeight = 24,

    --- @within Constants
    --- @prop DefaultToggleHeight number
    --- The default height of toggles (Checkbox and RadioButton).
    DefaultToggleHeight = 20,

    --- @within Constants
    --- @prop DefaultInputHeight number
    --- The default height of text and numeric inputs.
    DefaultInputHeight = 22,

    --- @within Constants
    --- @prop DefaultSliderHeight number
    --- The default height of sliders.
    DefaultSliderHeight = 22,

    --- @within Constants
    --- @prop DefaultDropdownHeight number
    --- The default height of the permanent section of dropdowns.
    DefaultDropdownHeight = 20,

    --- @within Constants
    --- @prop DefaultDropdownRowHeight number
    --- The default height of rows in dropdown lists.
    DefaultDropdownRowHeight = 16,

    --- @within Constants
    --- @prop DefaultProgressBarHeight number
    --- The default height of progress bars.
    DefaultProgressBarHeight = 14,

    --- @within Constants
    --- @prop DefaultColorPickerSize UDim2
    --- The default window size of color pickers.
    DefaultColorPickerSize = UDim2.fromOffset(260, 285),

    --- @within Constants
    --- @prop DefaultNumberSequencePickerSize UDim2
    --- The default window size of number sequence pickers.
    DefaultNumberSequencePickerSize = UDim2.fromOffset(425, 285)
})

local React = require(script.Parent.Parent.Packages.react)
local StudioThemes = require(script.Parent.Parent.PluginProxy.Themes)
local Enums = require(script.Parent.Parent.PluginProxy.EnumDefinitions)

export type StudioStyleGuideColor = Enums.StudioStyleGuideColor
export type StudioStyleGuideModifier = Enums.StudioStyleGuideModifier

local Icons = require(script.Parent.Parent.PluginProxy.Icons)

export type IconProps = Icons.ImageProps

function Common.useTheme(): StudioThemes.ThemeInstance
	local studioTheme, setStudioTheme = React.useState(StudioThemes.Theme)

	React.useEffect(function()
		local connection = StudioThemes.ThemeChanged:Connect(function()
			setStudioTheme(StudioThemes.Theme)
		end)

		return function() connection:Disconnect() end
	end)

	return studioTheme
end

local TextService = game:GetService("TextService")

local TEXT_SIZE = Common.Constants.DefaultTextSize
local FONT = Common.Constants.DefaultFont
local FRAME_SIZE = Vector2.one * math.huge

function Common.getTextSize(text: string): Vector2
    if not text then return Vector2.zero end

	local size = TextService:GetTextSize(text, TEXT_SIZE, FONT, FRAME_SIZE)
	return Vector2.new(math.ceil(size.X), math.ceil(size.Y)) + Vector2.one
end

local UserInputService = game:GetService("UserInputService")
local PlayerGui = game:GetService('Players').LocalPlayer.PlayerGui

local customMouse: ScreenGui?
local mouseFrame: ImageLabel
local mouseMoved: RBXScriptConnection?
local function getCustomMouse()
    if not customMouse then
        local mGui = Instance.new('ScreenGui')
        mGui.Name = "IngameStudio Cursor"
        mGui.DisplayOrder = 500
        mGui.Parent = PlayerGui

        local mFrame = Instance.new('ImageLabel')
        mFrame.Size = UDim2.fromOffset(64, 64)
        mFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        mFrame.BackgroundTransparency = 1
        mFrame.Parent = mGui

        customMouse = mGui
        mouseFrame = mFrame
    end

    if not mouseMoved then
        mouseMoved = UserInputService.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                mouseFrame.Position = UDim2.fromOffset(Input.Position.X, Input.Position.Y)
            end
        end)
    end

    if customMouse and customMouse.Parent == nil then
        customMouse.Parent = PlayerGui
    end

    return mouseFrame
end

local function removeCustomMouse()
    if mouseMoved then
        mouseMoved:Disconnect()
        mouseMoved = nil
    end
    if customMouse then
        customMouse.Parent = nil
    end
end

-- This function exists only because setting Active to true forces you to use the Hand cursor icon

--- Overrides the default cursor by setting MouseIconEnabled to false and creating a cursor element
--- required for overwriting cursors when hovering over active element
--- setting icon to nil will disable the override
--- setting icon to "" will result in using the default cursor instead
local defaultCursor = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
function Common.overrideCursor(Icon: string?)
    UserInputService.MouseIconEnabled = (Icon ==  nil)
    if not Icon then return removeCustomMouse() end

    if Icon == "" then Icon = defaultCursor end
    getCustomMouse().Image = Icon
end

type Rect = {
    top: number,
    bottom: number,
    left: number,
    right: number
}

--- Gets the Rect of a frame, with padding that reduces the size of it
function Common.getBoundingRect(Frame: GuiObject, Padding: number?): Rect
    local Pad = Padding or 0

    local Pos = Frame.AbsolutePosition
    local Size = Frame.AbsoluteSize

    return {
        top = Pos.Y + Pad,
        bottom = Pos.Y + Size.Y - Pad,
        left = Pos.X + Pad,
        right = Pos.X + Size.X - Pad,
    }
end

--[=[
    Determines if the cursor is on a border/corner, by returning an AnchorPoint

    Bounding box visualization, Center (C) would be the provided rect,
    anything outside of Center would give a value that is not [0.5, 0.5]

    In practice, CornerSize shrinks the bounding sizes of \
    T, B, L, R to increase the size of TL, TR, BL, BR

    ```
               [0,0] [0.5,0] [1,0]
                 |      |      |
                 v      v      v
              +––––––+––––––+––––––+
              |      |      |      |
      [0,0] <-+  TL  |  T   |  TR  +-> [1,0]
              |      |      |      |
              +––––––+––––––+––––––+
              |      |      |      |
    [0,0.5] <-+  L   |  C   |  R   +-> [1,0.5]
              |      |      |      |
              +––––––+––––––+––––––+
              |      |      |      |
      [0,1] <-+  BL  |  B   |  BR  +-> [1,1]
              |      |      |      |
              +––––––+––––––+––––––+
                  ^      ^      ^
                  |      |      |
               [0,1]  [0.5,1]  [1,1]
    ```

    **Format: [X, Y]** \
    X: 0 *(Left)*, 0.5 *(Center)*, 1 *(Right)* \
    Y: 0 *(Top)*, 0.5 *(Center)*, 1 *(Bottom)*
]=]
function Common.getRelativePos(Pos: Vector2, Rect: Rect, CornerSize: number?): Vector2
    local X = 0.5
    local Y = 0.5
    if Pos.X <= Rect.left then
        X = 0
    elseif Pos.X >= Rect.right then
        X = 1
    end

    if Pos.Y <= Rect.top then
        Y = 0
    elseif Pos.Y >= Rect.bottom then
        Y = 1
    end

    if not CornerSize then return Vector2.new(X, Y) end

    -- Increase bounding box for corners
    if X ~= 0.5 and Y == 0.5 then
        if Pos.Y < Rect.top + CornerSize then
            Y = 0
        elseif Pos.Y > Rect.bottom - CornerSize then
            Y = 1
        end
    elseif Y ~= 0.5 and X == 0.5 then
        if Pos.X < Rect.left + CornerSize then
            X = 0
        elseif Pos.X > Rect.right - CornerSize then
            X = 1
        end
    end

    return Vector2.new(X, Y)
end

--- Sets an anchor point without changing the frame's absolute position, returns the new anchor point's position
function Common.setAbsoluteAnchor(Frame: GuiObject, newAnchor: Vector2): Vector2
    -- Offset is used when the GUI's IgnoreGuiInset is set to true, in that case if this offset isnt accounted for then the window will float when dragged
    local insetOffsetY = 0 
    local screenGui = Frame:FindFirstAncestorWhichIsA('LayerCollector')
    if screenGui then insetOffsetY = screenGui.AbsolutePosition.Y end

    local absoluteAnchorPos = Vector2.new(
        math.ceil(Frame.AbsolutePosition.X + (newAnchor.X * Frame.AbsoluteSize.X)),
        math.ceil((Frame.AbsolutePosition.Y - insetOffsetY) + (newAnchor.Y * Frame.AbsoluteSize.Y))
    )

    Frame.Position = UDim2.fromOffset(absoluteAnchorPos.X, absoluteAnchorPos.Y)
    Frame.AnchorPoint = newAnchor
    return absoluteAnchorPos
end

return Common