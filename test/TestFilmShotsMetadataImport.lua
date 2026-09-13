local lu = require 'luaunit'
local FilmShotsMetadataImport = require 'analog.FilmShotsMetadataImport'

_PLUGIN = 'com.jonkeane.analogmetadata.plugin.lr'

local function makePhoto (legacyValues)
    local photo = {
        localIdentifier = 101,
        legacyValues = legacyValues or {},
        importedValues = {},
    }

    function photo:getPropertyForPlugin (pluginId, fieldId)
        lu.assertEquals (pluginId, FilmShotsMetadataImport.FILM_SHOTS_PLUGIN_ID)
        return self.legacyValues[fieldId]
    end

    function photo:setPropertyForPlugin (pluginId, fieldId, value)
        lu.assertEquals (pluginId, _PLUGIN)
        self.importedValues[fieldId] = value
    end

    return photo
end

function testImportPhotoCopiesSharedFieldsByExactName ()
    local photo = makePhoto {
        Roll_Name = 'Autumn 2020',
        Frame_Index = 12,
        Frame_Comment = 'Golden hour',
        Frame_Designator = '12A',
        Roll_Mode = 'manual',
    }

    local importedFields = FilmShotsMetadataImport.importPhoto (photo)

    lu.assertEquals (importedFields, 3)
    lu.assertEquals (photo.importedValues, {
        Roll_Name = 'Autumn 2020',
        Frame_Index = '12',
        Frame_Comment = 'Golden hour',
    })
end

function testImportPhotoPreservesDestinationWhenLegacyFieldIsMissing ()
    local photo = makePhoto {
        Roll_Name = 'Autumn 2020',
    }

    local importedFields = FilmShotsMetadataImport.importPhoto (photo)

    lu.assertEquals (importedFields, 1)
    lu.assertNil (photo.importedValues.Frame_Comment)
end

function testImportPhotosReportsPhotosAndFieldsImported ()
    local populatedPhoto = makePhoto { Roll_Name = 'Autumn 2020' }
    local emptyPhoto = makePhoto {}

    local importedPhotos, importedFields = FilmShotsMetadataImport.importPhotos {
        populatedPhoto,
        emptyPhoto,
    }

    lu.assertEquals (importedPhotos, 1)
    lu.assertEquals (importedFields, 1)
end

os.exit(lu.LuaUnit.run())
