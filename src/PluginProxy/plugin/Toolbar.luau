local Toolbar = {
	public = {
		ClassName = "PluginToolbar"
	}
}

local Implementation = require(script.Parent.Interface.Implementation)
Toolbar.Interface = nil :: Implementation.internal<Toolbar>?

local ToolbarButton = {}

type Toolbar = typeof(setmetatable({} :: {
	Name: string,
	Title: string,
	LayoutOrder: number,
	Buttons: { [string]: ToolbarButton },
	_uid: string
}, {} :: typeof({ __index = Toolbar.public })))

function Toolbar.new(plugin, name: string): Toolbar
	local UID = name

	local ExistingToolbar = Toolbar.Interface.InstanceList:Get(plugin._uid, UID)
	if ExistingToolbar then return ExistingToolbar end

	local self = setmetatable({
		Name = "Instance",
		Title = name,
		LayoutOrder = #Toolbar.Interface.InstanceList,
		Buttons = {},
		_plugin_uid = plugin._uid,
		_uid = UID,
		_Destroying = Instance.new('BindableEvent'),
	}, { __index = Toolbar.public })
	self.Destroying = self._Destroying.Event

	Toolbar.Interface:Created(self, plugin._uid, UID)

	return self
end

function Toolbar.public:Destroy()
	self._Destroying:Fire()
	self._Destroying:Destroy()

	self.Buttons = nil
	Toolbar.Interface:Destroy(self, self._plugin_uid, self._uid)
end

type ToolbarButton = typeof(setmetatable({} :: {
	Click: RBXScriptSignal,
	Destroying: RBXScriptSignal,

	Text: string,
	Image: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
	Enabled: boolean,
	Active: boolean,
	ClickableWhenViewportHidden: boolean,
	_uid: string
}, {} :: typeof({ __index = ToolbarButton })))

function Toolbar.public:CreateButton(buttonId: string, tooltip: string, iconname: string?, text: string?): ToolbarButton
	local currentToolbar = self :: Toolbar
	local ExistingButton = self.Buttons[buttonId]
	if ExistingButton then
		error(`Cannot create more than one button with id "{buttonId}" in toolbar with id "{currentToolbar.Title}"`, 2)
	end

	local events = {
		Click = Instance.new('BindableEvent'),
		Destroying = Instance.new('BindableEvent')
	}

	local metaContents = {
		Properties = {
			Text = text or buttonId,
			Image = iconname or "",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0),
			Enabled = true,
			Active = false,
			ClickableWhenViewportHidden = false,
		},
		_events = events,
		_uid = buttonId
	}

	for i, v in events do metaContents[i] = v.Event end

	local newButton = setmetatable(metaContents, {
		__newindex = function(self, i, v)
			if v == nil then return end
			
			if self.Properties[i] ~= nil then
				self.Properties[i] = v
				Toolbar.Interface:Changed(currentToolbar)
			end
		end,
		__index = function(self, i)
			if i == '_toolbar' then return currentToolbar end -- Use metamethod to avoid cyclic tables error 

			local Property = self.Properties[i]
			if Property ~= nil then return Property end

			return ToolbarButton[i]
		end
	})

	currentToolbar.Buttons[buttonId] = newButton
	Toolbar.Interface:Changed(currentToolbar)

	return newButton
end

function ToolbarButton:SetActive(active: boolean)
	self.Active = active
end

function ToolbarButton:Destroy()
	self._events.Destroying:Fire()

	self._toolbar.Buttons[self._uid] = nil
	setmetatable(self, nil)
	
	Toolbar.Interface:Changed(self._toolbar)
end

return Toolbar
