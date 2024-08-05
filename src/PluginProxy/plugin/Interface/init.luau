--!strict

local Interface = {}

local Implementation = require(script.Implementation)

local Toolbar = require(script.Parent.Toolbar)
local DockWidget = require(script.Parent.DockWidget)

Interface.Toolbar = Implementation.new(Toolbar)

--- When implementing DockWidget, all content of the widget must be parented to DockWidget.Content
Interface.DockWidget = Implementation.new(DockWidget)

return Interface