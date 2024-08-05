local Themes = {}

-- Custom Enums must be implemented because StudioStyleGuide Enums do not exist on the Roblox client
local EnumDefs = require(script.Parent.EnumDefinitions)

local ThemeChanged = Instance.new("BindableEvent")
Themes.ThemeChanged = ThemeChanged.Event

local ThemeInstance = { public = {} }

export type ThemeInstance = typeof(setmetatable({} :: {
	Name: string
}, {} :: { __index: typeof(ThemeInstance.public) }))

function ThemeInstance.new(Theme: ModuleScript): ThemeInstance
	return setmetatable({
		Name = Theme.Name,
		_themeData = require(Theme)
	}, { __index = ThemeInstance.public })
end

function ThemeInstance.public:GetColor(Color: EnumDefs.StudioStyleGuideColor, Modifier: EnumDefs.StudioStyleGuideModifier?)
	local Group = self._themeData[Color.Value]

	if Modifier and Group[Modifier.Value] then
		return Group[Modifier.Value]
	end

	return Group[0]
end

local Icons = require(script.Parent.Icons)
function ThemeInstance.public:GetIcon(iconName: string, size: Icons.Size?, scale: number?)
	local icon = Icons.Other:Get(iconName, self.Name, size, scale)
	if not icon then error(`Icon '{iconName}' does not exist`, 2) end

	return icon
end

function ThemeInstance.public:GetClassIcon(className: string, size: Icons.Size?, scale: number?)
	local icon = Icons.InsertableObjects:Get(className, self.Name, size, scale)
	if not icon then error(`Class icon '{className}' does not exist`, 2) end

	return icon
end

ThemeInstance.public.StudioStyleGuideColor = EnumDefs.StudioStyleGuideColor
ThemeInstance.public.StudioStyleGuideModifier = EnumDefs.StudioStyleGuideModifier

local LoadedThemes = {} :: {[string]: ThemeInstance}

local function loadThemes()
	for _, ThemeModule in script:GetChildren() do
		LoadedThemes[ThemeModule.Name] = ThemeInstance.new(ThemeModule)
	end
end
loadThemes()

Themes.Theme = LoadedThemes['Dark']

function Themes:GetAvailableThemes()
	local ThemeArray = {}

	local insertedThemes = {}
	for i, ThemeEnum in EnumDefs.UITheme:GetEnumItems() do
		if not LoadedThemes[ThemeEnum.Name] then
			warn(`PluginProxy has not implemented the built-in theme '{ThemeEnum.Name}'`)
		end
		
		insertedThemes[ThemeEnum.Name] = true
		ThemeArray[i] = LoadedThemes[ThemeEnum.Name]
	end

	for i, v in LoadedThemes do
		if insertedThemes[i] then continue end
		table.insert(ThemeArray, v)
	end

	return ThemeArray
end

return setmetatable(Themes, {
	__newindex = function(self, index, value)
		if index == "Theme" and LoadedThemes[value] then
			Themes.Theme = value
			ThemeChanged:Fire()
			return
		end
	end,
})