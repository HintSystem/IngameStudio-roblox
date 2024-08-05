--!strict
local EnumItem = {}

--[[
    This EnumItem type is meant for internal use only, as the regular EnumItem type makes it easier to define one
    The EnumParent is just Enum<CustomEnum>
--]]
type internalEnumItem<EnumParent> = typeof(setmetatable({} :: {
    Name: string,
    Value: number,
    EnumType: EnumParent,
}, {}))

-- Preferred way of using EnumItem, making it shorter
export type EnumItem<CustomEnum> = internalEnumItem<Enum<CustomEnum>>

function EnumItem.new<EnumParent>(Name: string, Value: number, EnumParent: EnumParent): internalEnumItem<EnumParent>
    return setmetatable({
        Name = Name,
        Value = Value,
        EnumType = EnumParent
    }, {
        __tostring = function(self: internalEnumItem<EnumParent>): string
            return `Enum.{tostring(self.EnumType)}.{self.Name}`
        end,
        __eq = function(self, v)
            if getmetatable(v).__type == 'EnumItem' then
                return tostring(self) == tostring(v)
            end
            return false
        end,
        __type = 'EnumItem'
    })
end

--------------------

local Enum = { public = {} }
Enum.__meta = {
    __index = function(self, i)
        if self._EnumValues[i] then
            -- Dynamically load a new EnumItem
            return EnumItem.new(i, self._EnumValues[i], self)
        end
        return Enum.public[i]
    end,
    __tostring = function(self)
        return self._EnumType
    end,
    __type = 'Enum'
}

--[=[
    EnumType is the name of the Enum (Enum.FillDirection) \
    EnumValues contain all the options for the Enum (Horizontal=0, Vertical=1) \
    Since EnumValues contains the entire Enum definition and is required for typechecking to work, its type will be called CustomEnum and will be reused in many type definitions
]=]
function Enum.new<CustomEnum>(EnumType: string, EnumValues: CustomEnum & {[string]: number} )
    return setmetatable({
        _EnumType = EnumType,
        _EnumValues = EnumValues
    }, Enum.__meta) :: Enum<CustomEnum>
end

function Enum.public:GetEnumItems()
    -- Invert dictionary, [EnumName] = EnumValue becomes [EnumValue] = EnumName
    local Items = {}
    for i, v in self._EnumValues do
        Items[v+1] = i 
    end
    
    -- Remove gaps in dictionary, because Enum.StudioStyleGuideColor has missing Enum Values between 119 and 128
    local Array = {}
    for i, v in Items do table.insert(Array, EnumItem.new(v, self._EnumValues[v], self)) end

    return Array
end

export type Enum<CustomEnum> = typeof(setmetatable({} :: any, {}))
& (CustomEnum & {[string]: EnumItem<CustomEnum>})
& typeof(Enum.public)

return Enum