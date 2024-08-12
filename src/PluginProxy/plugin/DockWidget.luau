local DockWidget = { 
    public = {
        ClassName = 'DockWidgetPluginGui'
    }
}

local GuiInfo = {}

type GuiInfo = {
    initDockState: Enum.InitialDockState, initEnabled: boolean, overrideEnabledRestore: boolean,
    floatXSize: number, floatYSize: number, minWidth: number, minHeight: number
}

type GuiInfoAliases = {
    InitialEnabled: boolean, InitialEnabledShouldOverrideRestore: boolean,
    FloatingXSize: boolean, FloatingYSize: boolean, MinWidth: number, MinHeight: number
}

-- These properties are listed in the DockWidgetPluginGuiInfo docs and autocomplete, so let the plugin have access to them
local aliases = {
    InitialEnabled = "initEnabled",
    InitialEnabledShouldOverrideRestore = "overrideEnabledRestore",
    FloatingXSize = "floatXSize",
    FloatingYSize = "floatYSize",
    MinWidth = "minWidth",
    MinHeight = "minHeight"
}

-- WidgetInfo defaults to this if some props are not present
local guiInfoDefault = {
    initDockState = Enum.InitialDockState.Float,
    initEnabled = false, 
    overrideEnabledRestore = false,
    floatXSize = 100,
    floatYSize = 100,
    minWidth = 40,
    minHeight = 40
} :: GuiInfo

local meta = {
    __index = function(self, i)
        local index = aliases[i]
        if index then
            return self[index]
        end
        return guiInfoDefault[i]
    end
}

export type WidgetPluginGuiInfo = typeof(setmetatable({} :: GuiInfo, meta))

-- Cannot get properties from DockWidgetPluginGuiInfo, so a new class must be created
function GuiInfo.new(initDockState: Enum.InitialDockState?, initEnabled: boolean?, overrideEnabledRestore: boolean?,
    floatXSize: number?, floatYSize: number?, minWidth: number?, minHeight: number?)
    return setmetatable({
        initDockState = initDockState,
        initEnabled = initEnabled,
        overrideEnabledRestore = overrideEnabledRestore,
        floatXSize = floatXSize,
        floatYSize = floatYSize,
        minWidth = minWidth,
        minHeight = minHeight
    }, meta) :: WidgetPluginGuiInfo
end

DockWidget.DockWidgetPluginGuiInfo = GuiInfo

local Implementation = require(script.Parent.Interface.Implementation)
DockWidget.Interface = nil :: Implementation.internal<DockWidget>?

type UID = string | number
type DockWidget = typeof(setmetatable({} :: {
    Gui: ScreenGui,
    Content: Frame,
    Info: DockWidgetPluginGuiInfo,
}, {} :: typeof({ __index = DockWidget.public }))) & {
    Title: string,
    HostWidgetWasRestored: false,
    Enabled: boolean,
    ResetOnSpawn: boolean,
    ZIndexBehavior: Enum.ZIndexBehavior
}

local ScreenGuiProps = {Enabled = true, ResetOnSpawn = true, ZIndexBehaviour = true}

local guiContainer -- Set by DockWidget.SetParentGui()
local defaultGuiContainer -- Created by this class
local function getGuiContainer()
    if not guiContainer and not defaultGuiContainer then
        defaultGuiContainer = Instance.new("ScreenGui")
        defaultGuiContainer.Name = "PluginProxy_Widgets"
        defaultGuiContainer.ResetOnSpawn = false
        defaultGuiContainer.Parent = game:GetService('Players').LocalPlayer.PlayerGui
    end
    return guiContainer or defaultGuiContainer
end

--- Sets the parent gui for all DockWidgets
function DockWidget.SetParentGui(gui: LayerCollector)
    if gui == nil then error("Can't set DockWidget container to nil") end
    if defaultGuiContainer then defaultGuiContainer:Destroy() end
    guiContainer = gui

    for _, Widget: DockWidget in DockWidget.Interface.InstanceList do
        Widget.Gui.Parent = gui
    end
end

function DockWidget.new(plugin, UID: UID, DockWidgetInfo: WidgetPluginGuiInfo): DockWidget
    local gui = Instance.new("ScreenGui")
    gui.Name = `p_{UID}`
    gui.Enabled = DockWidgetInfo.initEnabled
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 150
    gui.Parent = getGuiContainer()

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "PluginGuiContent"
    contentFrame.Size = UDim2.fromScale(1, 1)
    contentFrame.BackgroundTransparency = 1

    local self = setmetatable({
        Info = DockWidgetInfo,
        Gui = gui,
        Content = contentFrame,
        Properties = {
            Title = ""
        },
        _plugin_uid = plugin._uid,
        _uid = UID
    }, {
        __index = function(self, i)
            local classMethod = DockWidget.public[i]
            if classMethod then return classMethod end

            local editableProp = self.Properties[i]
            if editableProp then return editableProp end

            return rawget(self, 'Gui')[i]
        end,
        __newindex = function(self, i, v)
            if ScreenGuiProps[i] then
                gui[i] = v
                return
            end

            if self.Properties[i] ~= nil and v ~= nil then
                self.Properties[i] = v
                DockWidget.Interface:Changed(self)
            end
        end
    })

    DockWidget.Interface:Created(self, plugin._uid, UID)

    return self
end

-- Libraries like fusion sometimes attach to PropertyChangedSignal, so default it to the ScreenGui 
function DockWidget.public:GetPropertyChangedSignal(property: string)
    return rawget(self, 'Gui'):GetPropertyChangedSignal(property)
end

function DockWidget.public:Destroy()
    setmetatable(self, nil)

    self.Content:Destroy()
    self.Instance = nil

    DockWidget.Interface:Destroy(self)
end

return DockWidget