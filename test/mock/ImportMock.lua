-- Provide a global import() compatible with Lightroom SDK for unit tests
-- Maps module names to our mocks
local map = {
    LrView = function() return require('mock.LrViewMock') end,
    LrUUID = function() return { generateUUID = function() return 'test-export' end } end,
    LrPathUtils = function() return require('mock.LrPathUtilsMock') end,
    LrFileUtils = function() return require('mock.LrFileUtilsMock') end,
    LrDate = function() return require('mock.LrDateMock') end,
    LrMD5 = function() return require('mock.LrMD5Mock') end,
    LrFolder = function() return require('mock.LrFolderMock') end,
    LrCatalog = function() return require('mock.LrCatalogMock') end,
    LrTasks = function() return require('mock.LrTasksMock') end,
}

_G.import = function(name)
    local fn = map[name]
    if fn then return fn() end
    error('No mock for import('..tostring(name)..')')
end

return _G.import
