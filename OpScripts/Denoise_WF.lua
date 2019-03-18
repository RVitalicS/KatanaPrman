--[[

Location: /root
renderer: prman

Add outputChannels attributes for denoise workflow
and create output as multichanneled exr file

Required attributes:
    user.projectPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('Name_{:03d}'.format(frame) -> AttributeSet)

]]


-- global variable that collect all defined here AOV channels as a sting
-- and will be used to adjust renderSettings.output attributes
channels = ''


function PrmanOutputChannelDefine (name, type, lpe, statistics)
   --[[ Works the same way as the PrmanOutputChannelDefine node plus collect defined channels ]]

   -- add current AOV channel to global variable
   if channels == '' then
       channels = name
   else
       channels = channels .. ',' .. name
   end

   -- add two attributes grouped by input name
   -- these two attributes create base of outputChannel
   Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.type', name), StringAttribute(string.format ("%s", type)))
   Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.name', name), StringAttribute(string.format ("%s", name)))

   -- add required 'source' parameter for denoise workflow
   if lpe then
       Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.source.type', name), StringAttribute("string"))
       Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.source.value', name), StringAttribute(string.format ("%s", lpe)))
   end

   -- add required 'statistics' parameter for denoise workflow
   if statistics then
       Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.statistics.type', name), StringAttribute("string"))
       Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.statistics.value', name), StringAttribute(string.format ("%s", statistics)))
   end

end


-- define channels for denoise workflow
PrmanOutputChannelDefine("Ci", "varying color")
PrmanOutputChannelDefine("a", "varying float")
PrmanOutputChannelDefine("mse", "varying color", "Ci", "mse")

PrmanOutputChannelDefine("albedo", "varying color", "color lpe:nothruput;noinfinitecheck;noclamp;unoccluded;overwrite;C<.S'passthru'>*((U2L)|O)")
PrmanOutputChannelDefine("albedo_var", "varying color", "color lpe:nothruput;noinfinitecheck;noclamp;unoccluded;overwrite;C<.S'passthru'>*((U2L)|O)", "variance")

PrmanOutputChannelDefine("diffuse", "varying color", "color lpe:C(D[DS]*[LO])|O")
PrmanOutputChannelDefine("diffuse_mse", "varying color", "color lpe:C(D[DS]*[LO])|O", "mse")

PrmanOutputChannelDefine("specular", "varying color", "color lpe:CS[DS]*[LO]")
PrmanOutputChannelDefine("specular_mse", "varying color", "color lpe:CS[DS]*[LO]", "mse")

PrmanOutputChannelDefine("zfiltered", "varying float", "float zfiltered")
PrmanOutputChannelDefine("zfiltered_var", "varying float", "float zfiltered", "variance")

PrmanOutputChannelDefine("normal", "varying normal", "normal Nn")
PrmanOutputChannelDefine("normal_var", "varying normal", "normal Nn", "variance")

PrmanOutputChannelDefine("forward", "varying vector", "vector motionFore")
PrmanOutputChannelDefine("backward", "varying vector", "vector motionBack")


-- get string value from added earlier userdefined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.projectPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier userdefined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multichanneled exr file
local path = pystring.os.path.join(path_project, string.format ("%s_variance.exr", name) )



-- Create one render output for all denoise outputChannels

-- add 'name' and 'raw' type parameters
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.variance.type', StringAttribute("raw"))
Interface.SetAttr('renderSettings.outputs.variance.rendererSettings.channel', StringAttribute(string.format ("%s", channels)))
Interface.SetAttr('renderSettings.outputs.variance.locationType', StringAttribute("file"))
Interface.SetAttr('renderSettings.outputs.variance.locationSettings.renderLocation', StringAttribute(path))
