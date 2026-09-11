require 'Use'
local DefaultMetadataMap = use 'analog.DefaultMetadataMap'
local ExportSettings = use 'analog.ExportSettings'
local LrView = import 'LrView'

local function make(f, propertyTable)
    if propertyTable.filmStockDestination == nil then
        propertyTable.filmStockDestination = 'xmp'
    end
    local column = {
        bind_to_object = propertyTable,
        spacing = f:control_spacing(),
        f:row {
            spacing = f:control_spacing(),
            f:static_text { title = "Write film stock to:" },
            f:popup_menu {
                value = LrView.bind { key = 'filmStockDestination' },
                items = {
                    { title = "XMP (AnalogExif:Film)", value = 'xmp' },
                    { title = "Camera Make (compatibility workaround)", value = 'make' },
                },
            },
        },
        f:static_text {
            title = "XMP keeps film stock separate from camera Make.\n"
                .. "The Make workaround is helpful when your export destination has limited EXIF support\n"
                .. "and does not read custom XMP. It replaces camera/scanner Make with the film stock.",
            height_in_lines = 3,
            fill_horizontal = 1,
        },
        f:row {
            spacing = f:control_spacing(),
            f:static_text {
                title = "Update tags:",
                font = "<system/bold>",
                fill_horizontal = 1
            }
        }
    }

    for _, pair in ipairs(DefaultMetadataMap) do
        table.insert(
            column,
            f:row {
                spacing = f:control_spacing(),
                f:static_text {
                    title = pair.val == 'Frame_EmulsionName' and LrView.bind {
                        key = 'filmStockDestination',
                        transform = ExportSettings.filmTag,
                    } or pair.key,
                    fill_horizontal = 1
                },
                f:static_text {
                    title = "←",
                    font = "<system/bold>"
                },
                f:static_text {
                    title = pair.val,
                    fill_horizontal = 1
                }
            }
        )
    end

    return {
        title = "Crown & Flint Metadata",
        f:column(column)
    }
end

return {
    make = make
}
