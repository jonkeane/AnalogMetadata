local lu = require 'luaunit'
require 'mock.ImportMock'
local Export = require 'Export'
local Tasks = require 'mock.LrTasksMock'
local Paths = require 'mock.LrPathUtilsMock'
local Files = require 'mock.LrFileUtilsMock'

TestExport = {}
function TestExport:setUp()
    self.oldExecute = Tasks.execute
    self.oldTemp = Paths.getStandardFilePath
    self.tempFile = os.tmpname()
    os.remove(self.tempFile)
    assert(Files.createDirectory(self.tempFile))
    Paths.getStandardFilePath = function() return self.tempFile end
    self.commands, self.contents = {}, {}
    self.argsPath = self.tempFile .. '/analog-metadata-test-export.args'
    Tasks.execute = function(command)
        table.insert(self.commands, command)
        local f = assert(io.open(self.argsPath, 'rb'))
        table.insert(self.contents, f:read('*a'))
        f:close()
        return self.exitCode or 0
    end
end
function TestExport:tearDown()
    Tasks.execute = self.oldExecute
    Paths.getStandardFilePath = self.oldTemp
    Files.delete(self.tempFile)
end
function TestExport:runExport(properties, photos)
    local statuses = {}
    local context = {addCleanupHandler = function(_, handler) self.cleanup = handler end}
    local filter = {
        propertyTable = properties,
        renditions = function()
            local index = 0
            return function()
                index = index + 1
                if not photos[index] then return nil end
                local source = {
                    photo = photos[index],
                    destinationPath = 'unused-destination.jpg',
                    waitForRender = function() return true, '/rendered/' .. index .. '.jpg' end,
                }
                local renditionIndex = index
                return source, {renditionIsDone = function(_, success, reason)
                    statuses[renditionIndex] = {success, reason}
                end}
            end
        end,
    }
    Export.postProcessRenderedPhotos(context, filter)
    lu.assertFalse(Files.exists(self.argsPath))
    self.cleanup()
    return statuses
end
function TestExport:testMixedBatchUsesPresetAndRenderedPath()
    lu.assertEquals(Export.exportPresetFields, {{key = 'filmStockDestination', default = 'xmp'}})
    self:runExport({filmStockDestination = 'make'}, {
        {Frame_EmulsionName = 'Kodak Gold'}, {}, {Frame_EmulsionName = 'HP5'},
    })
    lu.assertEquals(#self.commands, 2)
    lu.assertStrContains(self.contents[1], '-Make=Kodak Gold')
    lu.assertStrContains(self.contents[2], '-Make=HP5')
    lu.assertStrContains(self.contents[2], '/rendered/3.jpg')
    lu.assertNil(self.contents[2]:find('Kodak Gold', 1, true))
end
function TestExport:testOlderPresetDefaultsToXmp()
    self:runExport({}, {{Frame_EmulsionName = 'Kodak Gold'}})
    lu.assertStrContains(self.contents[1], '-XMP-AnalogExif:Film=Kodak Gold')
end
function TestExport:testExiftoolFailureCleansUpAndFailsRendition()
    self.exitCode = 1
    local statuses = self:runExport({}, {{Frame_EmulsionName = 'Kodak Gold'}})
    lu.assertEquals(statuses[1], {false, 'Failed to execute ExifTool'})
end
function TestExport:testArgumentFileFailureFailsRendition()
    Files.delete(self.tempFile)
    local statuses = self:runExport({}, {{Frame_EmulsionName = 'Kodak Gold'}})
    lu.assertEquals(statuses[1][1], false)
    lu.assertEquals(#self.commands, 0)
end

os.exit(lu.LuaUnit.run())
