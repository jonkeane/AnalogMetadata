local Version = {major=0, minor=1, revision=0, build=12}

local Info = {

	LrSdkVersion = 9.0,
	LrSdkMinimumVersion = 2.0,
	LrToolkitIdentifier = 'com.jonkeane.analogmetadata.plugin.lr',

	LrPluginName = "Analog Metadata",
	LrPluginInfoUrl = "http://www.jonkeane.com",

	-- Add the Metadata Definition File
	LrMetadataProvider = 'MetadataDefinition.lua',

	-- Add the Metadata Tagset File
	LrMetadataTagsetFactory = {
		'MetadataTagset.lua',
		--'AllMetadataTagset.lua',
	},

    LrLibraryMenuItems = {
		{
			title = 'Import Analog Metadata ...',
			file = 'Import.lua',
			enabledWhen = 'photosAvailable',
		},
	},

	LrExportFilterProvider = {
		{
			title = "Export analog metadata",
			file = "Export.lua",
			id = "export",
		},
	},

	-- Add the entry for the Plug-in Manager Dialog
	--LrPluginInfoProvider = 'PluginInfoProvider.lua',

	VERSION = Version,
}

local function dumpVersion ()
    if print and string and string.format then
        print (string.format ("{major=%d, minor=%d, revision=%d, build=%d}", Version.major, Version.minor, Version.revision, Version.build))
    end
end

local function printVersion ()
    if print and string and string.format then
        print (string.format ("%d.%d.%d.%d", Version.major, Version.minor, Version.revision, Version.build))
    end
end

if arg then
    if arg[1] == '--version-table' then
        dumpVersion ()
    end

    if arg[1] == '--version' then
        printVersion ()
    end

    if arg[1] == '--next-build' then
        Version.build = Version.build + 1
        dumpVersion ()
    end

	if arg[1] == '--next-revision' then
	Version.revision = Version.revision + 1
	Version.build = 0
	dumpVersion ()
end
end

return Info
