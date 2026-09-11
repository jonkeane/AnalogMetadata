local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrTasks = import 'LrTasks'
local LrUUID = import 'LrUUID'

require 'Use'
local log = require 'Logger' ('export')
local AnalogMetadata = use 'analog.AnalogMetadata'
local exiftool = use 'analog.ExiftoolBuilder'
local ExportSettings = use 'analog.ExportSettings'
local ExportDialogSection = use 'analog.ExportDialogSection'

local function postProcessRenderedPhotos(functionContext, filterContext)
    local builder = exiftool.make(ExportSettings.metadataMap(filterContext.propertyTable))
    local argumentFilePath = LrPathUtils.child(LrPathUtils.getStandardFilePath('temp'),
        'analog-metadata-' .. LrUUID.generateUUID() .. '.args')
    functionContext:addCleanupHandler(function()
        LrFileUtils.delete(argumentFilePath)
    end)

    for sourceRendition, renditionToSatisfy in filterContext:renditions() do
        local success, pathOrError = sourceRendition:waitForRender()
        if success then
            local arguments = builder:buildArguments(pathOrError, AnalogMetadata.make(sourceRendition.photo))
            if arguments then
                local file, errorMessage = io.open(argumentFilePath, 'wb')
                if file then
                    local written, writeError = file:write(builder:argumentFileContents(arguments))
                    local closed, closeError = file:close()
                    if written and closed then
                        local result = LrTasks.execute(builder:buildCommand(argumentFilePath))
                        if result ~= 0 then
                            renditionToSatisfy:renditionIsDone(false, 'Failed to execute ExifTool')
                        end
                    else
                        renditionToSatisfy:renditionIsDone(false, writeError or closeError)
                    end
                else
                    renditionToSatisfy:renditionIsDone(false, errorMessage)
                end
                LrFileUtils.delete(argumentFilePath)
            end
        else
            log('waitForRender: error: ', pathOrError)
        end
    end
end

return {
    postProcessRenderedPhotos = postProcessRenderedPhotos,
    exportPresetFields = ExportSettings.presetFields,
    sectionForFilterInDialog = ExportDialogSection.make,
}
