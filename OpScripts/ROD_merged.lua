--[[

Location: /root
renderer: prman

For all defined outputChannels create one render output as multi-channeled exr file

Required attributes:
    user.projectPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('Name_{:03d}'.format(frame) -> AttributeSet)

]]


-- get all defined outputChannels then get their count
local output_root = Interface.GetAttr('prmanGlobalStatements.outputChannels')
if output_root then

    local children_num = output_root:getNumberOfChildren()


    -- create string that contains all defined outputChannels separated by comma
    channels = output_root:getChildName(0)
    for i = 1, children_num-1 do channels = channels .. ',' .. output_root:getChildName(i) end


    -- get added earlier userdefined attributes that contain:
    -- path for render outputs,
    -- name of the current shot
    local path_attribute = Interface.GetAttr('user.projectPath')
    local name_attribute = Interface.GetAttr('user.shotName')

    -- get string values of those attributes
    path_project = Attribute.GetStringValue(path_attribute, '')
    name = Attribute.GetStringValue(name_attribute, '')

    -- create full path string to save multi-channeled exr file
    local path = pystring.os.path.join(path_project, string.format ("%s.exr", name) )


    -- Create one render output for all defined outputChannels

    -- add 'name' and 'raw' type parameters
    -- switch location type to 'file' mode and set 'renderLocation' parameter
    Interface.SetAttr('renderSettings.outputs.workflow.type', StringAttribute("raw"))
    Interface.SetAttr('renderSettings.outputs.workflow.rendererSettings.channel', StringAttribute(string.format ("%s", channels)))
    Interface.SetAttr('renderSettings.outputs.workflow.locationType', StringAttribute("file"))
    Interface.SetAttr('renderSettings.outputs.workflow.locationSettings.renderLocation', StringAttribute(path))

end
