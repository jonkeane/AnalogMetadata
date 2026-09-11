local lu = require 'luaunit'
require 'mock.ImportMock'
local Builder = require 'analog.ExiftoolBuilder'
local Metadata = require 'analog.AnalogMetadata'
local Settings = require 'analog.ExportSettings'
local json = require 'lib.dkjson'
local root = 'AnalogMetadata.lrdevplugin'
local executable = root .. '/exiftool/macos/exiftool'
local config = root .. '/analog-film-exiftool.config'

local function readFile(path)
    local f = assert(io.open(path, 'rb'))
    local content = f:read('*a')
    f:close()
    return content
end
local function writeFile(path, data)
    local f = assert(io.open(path, 'wb'))
    assert(f:write(data))
    assert(f:close())
end
local function execute(command)
    local success = os.execute(command .. ' > /dev/null')
    lu.assertTrue(success == true or success == 0)
end
local function readTags(path)
    local pipe = assert(io.popen('perl ' .. executable .. ' -config ' .. config
        .. ' -j -G1 -s -XMP-AnalogExif:Film -Make -Model -ISO "' .. path .. '"'))
    local output = pipe:read('*a')
    pipe:close()
    return assert(json.decode(output))[1]
end

TestRoundTrip = {}
function TestRoundTrip:setUp()
    self.path = os.tmpname()
    self.args = os.tmpname()
    self.builder = Builder.make(Settings.metadataMap())
    self.builder.exiftoolPath = executable
end
function TestRoundTrip:tearDown()
    os.remove(self.path)
    os.remove(self.args)
end
function TestRoundTrip:write(meta, destination)
    self.builder.metadataMap = Settings.metadataMap({filmStockDestination = destination})
    local args = self.builder:buildArguments(self.path, Metadata.make(meta))
    if args then
        writeFile(self.args, self.builder:argumentFileContents(args))
        -- Invoke Perl explicitly so this also runs on Linux CI.
        execute('perl ' .. self.builder:buildCommand(self.args))
    end
end
function TestRoundTrip:seed(format)
    local fixture = format == 'jpg' and 'Canon.jpg' or 'ExifTool.tif'
    writeFile(self.path, readFile(root .. '/exiftool/macos/t/images/' .. fixture))
    execute('perl ' .. executable .. ' -config ' .. config
        .. ' -overwrite_original -Make=CameraMaker -Model=CameraModel -ISO=100 "' .. self.path .. '"')
end
function TestRoundTrip:testJpegAndTiff()
    for _, format in ipairs({'jpg', 'tif'}) do
        self:seed(format)
        self:write({Frame_EmulsionName = 'Kodak Portra 400', Frame_RatedISO = '800', Frame_BoxISO = '400'})
        local tags = readTags(self.path)
        lu.assertEquals(tags['XMP-AnalogExif:Film'], 'Kodak Portra 400')
        lu.assertEquals(tags['IFD0:Make'], 'CameraMaker')
        lu.assertEquals(tags['IFD0:Model'], 'CameraModel')
        lu.assertEquals(tags['ExifIFD:ISO'], 800)
        local bytes = readFile(self.path)
        lu.assertTrue(bytes:find("http://analogexif.sourceforge.net/ns['\"]") ~= nil)
        if format == 'jpg' then
            lu.assertStrContains(bytes, 'http://ns.adobe.com/xap/1.0/')
            lu.assertNil(bytes:find('http://ns.adobe.com/xmp/extension/', 1, true))
        end
        self:write({Frame_EmulsionName = 'Ilford HP5 Plus 400'}, 'make')
        tags = readTags(self.path)
        lu.assertEquals(tags['IFD0:Make'], 'Ilford HP5 Plus 400')
        lu.assertEquals(tags['XMP-AnalogExif:Film'], 'Kodak Portra 400')
    end
end
function TestRoundTrip:testSpecialCharacters()
    self:seed('jpg')
    local stock = '富士 "Film" & Co.\'s $HOME `id` $(id) %PATH% !test! \\n\n-Make=Injected\rEnd'
    for _, destination in ipairs({'xmp', 'make'}) do
        self:write({Frame_EmulsionName = stock}, destination)
        local tags = readTags(self.path)
        lu.assertEquals(tags[destination == 'xmp' and 'XMP-AnalogExif:Film' or 'IFD0:Make'], stock)
        if destination == 'xmp' then lu.assertEquals(tags['IFD0:Make'], 'CameraMaker') end
    end
end
function TestRoundTrip:testBlankAndDigitalMetadata()
    self:seed('jpg')
    self:write({Frame_EmulsionName = 'Original Film'})
    for _, destination in ipairs({'xmp', 'make'}) do
        for _, blank in ipairs({'', ' \t\r\n'}) do
            self:write({Frame_EmulsionName = blank, Frame_RatedISO = '200'}, destination)
            local tags = readTags(self.path)
            lu.assertEquals(tags['XMP-AnalogExif:Film'], 'Original Film')
            lu.assertEquals(tags['IFD0:Make'], 'CameraMaker')
        end
        local before = readFile(self.path)
        self:write({}, destination)
        lu.assertEquals(readFile(self.path), before)
    end
end

function testCommandPathsAndConfigOrder()
    for _, windows in ipairs({false, true}) do
        _G.WIN_ENV = windows
        _G.MAC_ENV = not windows
        _G._PLUGIN = {path = windows and 'C:\\Plugin Folder' or '/Plugin Folder/$test`x`'}
        local builder = Builder.make(Settings.metadataMap())
        local command = builder:buildCommand(windows and 'C:\\Temp\\export.args' or '/tmp/export.args')
        if windows then
            lu.assertEquals(command, '""C:\\Plugin Folder\\exiftool\\windows\\exiftool.exe" -config "C:\\Plugin Folder\\analog-film-exiftool.config" -@ "C:\\Temp\\export.args""')
        else
            lu.assertEquals(command, '"/Plugin Folder/\\$test\\`x\\`/exiftool/macos/exiftool" -config "/Plugin Folder/\\$test\\`x\\`/analog-film-exiftool.config" -@ "/tmp/export.args"')
        end
        _G.WIN_ENV, _G.MAC_ENV, _G._PLUGIN = nil, nil, nil
    end
end

os.exit(lu.LuaUnit.run())
