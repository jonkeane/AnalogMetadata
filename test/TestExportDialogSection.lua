local lu = require 'luaunit'
require 'mock.ImportMock'
local LrViewMock = require 'mock.LrViewMock'
local ExportDialogSection = require 'analog.ExportDialogSection'
local ExportSettings = require 'analog.ExportSettings'

function testDefaultAndSavedChoice()
    for _, initial in ipairs({'unset', 'xmp', 'make'}) do
        local props = initial == 'unset' and {} or {filmStockDestination = initial}
        local section = ExportDialogSection.make(LrViewMock.osFactory(), props)
        lu.assertEquals(props.filmStockDestination, initial == 'unset' and 'xmp' or initial)
        local column = section[1].args
        lu.assertIs(column.bind_to_object, props)
        local menu = column[1].args[2].args
        lu.assertEquals(menu.value.key.key, 'filmStockDestination')
        lu.assertEquals(menu.items[1].value, 'xmp')
        lu.assertEquals(menu.items[2].value, 'make')
        lu.assertStrContains(column[2].args.title, 'limited EXIF support')
        lu.assertStrContains(column[2].args.title, 'replaces camera/scanner Make')
    end
end

function testMapDoesNotLeakBetweenPresets()
    lu.assertEquals(ExportSettings.presetFields, {{key = 'filmStockDestination', default = 'xmp'}})
    for _, destination in ipairs({'make', 'xmp', 'unknown'}) do
        local map = ExportSettings.metadataMap({filmStockDestination = destination})
        lu.assertEquals(map[3].key, destination == 'make' and 'Make' or 'XMP-AnalogExif:Film')
        lu.assertEquals(map[4].key, 'Model')
    end
    lu.assertEquals(ExportSettings.metadataMap()[3].key, 'XMP-AnalogExif:Film')
end

function testMappingLabelTracksSelection()
    local view = {osFactory = LrViewMock.osFactory, bind = function(spec) return spec end}
    local originalImport = import
    _G.import = function(name) return name == 'LrView' and view or originalImport(name) end
    local section = dofile('AnalogMetadata.lrdevplugin/analog/ExportDialogSection.lua')
        .make(view.osFactory(), {})
    _G.import = originalImport
    local filmLabel = section[1].args[6].args[1].args.title
    lu.assertEquals(filmLabel.key, 'filmStockDestination')
    lu.assertEquals(filmLabel.transform('make'), 'Make')
    lu.assertEquals(filmLabel.transform('xmp'), 'XMP-AnalogExif:Film')
end

os.exit(lu.LuaUnit.run())
