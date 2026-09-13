local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'

local log = require 'Logger' ("ImportFilmShotsMetadata")
require 'Use'

local FilmShotsMetadataImport = use 'analog.FilmShotsMetadataImport'

local function main ()
    local catalog = LrApplication.activeCatalog ()
    local photos = catalog:getTargetPhotos ()

    if #photos == 0 then
        LrDialogs.message ('Select one or more photos before importing Film Shots metadata.')
        return
    end

    local importedPhotos, importedFields
    catalog:withPrivateWriteAccessDo (function ()
        importedPhotos, importedFields = FilmShotsMetadataImport.importPhotos (photos)
    end)

    log ('Imported', importedFields, 'fields for', importedPhotos, 'photos')

    if importedPhotos == 0 then
        LrDialogs.message ('No Film Shots metadata was found on the selected photos.')
    else
        LrDialogs.message (string.format (
            'Imported Film Shots metadata for %d selected photo%s.',
            importedPhotos,
            importedPhotos == 1 and '' or 's'
        ))
    end
end

LrFunctionContext.postAsyncTaskWithContext ('importFilmShotsMetadata', main)
