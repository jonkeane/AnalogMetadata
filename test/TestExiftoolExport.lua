local lu = require 'luaunit'
local exiftool = require 'analog.ExiftoolBuilder'
local AnalogMetadata = require 'analog.AnalogMetadata'
local DefaultMetadataMap = require 'analog.DefaultMetadataMap'

local function withGlobal (env, func)
    for _, pair in ipairs (env) do
        _G[pair[1]] = pair[2]
    end
    func ()
    for _, pair in ipairs (env) do
        _G[pair[1]] = nil
    end
end

function testEmpty()
    lu.assertTrue(true)
end

function testNegativeLongitude()
    local builder = exiftool.make (DefaultMetadataMap)

    command = builder:buildCommand (
        "1.jpg",
    AnalogMetadata.make (
            {
                Frame_Latitude = 50.211,
                Frame_Longitude = -91.3333
            }
        )
    )

    lu.assertEquals(
        command,
        'exiftool -GPSLatitude="50.211" -GPSLatitudeRef="N" -GPSLongitude="-91.3333" -GPSLongitudeRef="W" -overwrite_original "1.jpg"'
    )
end

function testNegativeLatitude()
    local builder = exiftool.make (DefaultMetadataMap)

    command = builder:buildCommand (
        "1.jpg",
    AnalogMetadata.make (
            {
                Frame_Latitude = -50.211,
                Frame_Longitude = 91.3333
            }
        )
    )

    lu.assertEquals(
        command,
        'exiftool -GPSLatitude="-50.211" -GPSLatitudeRef="S" -GPSLongitude="91.3333" -GPSLongitudeRef="E" -overwrite_original "1.jpg"'
    )
end

function testNegativeLatitudeLongitude()
    local builder = exiftool.make (DefaultMetadataMap)

    command =
        builder:buildCommand(
        "1.jpg",
    AnalogMetadata.make(
            {
                Frame_Latitude = -50.211,
                Frame_Longitude = -91.3333
            }
        )
    )

    lu.assertEquals(
        command,
        'exiftool -GPSLatitude="-50.211" -GPSLatitudeRef="S" -GPSLongitude="-91.3333" -GPSLongitudeRef="W" -overwrite_original "1.jpg"'
    )
end

function testNoLocation()
    local builder = exiftool.make (DefaultMetadataMap)

    command =
        builder:buildCommand(
        "1.jpg",
    AnalogMetadata.make(
            {
                Roll_Name = "Roll 1",
                Frame_Latitude = nil,
                Frame_Longitude = nil
            }
        )
    )

    lu.assertEquals(
        command,
        'exiftool -Title="Roll 1" -overwrite_original "1.jpg"'
    )
end

function testEmpty()
    local builder = exiftool.make (DefaultMetadataMap)

    local meta = AnalogMetadata.make ({})
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertNil (command)
end

function testBasic()
    local builder = exiftool.make (DefaultMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertEquals(
        command,
        'exiftool ' ..
        '-Title="Roll 1" ' ..
        -- '-Caption="Seaside" ' ..
        '-UserComment="Comment comment comment" ' ..
        '-Make="Kodak Gold" ' ..
        '-Model="Olympus XA" ' ..
        '-GPSLatitude="51.2322" ' ..
        '-GPSLatitudeRef="N" ' ..
        '-GPSLongitude="2.033" ' ..
        '-GPSLongitudeRef="E" ' ..
        '-ISO="200" ' ..
        '-LensModel="Zuyko 35mm F2.8" ' ..
        '-Lens="Zuyko 35mm F2.8" ' ..
        '-FocalLength="35" ' ..
        '-FNumber="5.6" ' ..
        '-ApertureValue="5.6" ' ..
        '-ExposureTime="1/250" ' ..
        '-ShutterSpeedValue="1/250" ' ..
        '-overwrite_original "1.jpg"'
    )
end

function testBasic_Win()
    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)

    local command = ""
    withGlobal ({
            {"WIN_ENV", true},
            {"_PLUGIN", {path = "c:\\Program Files\\Lightroom\\plugins\\AnalogMetadata.lrplugin"}}
        },
        function ()
            local builder = exiftool.make (DefaultMetadataMap)
            command = builder:buildCommand ("1.jpg", meta)
        end
    )

    lu.assertEquals(
        command,
        '"' ..
    '"c:\\Program Files\\Lightroom\\plugins\\AnalogMetadata.lrplugin\\exiftool\\windows\\exiftool.exe" ' ..
        '-Title="Roll 1" ' ..
        -- '-Caption="Seaside" ' ..
        '-UserComment="Comment comment comment" ' ..
        '-Make="Kodak Gold" ' ..
        '-Model="Olympus XA" ' ..
        '-GPSLatitude="51.2322" ' ..
        '-GPSLatitudeRef="N" ' ..
        '-GPSLongitude="2.033" ' ..
        '-GPSLongitudeRef="E" ' ..
        '-ISO="200" ' ..
        '-LensModel="Zuyko 35mm F2.8" ' ..
        '-Lens="Zuyko 35mm F2.8" ' ..
        '-FocalLength="35" ' ..
        '-FNumber="5.6" ' ..
        '-ApertureValue="5.6" ' ..
        '-ExposureTime="1/250" ' ..
        '-ShutterSpeedValue="1/250" ' ..
        '-overwrite_original "1.jpg"' ..
        '"'
    )
end

