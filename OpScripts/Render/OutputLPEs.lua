--[[

Location: /root
renderer: arnold

Add outputChannel attributes to create render output as multichanneled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- global variable that collect all defined here LPE outputChannels as a string
-- and will be used to merge those ones to multichanneled exr file
channels = ''



function ArnoldOutput (name, lpe)
    --[[ Create outputChannel and local render output using name and Light Path Expression ]]


    -- add current LPE channel to global variable
    if channels == '' then
        channels = name
    else
        channels = channels .. ',' .. name
    end

    -- define output data type with one exception
    local channel_type = 'RGB'
    if name == 'primary' then channel_type = 'RGBA' end


    -- create outputChannel by name
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.name', name), StringAttribute(name))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.type', name), StringAttribute(channel_type))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.channel', name), StringAttribute(name))

    -- add driver attributes
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.half_precision', name), IntAttribute(0))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.tiled', name), IntAttribute(0))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.color_space', name), StringAttribute('linear'))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.driverParameters.autocrop', name), IntAttribute(0))

    -- set Light Path Expression
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.lightPathExpression', name), StringAttribute(lpe))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.lightGroups', name), StringAttribute('separate AOVs'))


    -- create render output for current outputChannel
    Interface.SetAttr(string.format('renderSettings.outputs.%s.type', name), StringAttribute('raw'))
    Interface.SetAttr(string.format('renderSettings.outputs.%s.rendererSettings.channel', name), StringAttribute(name))

end



-- add 'beauty' channels
ArnoldOutput("primary", "C.*")

-- add all other built-in channels
ArnoldOutput("diffuseDirect", "C<RD>L")
ArnoldOutput("diffuseIndirect", "C<RD>[DSVOB].*")
ArnoldOutput("diffuseAlbedo", "C<RD>A")

ArnoldOutput("specularDirect", "C<RS[^'coat''sheen']>L")
ArnoldOutput("specularIndirect", "C<RS[^'coat''sheen']>[DSVOB].*")
ArnoldOutput("specularAlbedo", "C<RS[^'coat''sheen']>A")

ArnoldOutput("sheenDirect", "C<RS'sheen'>L")
ArnoldOutput("sheenIndirect", "C<RS'sheen'>[DSVOB].*")
ArnoldOutput("sheenAlbedo", "C<RS'sheen'>A")

ArnoldOutput("coatDirect", "C<RS'coat'>L")
ArnoldOutput("coatIndirect", "C<RS'coat'>[DSVOB].*")
ArnoldOutput("coatAlbedo", "C<RS'coat'>A")

ArnoldOutput("transmissionDirect", "C<TS>L")
ArnoldOutput("transmissionIndirect", "C<TS>[DSVOB].*")
ArnoldOutput("transmissionAlbedo", "C<TS>A")

ArnoldOutput("sssDirect", "C<TD>L")
ArnoldOutput("sssIndirect", "C<TD>[DSVOB].*")
ArnoldOutput("sssAlbedo", "C<TD>A")

ArnoldOutput("volumeDirect", "CVL")
ArnoldOutput("volumeIndirect", "CV[DSVOB].*")
ArnoldOutput("volumeAlbedo", "CVA")

ArnoldOutput("emission", "C[LO]")
ArnoldOutput("background", "CB")



-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multi-channeled exr file
local path = pystring.os.path.join(path_project, string.format("%s.exr", name) )
path = pystring.replace(path, '\\', '/')



-- Merge all render outputs to multichanneled exr file
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.multichanneled.type', StringAttribute('merge'))
Interface.SetAttr('renderSettings.outputs.multichanneled.mergeOutputs', StringAttribute(channels))
Interface.SetAttr('renderSettings.outputs.multichanneled.locationType', StringAttribute('file'))
Interface.SetAttr('renderSettings.outputs.multichanneled.locationSettings.renderLocation', StringAttribute(path))
