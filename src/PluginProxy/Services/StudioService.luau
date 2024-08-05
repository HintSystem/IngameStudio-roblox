local StudioService = {}

local Themes = require(script.Parent.Parent.Themes)
function StudioService:GetClassIcon(className: string)
    return Themes.Theme:GetClassIcon(className, nil, nil)
end

return StudioService