function testBasic_Mac()
    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)

    local command = ""
    withGlobal ({
            {"MAC_ENV", true},
            {"_PLUGIN", {path = "/Applications/Adobe Photoshop Lightroom 5.app/Contents/PlugIns/AnalogMetadata.lrplugin"}}
        },
        function ()
            local builder = exiftool.make (DefaultMetadataMap)
            command = builder:buildCommand ("1.jpg", meta)
        end
    )

    lu.assertEquals(
        command,
    '"/Applications/Adobe Photoshop Lightroom 5.app/Contents/PlugIns/AnalogMetadata.lrplugin/exiftool/macos/exiftool" ' ..
        '-Title="Roll 1" ' ..
        -- '-Caption="Seaside" ' ..
        '-UserComment="Comment comment comment" ' ..
        '-Make="Kodak Gold" ' ..
        '-Model="Olympus XA" ' ..
        '-GPSLatitude="51.2322" ' ..
        '-GPSLatitudeRef="N" ' ..
        '-GPSLongitude="2.033" ' ..
        '-GPSLongitudeRef="E" ' ..
        '-ISO="200" ' ..
        '-LensModel="Zuyko 35mm F2.8" ' ..
        '-Lens="Zuyko 35mm F2.8" ' ..
        '-FocalLength="35" ' ..
        '-FNumber="5.6" ' ..
        '-ApertureValue="5.6" ' ..
        '-ExposureTime="1/250" ' ..
        '-ShutterSpeedValue="1/250" ' ..
        '-overwrite_original "1.jpg"'
    )
end

function testCustomMapping_Empty()
    local customMetadataMap = {

    }

    local builder = exiftool.make (customMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertNil (command)
end

function testCustomMapping_SkipBadFormat()
    local customMetadataMap = {
        {key = "Title", value = "Roll_Name"}, -- 'has to be val, not value'
        {key = "Caption", val = "Frame_Locality"},
    }

    local builder = exiftool.make (customMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertEquals(
        command,
        'exiftool -Caption=\"Seaside\" -overwrite_original "1.jpg"'
    )
end

function testCustomMapping_SkipAllBadFormat()
    local customMetadataMap = {
        {key = "Title", value = "Roll_Name"}, -- 'has to be val, not value'
        {Key = "Caption", val = "Frame_Locality"}, -- 'key, not Key'
    }

    local builder = exiftool.make (customMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertNil (command)
end

function testCustomMapping_Basic()
    local customMetadataMap = {
        {key = "Title", val = "Roll_Name"},
        {key = "Caption", val = "Frame_Locality"},
    }

    local builder = exiftool.make (customMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "200",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertEquals(
        command,
        'exiftool -Title=\"Roll 1\" -Caption=\"Seaside\" -overwrite_original "1.jpg"'
    )
end

function testBasic_EffectiveISO_Box()
    local builder = exiftool.make (DefaultMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = nil,
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertEquals(
        command,
        'exiftool ' ..
        '-Title="Roll 1" ' ..
        -- '-Caption="Seaside" ' ..
        '-UserComment="Comment comment comment" ' ..
        '-Make="Kodak Gold" ' ..
        '-Model="Olympus XA" ' ..
        '-GPSLatitude="51.2322" ' ..
        '-GPSLatitudeRef="N" ' ..
        '-GPSLongitude="2.033" ' ..
        '-GPSLongitudeRef="E" ' ..
        '-ISO="200" ' ..
        '-LensModel="Zuyko 35mm F2.8" ' ..
        '-Lens="Zuyko 35mm F2.8" ' ..
        '-FocalLength="35" ' ..
        '-FNumber="5.6" ' ..
        '-ApertureValue="5.6" ' ..
        '-ExposureTime="1/250" ' ..
        '-ShutterSpeedValue="1/250" ' ..
        '-overwrite_original "1.jpg"'
    )
end

function testBasic_EffectiveISO_Rated()
    local builder = exiftool.make (DefaultMetadataMap)

    local photo = {
        Roll_Name = "Roll 1",
        Frame_Locality = "Seaside",
        Frame_Comment = "Comment comment comment",
        Frame_EmulsionName = "Kodak Gold",
        Roll_CameraName = "Olympus XA",
        Frame_LocalTime = "2020-05-09T13:21:35",
        Frame_Latitude = "51.2322",
        Frame_LatitudeRef = "N",
        Frame_Longitude = "2.033",
        Frame_LongitudeRef = "E",
        Frame_BoxISO = "200",
        Frame_RatedISO = "400",
        Frame_LensName = "Zuyko 35mm F2.8",
        Frame_FocalLength = "35",
        Frame_FStop = "5.6",
        Frame_Shutter = "1/250"
    }

    local meta = AnalogMetadata.make (photo)
    local command = builder:buildCommand ("1.jpg", meta)

    lu.assertEquals(
        command,
        'exiftool ' ..
        '-Title="Roll 1" ' ..
        -- '-Caption="Seaside" ' ..
        '-UserComment="Comment comment comment" ' ..
        '-Make="Kodak Gold" ' ..
        '-Model="Olympus XA" ' ..
        '-GPSLatitude="51.2322" ' ..
        '-GPSLatitudeRef="N" ' ..
        '-GPSLongitude="2.033" ' ..
        '-GPSLongitudeRef="E" ' ..
        '-ISO="400" ' ..
        '-LensModel="Zuyko 35mm F2.8" ' ..
        '-Lens="Zuyko 35mm F2.8" ' ..
        '-FocalLength="35" ' ..
        '-FNumber="5.6" ' ..
        '-ApertureValue="5.6" ' ..
        '-ExposureTime="1/250" ' ..
        '-ShutterSpeedValue="1/250" ' ..
        '-overwrite_original "1.jpg"'
    )
end

os.exit(lu.LuaUnit.run())
