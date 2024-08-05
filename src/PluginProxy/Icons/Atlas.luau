--!strict
local BaseAtlas = { public = {} }
BaseAtlas.meta = { __index = BaseAtlas.public }

type AtlasTable = {
	Asset: string,
	Size: number
}

type BaseAtlas = typeof(setmetatable({} :: {
	Atlases: {AtlasTable},
	ItemSize: number
}, BaseAtlas.meta))

export type ImageProps = {
	Image: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2
}

local function newAtlasTable(asset: string, atlasSize: number): AtlasTable
	return { Asset = asset, Size = atlasSize }
end

function BaseAtlas.new(asset: string, atlasSize: number, itemSize: number): BaseAtlas
	local Atlases = {}
	table.insert(Atlases, newAtlasTable(asset, atlasSize))

	return setmetatable({
		Atlases = Atlases,
		ItemSize = itemSize
	}, BaseAtlas.meta)
end

--- Extends the atlas with another asset, use this if the max size of 1024 is reached, ItemSize must be the same
function BaseAtlas.public:Extend(asset: string, atlasSize: number)
	table.insert(self.Atlases, newAtlasTable(asset, atlasSize))
	return self
end

--- Get Image properties from an identifier that starts from 0
function BaseAtlas.public:Get(identifier: number): ImageProps?
	self = self :: BaseAtlas -- Type error on next line otherwise
	local id = identifier

	local itemsPerAtlas = ((self.Atlases[1].Size // self.ItemSize) ^ 2)
	local atlasIndex = (id // itemsPerAtlas) + 1
	local localIdentifier = (id % itemsPerAtlas)

	if atlasIndex > #self.Atlases then -- Reached end of atlas list
		return nil
	end

	local atlas = self.Atlases[atlasIndex]

	local rowItems = atlas.Size // self.ItemSize

	local x = (localIdentifier % rowItems) * self.ItemSize
	local y = (localIdentifier // rowItems) * self.ItemSize

	if y > atlas.Size then -- Reached end of atlas
		return nil
	end

	return {
		Image = atlas.Asset,
		ImageRectOffset = Vector2.new(x, y),
		ImageRectSize = Vector2.new(self.ItemSize, self.ItemSize)
	}
end


local Atlas = { public = {} }
Atlas.meta = { __index = Atlas.public }

type AtlasOrder = {[string]: number}

type Atlas = typeof(setmetatable({} :: {
	Order: AtlasOrder,
	MaxId: number,
	Default: BaseAtlas,
	Scales: {[number]: BaseAtlas}
}, Atlas.meta))

function Atlas.new(atlasOrder: AtlasOrder, defaultAtlas: BaseAtlas): Atlas
	local MaxId = 0
	for _, v in atlasOrder do
		MaxId = math.max(MaxId, v)
	end

	return setmetatable({
		Order = atlasOrder,
		MaxId = MaxId,
		Default = defaultAtlas,
		Scales = {}
	}, Atlas.meta)
end

--- Get Image properties from identifier and scale
function Atlas.public:Get(identifier: string | number, scale: number?): ImageProps?
	self = self :: Atlas -- Type errors otherwise

	if type(identifier) == "string" then
		identifier = self.Order[identifier]
		if not identifier then return nil end
	end

	local minScale = 1
	local scaledAtlas = self.Default
	if scale then
		for atlasScale, atlas in self.Scales do
			if atlasScale > minScale and atlasScale >= scale then
				minScale = atlasScale
				scaledAtlas = atlas
			end
		end
	end

	return scaledAtlas:Get(identifier :: number)
end

--- Adds a new atlas containing a different scale for icons (1.5x, 2x res)
function Atlas.public:AddScale(scale: number, scaledAtlas: BaseAtlas)
	self.Scales[scale] = scaledAtlas
	return self
end

local StudioIconAtlas = { public = {} }
StudioIconAtlas.meta = { __index = StudioIconAtlas.public }

type StudioIconAtlas = typeof(setmetatable({} :: {
	Default: Atlas,
	Sizes: {[number]: Atlas}
}, StudioIconAtlas.meta))

type SizeName = "Standard" | "Medium" | "Large"
export type AtlasSize = number | SizeName

type IconTheme = "Dark" | "Light"

local function atlasSizeToNum(size: AtlasSize): number
	if type(size) == "number" then
		return size
	end

	if size == "Standard" then
		return 16
	elseif size == "Medium" then
		return 24
	elseif size == "Large" then
		return 32
	end
	error(`Atlas size name of '{size}' does not exist`, 3)
end

function StudioIconAtlas.new(size: AtlasSize, sizedAtlas: Atlas): StudioIconAtlas
	local Sizes = { [atlasSizeToNum(size)] = sizedAtlas } :: {[number]: Atlas}

	return setmetatable({
		Default = sizedAtlas,
		Sizes = Sizes
	}, StudioIconAtlas.meta)
end

function StudioIconAtlas.public:Get(identifier: string | number, theme: IconTheme?, size: AtlasSize?, scale: number?): ImageProps?
	if not theme then theme = "Dark" end
	if size then size = atlasSizeToNum(size) end

	local sizedAtlas = self.Default
	if size then
		local newSizeAtlas = self.Sizes[size]
		if newSizeAtlas then
			sizedAtlas = newSizeAtlas :: Atlas
		end
	end

	if type(identifier) == "string" and theme == "Light" then
		local id = sizedAtlas.Order[identifier]
		if not id then return nil end
		identifier = id + (sizedAtlas.MaxId + 1)
	end

	return sizedAtlas:Get(identifier, scale)
end

--- Adds a new atlas containing a different size of icon (Standard / Medium / Large)
function StudioIconAtlas.public:AddSize(size: AtlasSize, sizedAtlas: Atlas)
	self.Sizes[atlasSizeToNum(size)] = sizedAtlas
	return self
end

return {
	new = Atlas.new,

	BaseAtlas = BaseAtlas,
	StudioIconAtlas = StudioIconAtlas
}