require 'Use'
local DefaultMetadataMap = use 'analog.DefaultMetadataMap'

local function make(f, propertyTable)
    local column = {
        spacing = f:control_spacing(),
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
                    title = pair.key,
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