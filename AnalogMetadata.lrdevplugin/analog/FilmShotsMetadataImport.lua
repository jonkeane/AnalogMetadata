local log = require 'Logger' ("FilmShotsMetadataImport")

-- This is the toolkit identifier used by the legacy FilmLog / Film Shots
-- Lightroom plugin. Lightroom keeps a plug-in's custom metadata under this
-- identifier, independently of AnalogMetadata's own identifier (_PLUGIN).
local FILM_SHOTS_PLUGIN_ID = 'com.leaf500.filmlog.plugin.lr'

-- These are the AnalogMetadata fields that also existed in Film Shots. Keep
-- this explicit so the migration never imports Film Shots-only fields such as
-- Frame_Designator or Roll_Mode.
local FIELD_IDS = {
    'Frame_Index',
    'Roll_UID',
    'Roll_Status',
    'Roll_Name',
    'Roll_Comment',
    'Roll_Thumbnail',
    'Roll_CreationTimeUnix',
    'Roll_CameraName',
    'Roll_FormatName',
    'Frame_LocalTimeIso8601',
    'Frame_Thumbnail',
    'Frame_Latitude',
    'Frame_Longitude',
    'Frame_Locality',
    'Frame_Comment',
    'Frame_EmulsionName',
    'Frame_BoxISO',
    'Frame_RatedISO',
    'Frame_LensName',
    'Frame_FocalLength',
    'Frame_FStop',
    'Frame_Shutter',
}

local function importPhoto (photo)
    local importedFields = 0

    for _, fieldId in ipairs (FIELD_IDS) do
        local value = photo:getPropertyForPlugin (FILM_SHOTS_PLUGIN_ID, fieldId)

        -- A missing legacy value must not erase metadata already entered in
        -- AnalogMetadata. Empty strings are copied deliberately, since they
        -- represent an explicitly cleared legacy value.
        if value ~= nil then
            photo:setPropertyForPlugin (_PLUGIN, fieldId, tostring (value))
            importedFields = importedFields + 1
        end
    end

    log (photo.localIdentifier, 'imported fields:', importedFields)
    return importedFields
end

local function importPhotos (photos)
    local importedPhotos = 0
    local importedFields = 0

    for _, photo in ipairs (photos) do
        local fields = importPhoto (photo)
        if fields > 0 then
            importedPhotos = importedPhotos + 1
            importedFields = importedFields + fields
        end
    end

    return importedPhotos, importedFields
end

return {
    FILM_SHOTS_PLUGIN_ID = FILM_SHOTS_PLUGIN_ID,
    FIELD_IDS = FIELD_IDS,
    importPhoto = importPhoto,
    importPhotos = importPhotos,
}
