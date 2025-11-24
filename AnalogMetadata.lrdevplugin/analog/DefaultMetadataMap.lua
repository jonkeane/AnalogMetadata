local DefaultMetadataMap = {

    {key = "Title", val = "Roll_Name"},
    -- {key = "Caption", val = "Frame_Locality"},
    {key = "UserComment", val = "Frame_Comment"},
    {key = "Make", val = "Frame_EmulsionName"},
    {key = "Model", val = "Roll_CameraName"},
    {key = "DateTime", val = "Frame_LocalTime"},
    {key = "DateTimeOriginal", val = "Frame_LocalTime"},
    {key = "GPSLatitude", val = "Frame_Latitude"},
    {key = "GPSLatitudeRef", val = "Frame_LatitudeRef"},
    {key = "GPSLongitude", val = "Frame_Longitude"},
    {key = "GPSLongitudeRef", val = "Frame_LongitudeRef"},
    {key = "ISO", val = "Frame_EffectiveISO"},
    {key = "LensModel", val = "Frame_LensName"},
    {key = "Lens", val = "Frame_LensName"},
    {key = "FocalLength", val = "Frame_FocalLength"},
    {key = "FNumber", val = "Frame_FStop"},
    {key = "ApertureValue", val = "Frame_FStop"},
    {key = "ExposureTime", val = "Frame_Shutter"},
    {key = "ShutterSpeedValue", val = "Frame_Shutter"},    
}

return DefaultMetadataMap