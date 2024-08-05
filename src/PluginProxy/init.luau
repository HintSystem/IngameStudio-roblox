local PluginProxy = {}

local defaultPluginsFolder = script.Parent:FindFirstChild('Plugins')

local plugin = require(script.plugin)

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

return PluginProxy