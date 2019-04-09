--[[

Location: /root
renderer: prman

Add outputChannel attributes for PerLobe LPE workflow and create render output as multi-channeled exr file

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


-- to correctly render PerLobe LPE in Katana, you need to declare how these are routed to the outputs
Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse2', StringAttribute("Diffuse"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse3', StringAttribute("Subsurface"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular2', StringAttribute("Specular"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular3', StringAttribute("RoughSpecular"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular4', StringAttribute("Clearcoat"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular5', StringAttribute("Iridescence"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular6', StringAttribute("Fuzz"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular7', StringAttribute("SingleScatter"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular8', StringAttribute("Glass"))


-- define channels for PerLobe LPE workflow
PrmanOutputChannelDefine("directDiffuseLobe", "color lpe:CD2[<L.>O]")
PrmanOutputChannelDefine("indirectDiffuseLobe", "color lpe:CD2[DS]+[<L.>O]")
PrmanOutputChannelDefine("subsurfaceLobe", "color lpe:CD3[DS]*[<L.>O]")
PrmanOutputChannelDefine("directSpecularPrimaryLobe", "color lpe:CS2[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularPrimaryLobe", "color lpe:CS2[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularRoughLobe", "color lpe:CS3[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularRoughLobe", "color lpe:CS3[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularClearcoatLobe", "color lpe:CS4[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularClearcoatLobe", "color lpe:CS4[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularIridescenceLobe", "color lpe:CS5[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularIridescenceLobe", "color lpe:CS5[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularFuzzLobe", "color lpe:CS6[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularFuzzLobe", "color lpe:CS6[DS]+[<L.>O]")
PrmanOutputChannelDefine("transmissiveSingleScatterLobe", "color lpe:CS7[DS]*[<L.>O]")
PrmanOutputChannelDefine("directSpecularGlassLobe", "color lpe:C<RS8>[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularGlassLobe", "color lpe:C<RS8>[DS]+[<L.>O]")
PrmanOutputChannelDefine("transmissiveGlassLobe", "color lpe:C<TS8>[DS]*[<L.>O]")
PrmanOutputChannelDefine("emissive", "color lpe:C[<L.>O]")


-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multi-channeled exr file
local path = pystring.os.path.join(path_project, string.format ("%s_perLobeWF.exr", name) )
path = pystring.replace(path, '\\', '/')



-- Create one render output for all defined here LPE outputChannels

-- add 'name' and 'raw' type parameters
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.primary.type', StringAttribute("raw"))
Interface.SetAttr('renderSettings.outputs.primary.rendererSettings.channel', StringAttribute(channels))
Interface.SetAttr('renderSettings.outputs.primary.locationType', StringAttribute("file"))
Interface.SetAttr('renderSettings.outputs.primary.locationSettings.renderLocation', StringAttribute(path))