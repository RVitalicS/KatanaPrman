--[[

Location: /root
renderer: prman

Create one render output as multichanneled exr file per one defined outputChannel

Required attributes:
    user.projectPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name  ('Name_{:03d}'.format(frame) -> AttributeSet)

    * there has to be defined at least one outputChannel

]]


-- get added earlier userdefined attributes that contain:
-- path for render outputs and name of the current shot
local path_attribute = Interface.GetAttr('user.projectPath')
local name_attribute = Interface.GetAttr('user.shotName')

-- get string values of those attributes
path_project = Attribute.GetStringValue(path_attribute, '')
name = Attribute.GetStringValue(name_attribute, '')


function RenderOutputDefine (channel)
    --[[ Works the same way as the RenderOutputDefine node ]]

    -- add 'name' and 'raw' type parameters
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.type', channel), StringAttribute("raw"))
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.rendererSettings.channel', channel), StringAttribute(string.format ("%s", channel)))

    -- create full path string to save multichanneled exr file
    local path = pystring.os.path.join(path_project, string.format ("%s_%s.exr", name, channel) )

    -- switch location type to 'file' mode and set 'renderLocation' parameter
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.locationType', channel), StringAttribute("file"))
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.locationSettings.renderLocation', channel), StringAttribute(path))

end


-- get all defined outputChannels then get their count
local output_root = Interface.GetAttr('prmanGlobalStatements.outputChannels')
local children_num = output_root:getNumberOfChildren()

-- create separate render output for each outputChannel
for i = 0, children_num-1 do RenderOutputDefine(output_root:getChildName(i)) end
