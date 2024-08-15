local ReflectionService = {}

local metadata = require(script.metadata) :: {[string]: ClassMetadata}

type ClassMetadata = {
    ClassCategory: string?,
    PreferredParent: string?,
    ExplorerOrder: number?
}

local database = require(script.database) :: database

type TagType = "ReadOnly" | "WriteOnly" | "Hidden" | "Deprecated"
| "PlayerReplicated" | "NotReplicated" | "NotCreatable" | "NotScriptable" | "NotBrowsable" 
| "Service" | "Settings" | "UserSettings"

type Scriptability = "Read" | "Write" | "ReadWrite" | "Custom" | "None"
type Serialization = "DoesNotSerialize" | "Serializes" | {
    SerializesAs: string?, -- serialized name in xml
    Migrate: {
        To: string, -- type to migrate to
        Migration: string -- conversion function name
    }?
}

type PropertyInfo = {
    Name: string,
    Scriptability: Scriptability,
    Tags: {TagType},
    Kind: {
        Canonical: { Serialization: Serialization }?,
        Alias: { AliasFor: string }?
    }
}

type ClassInfo = {
    Name: string,
    Superclass: string,
    Properties: {[string]: PropertyInfo},
    DefaultProperties: {[string]: any},
    Tags: {string},
}

type EnumInfo = {
    name: string,
    items: {[string]: number}
}

type database = {
    Version: {number},
    Classes: {[string]: ClassInfo},
    Enums: {[string]: EnumInfo}
}

--- Returns the API version of the database and Roblox
function ReflectionService:GetVersions()
    local ver = string.split(version(), '.')
    for i, v in ver do
        ver[i] = tonumber(v)
    end

    return database.Version, ver
end

local DBVer, RobloxVer = ReflectionService:GetVersions()
if RobloxVer[2] - 5 > DBVer[2] then
    warn(`ReflectionService database is outdated by {RobloxVer[2] - DBVer[2]} major revisions. Consider updating the database.`)
    warn(`latest: ({table.concat(RobloxVer, '.')}), current: ({table.concat(DBVer, '.')})`)
end


function ReflectionService:GetClassInfo(ClassName: string)
    return database.Classes[ClassName]
end

function ReflectionService:GetMetadata(ClassName: string)
    return metadata[ClassName]
end

--- Checks if `ClassName` is a descendant of `Class`
function ReflectionService:ClassIsA(ClassName: string, Class: string)
    local foundClass = ReflectionService:GetClassInfo(ClassName)
    if not foundClass then
        warn(`Class '{ClassName}' doesn't exist in the reflection database, consider updating it or correcting the ClassName`)
        return
    end

    if not foundClass.Superclass then return false end
    if foundClass.Superclass == Class then return true end

    return ReflectionService:ClassIsA(foundClass.Superclass, Class)
end

return ReflectionService