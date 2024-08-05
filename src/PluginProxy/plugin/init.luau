local plugin = {
	public = {
		ClassName = "Plugin",

		CollisionEnabled = false,
		GridSize = 0.1,
	}
}

local Settings = require(script.Parent.Settings)
local EnumDefs = require(script.Parent.EnumDefinitions)
local DockWidget = require(script.DockWidget)

local pluginGlobals = {
	DockWidgetPluginGuiInfo = DockWidget.DockWidgetPluginGuiInfo,
	Enums = EnumDefs,
	game = setmetatable(require(script.Parent.Services), {
		__index = game
	}),
	settings = function() return Settings end
} :: {
	DockWidgetPluginGuiInfo: typeof(DockWidget.DockWidgetPluginGuiInfo),
	Enums: typeof(EnumDefs),
	game: DataModel,
	settings: () -> typeof(Settings)
}

type Globals = typeof(setmetatable({} :: {
	plugin: plugin
}, {} :: typeof({ __index = pluginGlobals }) ))

export type PluginModule = {
	init: (Globals) -> (),
	Name: string?,
	UID: number | string | nil,
	Globals: Globals -- Automatically added during plugin loading
}

type plugin = typeof(setmetatable({} :: {
	Name: string,
	_uid: number | string
}, {} :: typeof({ __index = plugin.public })))

local CreatedPlugins = {}
function plugin.new(pluginModule: ModuleScript)
	local moduleData = require(pluginModule) :: PluginModule
	local UID = moduleData.UID or pluginModule.Name -- For now the unique id is just the name, since generating one wouldn't be ideal

	local ExistingPlugin = CreatedPlugins[UID]
	if ExistingPlugin then
		warn(`A plugin of UID '{UID}' already exists. To fix this rename`, pluginModule, 'to something else or add a UID item/property in the module to make it unique.')
		return
	end

	if not moduleData.init then
		warn('The plugin', pluginModule, 'does not have an init function')
		return
	end

	local self = setmetatable({
		Name = moduleData.Name or pluginModule.Name,
		
		_uid = UID,
		_script = pluginModule,
		_events = {
			Deactivation = Instance.new("BindableEvent"),
			Unloading = Instance.new("BindableEvent")
		},
		_thread = nil
	}, { __index = plugin.public })
	
	for EventName: string, Event: BindableEvent in pairs(self._events) do
		self[EventName] = Event.Event
	end

	local newGlobals = setmetatable({
		plugin = self,
	}, { __index = pluginGlobals })
	
	moduleData.Globals = newGlobals

	-- Run plugin in seperate thread to prevent Ingame Studio from crashing due to errors
	self._thread = task.spawn(function() moduleData.init(newGlobals) end)
	
	CreatedPlugins[UID] = self
end

local Toolbar = require(script.Toolbar)
local RibbonTools = require(script.Parent.RibbonTools)

function plugin.public:CreateDockWidgetPluginGui(pluginGuiId: string, dockWidgetPluginGuiInfo: DockWidget.WidgetPluginGuiInfo)
	if typeof(dockWidgetPluginGuiInfo) == "DockWidgetPluginGuiInfo" then
		error("Using incorrect constructor for DockWidgetPluginGuiInfo, use _proxyGlobals.DockWidgetPluginGuiInfo instead", 2)
	end

	return DockWidget.new(self, pluginGuiId, dockWidgetPluginGuiInfo)
end

function plugin.public:CreateToolbar(name: string)
	return Toolbar.new(self, name)
end

function plugin.public:GetSelectedRibbonTool()
	return RibbonTools.GetSelected()
end

function plugin.public:SelectRibbonTool(tool: Enum.RibbonTool, position: UDim2)
	RibbonTools.Select(tool, true)
end

local ActivePlugin = nil
function plugin.public:Activate(exclusiveMouse: boolean)
	if ActivePlugin then
		ActivePlugin._events.Deactivation:Fire()
	end
	
	ActivePlugin = self
end

function plugin.public:Deactivate()
	if ActivePlugin == self then
		self._events.Deactivation:Fire()
		ActivePlugin = nil
	end
end

function plugin.public:IsActivated()
	return ActivePlugin == self
end

function plugin.public:GetJoinMode() return Enum.JointCreationMode.None end

function plugin.public:GetMouse()
	if not self:IsActivated() then return end
	return game:GetService('Players').LocalPlayer:GetMouse()
end

-- Might want to use data store in the future
local pluginSettings = {}
local function getPluginSettingsStore(pluginId)
	if not pluginSettings[pluginId] then
		pluginSettings[pluginId] = {}
	end
	return pluginSettings[pluginId]
end

function plugin.public:GetSetting(key: string): any?
	return getPluginSettingsStore(self._uid)[key]
end

function plugin.public:SetSetting(key: string, value: any?)
	getPluginSettingsStore(self._uid)[key] = value
end

function plugin.public:FindFirstChild(name: string, recursive: boolean?)
	return self._script:FindFirstChild(name, recursive)
end


-- Private functions, internal use only


function plugin.Destroy(self)
	for i, Event: BindableEvent in pairs(self._events) do
		Event:Destroy()
	end
	self._events = nil

	-- Not sure how plugin threads should be closed
	task.delay(2, function()
		if not self._thread then return end
		task.cancel(self._thread)
	end)
end

function plugin.unloadPlugins()
	for i, self in pairs(CreatedPlugins) do
		self._events.Unloading:Fire()
		plugin.Destroy(self)
	end
end

return plugin