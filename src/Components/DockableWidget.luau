local React = require(script.Parent.Parent.Packages.react)
local ReactRoblox = require(script.Parent.Parent.Packages["react-roblox"])

local Common = require(script.Parent.Parent.Components.Common)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)
local BaseButton = require(script.Parent.BaseButton)

local UserInputService = game:GetService("UserInputService")

local TITLEBAR_HEIGHT = 24

local RESIZE_RECT_PADDING = 12 -- Padding added to the DockWidget for increasing the size of the resizable area
local RESIZE_CORNER_SIZE = 10 -- Added width of resizable window corners

local function getMouseIcon(Pos: Vector2): string
    -- none
    if Pos.Y == 0.5 and Pos.X == 0.5 then
        return ""
    end

    -- top-left or bottom-right
    if Pos.Y == Pos.X then
        return "rbxasset://textures/StudioUIEditor/icon_resize3.png"
    end
    
    -- top-right or bottom-left
    if Pos.X + Pos.Y == 1 then
        return "rbxasset://textures/StudioUIEditor/icon_resize1.png"
    end
    
    -- left or right
    if Pos.X ~= 0.5 then
        return "rbxasset://textures/StudioUIEditor/icon_resize2.png"
    end

    -- bottom or top
    return "rbxasset://textures/StudioUIEditor/icon_resize4.png"
end

local usingMouse: RBXScriptConnection?
local mouseEndConnection: RBXScriptConnection?
local function disconnectMouse()
    if usingMouse then
        usingMouse:Disconnect()
        usingMouse = nil
    end

    if mouseEndConnection then
        mouseEndConnection:Disconnect()
        mouseEndConnection = nil
    end
end

local function useMouse(callback: (InputObject) -> ())
    disconnectMouse()

    usingMouse = UserInputService.InputChanged:Connect(callback)
    mouseEndConnection = UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            disconnectMouse()
        end
    end)
end

local function setResizing(Window: GuiObject, Input: InputObject, minSize)
    local Pos = Vector2.new(Input.Position.X, Input.Position.Y)
    local Rect = Common.getBoundingRect(Window, RESIZE_RECT_PADDING)

    local InvertedAnchor = Vector2.one - Common.getRelativePos(Pos, Rect, RESIZE_CORNER_SIZE)  -- The anchor point opposite to where the mouse is
    local absAnchorPosition = Common.setAbsoluteAnchor(Window, InvertedAnchor) -- Absolute position of the new anchor point
    
    useMouse(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            local signAnchor = (InvertedAnchor*2) - Vector2.one -- 0 (left) 0.5 (mid) 1(right) becomes -1, 0, 1
            local Size = Vector2.new(
                (absAnchorPosition.X - Input.Position.X) * math.sign(signAnchor.X),
                (absAnchorPosition.Y - Input.Position.Y) * math.sign(signAnchor.Y)
            ):Max(minSize)
            
            local X = Size.X + RESIZE_RECT_PADDING
            local Y = Size.Y + RESIZE_RECT_PADDING
            if InvertedAnchor.X == 0.5 then
                X = Window.AbsoluteSize.X
            elseif InvertedAnchor.Y == 0.5 then
                Y = Window.AbsoluteSize.Y
            end

            Window.Size = UDim2.fromOffset(X, Y)
        end
    end)
end

local focusChangeEvent = Instance.new('BindableEvent')
local focusChanged = focusChangeEvent.Event

