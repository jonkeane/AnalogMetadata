local lu = require "luaunit"
local LrViewMock = require "mock.LrViewMock"
local ExportDialogSection = require "analog.ExportDialogSection"

function testEmpty()
    lu.assertTrue(true)
end

function testSectionForFilterInDialog()
    local props = {}
    local section = ExportDialogSection.make(LrViewMock.osFactory(), props)

    lu.assertEquals(
        section,
        {
            {
                args = {
                    {
                        args = {
                            {
                                args = {fill_horizontal = 1, font = "<system/bold>", title = "Update tags:"},
                                type = "static_text"
                            },
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "Title"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Roll_Name"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    -- {
                    --     args = {
                    --         {args = {fill_horizontal = 1, title = "Caption"}, type = "static_text"},
                    --         {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                    --         {args = {fill_horizontal = 1, title = "Frame_Locality"}, type = "static_text"},
                    --         spacing = 0
                    --     },
                    --     type = "row"
                    -- },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "UserComment"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_Comment"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "Make"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_EmulsionName"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "Model"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Roll_CameraName"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "DateTime"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_LocalTime"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "DateTimeOriginal"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_LocalTime"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "GPSLatitude"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_Latitude"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "GPSLatitudeRef"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_LatitudeRef"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "GPSLongitude"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_Longitude"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "GPSLongitudeRef"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_LongitudeRef"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "ISO"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_EffectiveISO"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "LensModel"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_LensName"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "Lens"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_LensName"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "FocalLength"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_FocalLength"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "FNumber"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_FStop"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "ApertureValue"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_FStop"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "ExposureTime"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_Shutter"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    {
                        args = {
                            {args = {fill_horizontal = 1, title = "ShutterSpeedValue"}, type = "static_text"},
                            {args = {font = "<system/bold>", title = "←"}, type = "static_text"},
                            {args = {fill_horizontal = 1, title = "Frame_Shutter"}, type = "static_text"},
                            spacing = 0
                        },
                        type = "row"
                    },
                    spacing = 0
                },
                type = "column"
            },
            title = "Crown & Flint Metadata"
        }
    )
end

os.exit(lu.LuaUnit.run())
