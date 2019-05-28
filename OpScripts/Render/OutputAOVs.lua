--[[

Location: /root
renderer: arnold

Add outputChannel attributes for AOVs and create render output as multi-channeled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- global variable that collect all defined here AOV channels as a string
-- and will be used to merge those ones to multichanneled exr file
channels = ''



function AovOutput (name, data, filter)
    --[[ Create outputChannel and local render output using AOV name and data type ]]


    -- add current LPE channel to global variable
    if channels == '' then
        channels = name
    else
        channels = channels .. ',' .. name
    end


    -- create outputChannel by name
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.name', name), StringAttribute(name))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.type', name), StringAttribute(data))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.channel', name), StringAttribute(name))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.filter', name), StringAttribute(filter))

    -- add driver attributes
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.half_precision', name), IntAttribute(0))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.tiled', name), IntAttribute(0))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.color_space', name), StringAttribute('linear'))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.autocrop', name), IntAttribute(0))

    -- set Light Path Expression for beauty channel
    if name == "primary" then
        Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.lightPathExpression', name), StringAttribute('C.*'))
    end


    -- create render output for current outputChannel
    Interface.SetAttr(string.format('renderSettings.outputs.%s.type', name), StringAttribute('raw'))
    Interface.SetAttr(string.format('renderSettings.outputs.%s.rendererSettings.channel', name), StringAttribute(name))

end



-- add 'beauty' channels
AovOutput("primary", "RGBA", "gaussian_filter")

-- add all other built-in AOVs
AovOutput("Z", "FLOAT", "closest_filter")
AovOutput("opacity", "RGB", "gaussian_filter")
AovOutput("volume_opacity", "RGB", "gaussian_filter")
AovOutput("ID", "UINT", "closest_filter")
AovOutput("P", "VECTOR", "closest_filter")
AovOutput("Pref", "VECTOR", "closest_filter")
AovOutput("N", "VECTOR", "closest_filter")
AovOutput("motionvector", "RGB", "gaussian_filter")
AovOutput("shadow_matte", "RGBA", "gaussian_filter")
AovOutput("shadow", "RGB", "gaussian_filter")
AovOutput("shadow_diff", "RGB", "gaussian_filter")
AovOutput("shadow_mask", "RGB", "gaussian_filter")
AovOutput("cputime", "FLOAT", "gaussian_filter")
AovOutput("raycount", "FLOAT", "gaussian_filter")
AovOutput("AA_inv_density", "FLOAT", "heatmap_filter")



-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multi-channeled exr file
local path = pystring.os.path.join(path_project, string.format("%s_aovs.exr", name))
path = pystring.replace(path, '\\', '/')



-- Merge all render outputs to multichanneled exr file
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.aovs.type', StringAttribute('merge'))
Interface.SetAttr('renderSettings.outputs.aovs.mergeOutputs', StringAttribute(channels))
Interface.SetAttr('renderSettings.outputs.aovs.locationType', StringAttribute('file'))
Interface.SetAttr('renderSettings.outputs.aovs.locationSettings.renderLocation', StringAttribute(path))
