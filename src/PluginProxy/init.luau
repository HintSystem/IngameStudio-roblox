local PluginProxy = {}

local defaultPluginsFolder = script.Parent:FindFirstChild('Plugins')

local plugin = require(script.plugin)
local DockWidget = require(script.plugin.DockWidget)

--- Loads and activates all plugins within a folder, folder defaults to PluginProxy.Parent.Plugins
function PluginProxy.LoadPlugins(PluginsFolder: Folder?)
	PluginsFolder = PluginsFolder or defaultPluginsFolder
	if not PluginsFolder then
		warn('Plugins did not load because no plugin folder was found.')
		return
	end

	for i, Module in PluginsFolder:GetChildren() do
		if not Module:IsA('ModuleScript') then return end

		plugin.new(Module)
	end
end

--- Sets the location for all plugin created DockWidgets
function PluginProxy.SetDockWidgetParentGui(gui: LayerCollector)
	DockWidget.SetParentGui(gui)
end

return PluginProxy