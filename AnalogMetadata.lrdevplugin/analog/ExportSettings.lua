require 'Use'
local DefaultMetadataMap = use 'analog.DefaultMetadataMap'

local function filmTag(destination)
    if destination == 'make' then
        return 'Make'
    end
    return 'XMP-AnalogExif:Film'
end

local function metadataMap(properties)
    local result = {}
    for _, pair in ipairs(DefaultMetadataMap) do
        table.insert(result, {
            key = pair.val == 'Frame_EmulsionName'
                and filmTag(properties and properties.filmStockDestination) or pair.key,
            val = pair.val,
        })
    end
    return result
end

return {
    presetFields = {{ key = 'filmStockDestination', default = 'xmp' }},
    filmTag = filmTag,
    metadataMap = metadataMap,
}
