--[[

Location: /root
renderer: prman

Add outputChannels attributes for Basic LPE workflow and create render output as multichanneled exr file

Required attributes:
    user.projectPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('Name_{:03d}'.format(frame) -> AttributeSet)

]]


-- add 'Ci' and 'a' channels
Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.type', StringAttribute("varying color"))
Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.name', StringAttribute("Ci"))

Interface.SetAttr('prmanGlobalStatements.outputChannels.a.type', StringAttribute("varying float"))
Interface.SetAttr('prmanGlobalStatements.outputChannels.a.name', StringAttribute("a"))


-- global variable that collect all defined here LPE outputChannels as a string
-- and will be used to adjust renderSettings.output attribute
channels = 'Ci,a'


function PrmanOutputChannelDefine (name, lpe)
    --[[ Works the same way as the PrmanOutputChannelDefine node ]]

    -- add current LPE channel to global variable
    channels = channels .. ',' .. name

    -- add two attributes grouped by input name
    -- these two attributes create base of outputChannel
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.type', name), StringAttribute("varying color"))
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.name', name), StringAttribute(string.format ("%s", name)))

    -- these attributes are for working with Light Path Expressions
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.source.type', name), StringAttribute("string"))
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.source.value', name), StringAttribute(string.format ("%s", lpe)))

end


-- define channels for Basic LPE workflow
PrmanOutputChannelDefine("directDiffuse", "color lpe:C<RD>[<L.>O]")
PrmanOutputChannelDefine("indirectDiffuse", "color lpe:C<RD>[DS]+[<L.>O]")

PrmanOutputChannelDefine("directSpecular", "color lpe:C<RS>[<L.>O]")
PrmanOutputChannelDefine("indirectSpecular", "color lpe:C<RS>[DS]+[<L.>O]")

PrmanOutputChannelDefine("subsurface", "color lpe:C<TD>[DS]*[<L.>O]")
PrmanOutputChannelDefine("transmissive", "color lpe:C<TS>[DS]*[<L.>O]")
PrmanOutputChannelDefine("emissive", "color lpe:C[<L.>O]")


-- get string value from added earlier userdefined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.projectPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier userdefined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multichanneled exr file
local path = pystring.os.path.join(path_project, string.format ("%s_basicWF.exr", name) )



-- Create one render output for all defined here LPE outputChannels

-- add 'name' and 'raw' type parameters
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.basicWF.type', StringAttribute("raw"))
Interface.SetAttr('renderSettings.outputs.basicWF.rendererSettings.channel', StringAttribute(string.format ("%s", channels)))
Interface.SetAttr('renderSettings.outputs.basicWF.locationType', StringAttribute("file"))
Interface.SetAttr('renderSettings.outputs.basicWF.locationSettings.renderLocation', StringAttribute(path))
