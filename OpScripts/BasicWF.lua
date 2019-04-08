--[[

Location: /root
renderer: prman

Add outputChannel attributes for Basic LPE workflow and create render output as multichanneled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- global variable that collect all defined here LPE outputChannels as a string
-- and will be used to adjust renderSettings.output attribute
channels = ''

function PrmanOutputChannelDefine (name, lpe, type)
    --[[ Works the same way as the PrmanOutputChannelDefine node ]]

    -- set default value for the 'type' argument
    type=type or "varying color"

    -- add current LPE channel to global variable
    if channels == '' then
        channels = name
    else
        channels = channels .. ',' .. name
    end

    -- create outputChannel by name
    Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.type', name), StringAttribute(type))
    Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.name', name), StringAttribute(name))

    -- set Light Path Expression
    if lpe ~= "" then
        Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.params.source.type', name), StringAttribute("string"))
        Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.params.source.value', name), StringAttribute(lpe))
    end

end



-- add 'Ci' and 'a' channels
PrmanOutputChannelDefine("Ci", "")
PrmanOutputChannelDefine("a", "", "varying float")


-- add channels for Basic LPE workflow
PrmanOutputChannelDefine("directDiffuse", "color lpe:C<RD>[<L.>O]")
PrmanOutputChannelDefine("indirectDiffuse", "color lpe:C<RD>[DS]+[<L.>O]")

PrmanOutputChannelDefine("directSpecular", "color lpe:C<RS>[<L.>O]")
PrmanOutputChannelDefine("indirectSpecular", "color lpe:C<RS>[DS]+[<L.>O]")

PrmanOutputChannelDefine("subsurface", "color lpe:C<TD>[DS]*[<L.>O]")
PrmanOutputChannelDefine("transmissive", "color lpe:C<TS>[DS]*[<L.>O]")
PrmanOutputChannelDefine("emissive", "color lpe:C[<L.>O]")



-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multi-channeled exr file
local path = pystring.os.path.join(path_project, string.format("%s_basicWF.exr", name) )



-- Create one render output for all defined here LPE outputChannels

-- add 'name' and 'raw' type parameters
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.basicWF.type', StringAttribute("raw"))
Interface.SetAttr('renderSettings.outputs.basicWF.rendererSettings.channel', StringAttribute(channels))
Interface.SetAttr('renderSettings.outputs.basicWF.locationType', StringAttribute("file"))
Interface.SetAttr('renderSettings.outputs.basicWF.locationSettings.renderLocation', StringAttribute(path))
