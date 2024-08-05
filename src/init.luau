local IngameStudio = {}

local ReactRoblox = require(script.Packages["react-roblox"])

local PluginProxy = require(script.PluginProxy)
local App = require(script.App)

local ScreenGui = nil
local Root = nil

local function createRoot()
    if not ScreenGui then
        ScreenGui = Instance.new('ScreenGui')
        ScreenGui.Name = 'In-game Studio'
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 100
        ScreenGui.Parent = game:GetService('Players').LocalPlayer.PlayerGui
    end
    if not Root then
        Root = ReactRoblox.createRoot(ScreenGui)
    end
end

function IngameStudio.Show()
    createRoot()

    Root:render(App())
end

function IngameStudio.Hide()
    if Root then
        Root.unmount()
        Root = nil
    end
end

return setmetatable(IngameStudio, { __index = PluginProxy })