return function(props: {
    BindToClose: (() -> ())?,
    Parent: ScreenGui?,
    Content: Instance?,
    Title: string?,
    Enabled: boolean?,
    minSize: Vector2?,
    Size: Vector2?,
    Position: Vector2?,
    CornerRadius: UDim?
} & React.ElementProps<Frame>)
    local theme = Common.useTheme()

    local Title = props.Title
    if Title == "" then Title = nil end

    local Enabled = props.Enabled == nil and true or props.Enabled

    local minSize = props.minSize or Vector2.new(60, 65)
    local Size = (props.Size or Vector2.new(150, 200)):Max(minSize)
    local Position = props.Position or Vector2.new(200, 140)
    local CornerRadius = props.CornerRadius or UDim.new(0, 6)

    local contentContainerRef = React.useRef(nil)
    local floatingWidgetRef = React.useRef(nil)

    -- Parent Instance content to contentContainer
    React.useEffect(function()
        if props.Content then
            props.Content.Parent = contentContainerRef.current
        end

        return function()
            if props.Content then props.Content.Parent = nil end
        end
    end, {contentContainerRef, props.Content})

    
    local isFocused = React.useRef(false)
    local function setFocused(focused: boolean)
        isFocused.current = focused

        if props.Parent then
            props.Parent.DisplayOrder = focused and 170 or 150
        end
    end

    React.useEffect(function()
        local event = focusChanged:Connect(function()
            if isFocused.current then setFocused(false) end
        end)
        
        return function()
            event:Disconnect()
            isFocused.current = false
        end
    end, {})

    local isResizable = false
    local function onWindowInput(Window: GuiObject, Input: InputObject)
        local isDown = Input.UserInputState == Enum.UserInputState.Begin
        if not isDown and Input.UserInputType == Enum.UserInputType.MouseMovement then
            if not usingMouse then Common.overrideCursor() end
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        -- Gain exclusive focus on click
        if isDown and not isFocused.current then
            focusChangeEvent:Fire()
            setFocused(true)
        end

        if not isDown and usingMouse then
            disconnectMouse()

            Common.overrideCursor("")
            Common.setAbsoluteAnchor(Window, Vector2.zero)
        end

        if not isResizable or not isDown then return end
        setResizing(Window, Input, minSize)
    end

    local function setDragging(TitleBar: GuiObject, Input: InputObject)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or usingMouse then return end

        local isDown = Input.UserInputState == Enum.UserInputState.Begin
        if isDown and not isResizable then
            local Frame = floatingWidgetRef.current
            if not Frame then return end

            local insetOffsetY = 0 
            local screenGui = Frame:FindFirstAncestorWhichIsA('LayerCollector')
            if screenGui then insetOffsetY = screenGui.AbsolutePosition.Y end
            
            local PosDelta = Vector2.new(Frame.AbsolutePosition.X, Frame.AbsolutePosition.Y - insetOffsetY) - UserInputService:GetMouseLocation()

            useMouse(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Pos = UserInputService:GetMouseLocation() + PosDelta
                    Frame.Position = UDim2.fromOffset(Pos.X, Pos.Y)
                end
            end)
        end
    end

    local function UICorner()
        return React.createElement('UICorner', {
            key = 'UICorner',
            CornerRadius = CornerRadius
        })
    end

    -- Covers the bottom of a UICorner frame
    local function BottomCover(color: Color3, transp: number?)
        return React.createElement('Frame', {
            key = 'BottomCover',
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, CornerRadius.Scale, CornerRadius.Offset),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = color,
            BackgroundTransparency = transp or 0,
            BorderSizePixel = 0
        })
    end

    local TitleBarColor = theme:GetColor(theme.StudioStyleGuideColor.Titlebar)
    local OutlineColor = theme:GetColor(theme.StudioStyleGuideColor.SubText)
    local outlinePad = 1

    local Window = React.createElement('Frame', {
        key = 'DockWidget',
        Visible = Enabled,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = OutlineColor,
        BackgroundTransparency = 0.5,
    }, {
        UICorner(),
        BottomCover(OutlineColor, 0.4),
        TitleBar = React.createElement('Frame', {
            Position = UDim2.new(0.5, 0, 0, outlinePad),
            Size = UDim2.new(1, -2*outlinePad, 0, TITLEBAR_HEIGHT),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = TitleBarColor,
            ClipsDescendants = true,
            ZIndex = 2,
            [React.Event.InputBegan] = setDragging,
            [React.Event.InputEnded] = setDragging
        }, {
            UICorner(),
            BottomCover(TitleBarColor),
            Title = Title and React.createElement(Label, {
                ZIndex = 2,
                Text = Title,
                StyleGuide = { TextColor = theme.StudioStyleGuideColor.TitlebarText }
            }),
            CloseButton = React.createElement(BaseButton, {
                ZIndex = 2,
                Size = UDim2.fromOffset(14, 14),
                Position = UDim2.new(1, -6, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                StyleGuide = { defaultTransparent = true },
                OnActivated = props.BindToClose or function()
                    if props.Parent then
                        props.Parent.Enabled = false
                    end
                end
            }, {
                X = React.createElement(Icon, {
                    ZIndex = 2,
                    Icon = 'CloseWidget'
                })
            })
        }),
        InnerFrame = React.createElement('Frame', {
            ref = contentContainerRef,
            Size = UDim2.new(1, -2*outlinePad, 1, -24 - 2*outlinePad),
            Position = UDim2.new(0.5, 0, 1, -outlinePad),
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = theme:GetColor(theme.StudioStyleGuideColor.MainBackground),
            BorderSizePixel = 0,
            ClipsDescendants = true
        }, props.children)
    })

    -- Pad window for bigger resize area
    Window = React.createElement('Frame', {
        ref = floatingWidgetRef,
        Active = true,
        BackgroundTransparency = 1,

        Size = UDim2.fromOffset(Size.X + RESIZE_RECT_PADDING*2, Size.Y + RESIZE_RECT_PADDING*2),
        Position = UDim2.fromOffset(Position.X + RESIZE_RECT_PADDING, Position.Y + RESIZE_RECT_PADDING),

        [React.Event.InputChanged] = function(Frame, Input: InputObject)
            if usingMouse then return end

            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                local Rect = Common.getBoundingRect(Frame, RESIZE_RECT_PADDING)
                local RelativeVec = Common.getRelativePos(Vector2.new(Input.Position.X, Input.Position.Y), Rect, RESIZE_CORNER_SIZE)

                isResizable = RelativeVec ~= Vector2.new(0.5, 0.5)
                Common.overrideCursor(getMouseIcon(RelativeVec))
            end
        end,
        [React.Event.InputBegan] = onWindowInput,
        [React.Event.InputEnded] = onWindowInput
    }, {
        UIPadding = React.createElement('UIPadding', {
            PaddingTop = UDim.new(0, RESIZE_RECT_PADDING),
            PaddingBottom = UDim.new(0, RESIZE_RECT_PADDING),
            PaddingLeft = UDim.new(0, RESIZE_RECT_PADDING),
            PaddingRight = UDim.new(0, RESIZE_RECT_PADDING)
        }),
        Window
    })

    return props.Parent and ReactRoblox.createPortal(Window, props.Parent) or Window
end
