--[[

Location: /root
renderer: prman

For all defined outputChannels create one render output as multichanneled exr file

Required attributes:
    user.projectPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('Name_{:03d}'.format(frame) -> AttributeSet)
    user.workflow: (string) type of chosen workflow ('basicWF' or 'perLobeWF')

    * there has to be defined at least one outputChannel

]]


-- get all defined outputChannels then get their count
local output_root = Interface.GetAttr('prmanGlobalStatements.outputChannels')
local children_num = output_root:getNumberOfChildren()


-- create string that contains all defined outputChannels separated by comma
channels = output_root:getChildName(0)
for i = 1, children_num-1 do channels = channels .. ',' .. output_root:getChildName(i) end


-- get added earlier userdefined attributes that contain:
-- path for render outputs,
-- name of the current shot
-- and workflow tag depending on defined outputChannels
local path_attribute = Interface.GetAttr('user.projectPath')
local name_attribute = Interface.GetAttr('user.shotName')
local workflow_attribute = Interface.GetAttr('user.workflow')

-- get string values of those attributes
path_project = Attribute.GetStringValue(path_attribute, '')
name = Attribute.GetStringValue(name_attribute, '')
workflow = Attribute.GetStringValue(workflow_attribute, '')

-- create full path string to save multichanneled exr file
local path = pystring.os.path.join(path_project, string.format ("%s_%s.exr", name, workflow) )



-- Create one render output for all defined outputChannels

-- add 'name' and 'raw' type parameters
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.workflow.type', StringAttribute("raw"))
Interface.SetAttr('renderSettings.outputs.workflow.rendererSettings.channel', StringAttribute(string.format ("%s", channels)))
Interface.SetAttr('renderSettings.outputs.workflow.locationType', StringAttribute("file"))
Interface.SetAttr('renderSettings.outputs.workflow.locationSettings.renderLocation', StringAttribute(path))
