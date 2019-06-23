--[[

Location: /root
renderer: prman

Add outputChannel attributes for "denoise" workflow and create render output as multi-channeled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ("shotName_F%03d"%frame -> AttributeSet)

Required user defined parameters:
    user.CreateStatisticFile: (number) switch to create statistic file

]]



-- get switch from user defined parameter to create statistic file
local CheckBox_StatisticFile = Attribute.GetFloatValue(Interface.GetOpArg("user.CreateStatisticFile"), 0)




-- variable that collect all defined here LPE channels as a sting
-- and will be used to adjust renderSettings.output attributes
local channel_list = ""


function PrmanOutputChannelDefine (input_name, input_type, input_lpe, input_statistics)

   --[[
   Works the same way as the PrmanOutputChannelDefine node plus collect defined channels

   Arguments:
        input_name       (string): name of outputChannel
        input_type       (string): type of channel data
        input_lpe        (string): Light Path Expression ("color lpe:C.*[<L.>O]")
        input_statistics (string): choice of sampling type
   ]]


   -- add current LPE channel to global variable
   if channel_list == "" then
       channel_list = input_name
   else
       channel_list = channel_list .. "," .. input_name
   end

   -- create outputChannel
   Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", input_name), StringAttribute(input_type))
   Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", input_name), StringAttribute(input_name))

   -- add required "source" parameter for denoise workflow
   if input_lpe then
       Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", input_name), StringAttribute("string"))
       Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", input_name), StringAttribute(input_lpe))
   end

   -- add required "statistics" parameter for denoise workflow
   if input_statistics then
       Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.statistics.type", input_name), StringAttribute("string"))
       Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.statistics.value", input_name), StringAttribute(input_statistics))
   end

end




-- add channels for "denoise" workflow
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




-- get path for render outputs and name of the current shot
local shot_path = Attribute.GetStringValue(Interface.GetAttr("user.shotPath"), "")
local shot_name = Attribute.GetStringValue(Interface.GetAttr("user.shotName"), "")

-- create full path string to save multi-channeled exr file
local output_path = pystring.os.path.join(shot_path, string.format("%s_variance.exr", shot_name) )
      output_path = pystring.os.path.normpath(output_path)


-- Create one render output for all "denoise" outputChannels
Interface.SetAttr("renderSettings.outputs.denoise.type", StringAttribute("raw"))
Interface.SetAttr("renderSettings.outputs.denoise.rendererSettings.channel", StringAttribute(channel_list))
Interface.SetAttr("renderSettings.outputs.denoise.locationType", StringAttribute("file"))
Interface.SetAttr("renderSettings.outputs.denoise.locationSettings.renderLocation", StringAttribute(output_path))




-- create statistic file at will
if CheckBox_StatisticFile > 0.0 then

    -- create full path string to save multi-channeled exr file
    local statistic_path = pystring.os.path.join(shot_path, string.format("%s_variance.xml", shot_name) )
          statistic_path = pystring.os.path.normpath(statistic_path)

    -- switch on statistics output
    Interface.SetAttr("prmanGlobalStatements.options.statistics.level", IntAttribute(1))
    Interface.SetAttr("prmanGlobalStatements.options.statistics.xmlfilename", StringAttribute(statistic_path))

end
