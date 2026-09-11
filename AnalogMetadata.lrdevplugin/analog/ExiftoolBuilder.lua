local log = require 'Logger' ('ExiftoolBuilder')

local ExiftoolBuilder = {}
ExiftoolBuilder.__index = ExiftoolBuilder

-- Metadata and image paths go in an argument file, never through the shell.
-- CSTR preserves newlines and leading spaces without allowing extra arguments.
local function argumentLine(value)
    return '#[CSTR]' .. tostring(value):gsub('\\', '\\\\'):gsub('\r', '\\r'):gsub('\n', '\\n')
end

local function quotePath(path)
    if WIN_ENV then
        -- These characters cannot safely be passed through cmd.exe.
        assert(not path:find('["%%!\r\n]'), 'Unsupported character in ExifTool command path')
        return '"' .. path .. '"'
    end
    return '"' .. path:gsub('([\\"$`])', '\\%1') .. '"'
end

function ExiftoolBuilder:buildArguments(photoPath, meta)
    local arguments = { '-charset', 'UTF8', '-charset', 'filename=UTF8' }
    local empty = true
    for _, pair in ipairs(self.metadataMap) do
        if pair.key and pair.val then
            local getter = meta[pair.val]
            local value = getter and getter(meta)
            if value ~= nil and value ~= false then
                value = tostring(value)
                -- Blank film stock must not clear existing Film or Make metadata.
                if pair.val ~= 'Frame_EmulsionName' or value:find('%S') then
                    table.insert(arguments, '-' .. pair.key .. '=' .. value)
                    empty = false
                end
            end
        end
    end
    if empty then return nil end
    table.insert(arguments, '-overwrite_original')
    table.insert(arguments, '--')
    table.insert(arguments, photoPath)
    return arguments
end

function ExiftoolBuilder:argumentFileContents(arguments)
    local lines = {}
    for _, argument in ipairs(arguments) do
        table.insert(lines, argumentLine(argument))
    end
    return table.concat(lines, '\n') .. '\n'
end

function ExiftoolBuilder:buildCommand(argumentFilePath)
    -- ExifTool requires -config to be the first argument, outside the argfile.
    local command = quotePath(self.exiftoolPath) .. ' -config ' .. quotePath(self.configPath)
        .. ' -@ ' .. quotePath(argumentFilePath)
    if WIN_ENV then command = '"' .. command .. '"' end
    log(command)
    return command
end

local function make(metadataMap)
    local root = _PLUGIN and _PLUGIN.path or 'AnalogMetadata.lrdevplugin'
    local builder = setmetatable({ metadataMap = metadataMap }, ExiftoolBuilder)
    if MAC_ENV then
        builder.exiftoolPath = root .. '/exiftool/macos/exiftool'
    elseif WIN_ENV then
        builder.exiftoolPath = root .. '\\exiftool\\windows\\exiftool.exe'
    else
        builder.exiftoolPath = 'exiftool'
    end
    builder.configPath = root .. (WIN_ENV and '\\' or '/') .. 'analog-film-exiftool.config'
    return builder
end

return { make = make }
