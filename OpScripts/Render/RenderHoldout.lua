--[[

Location: /root
renderer: prman

Add "occluded" and "shadow" outputChannel attributes and create render output as multi-channeled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ("shotName_F%03d"%frame -> AttributeSet)

Required user defined parameters:
    user.CreateStatisticFile: (number) switch to create statistic file

]]



-- get switch from user defined parameter to create statistic file
local CheckBox_StatisticFile = Attribute.GetFloatValue(Interface.GetOpArg("user.CreateStatisticFile"), 0)




-- variable that collect all defined here LPE outputChannels as a string
-- and will be used to adjust renderSettings.output attribute
local channel_list = ""


function PrmanOutputChannelDefine (input_name, input_lpe, input_type)

    --[[
    Works the same way as the PrmanOutputChannelDefine node

    Arguments:
        input_name       (string): name of outputChannel
        input_lpe        (string): Light Path Expression ("color lpe:C.*[<L.>O]")
        input_type       (string): type of channel data
    ]]


    -- set default value for the "type" argument
    input_type = input_type or "varying color"

    -- add current LPE channel to global variable
    if channel_list == "" then
        channel_list = input_name
    else
        channel_list = channel_list .. "," .. input_name
    end

    -- create outputChannel
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", input_name), StringAttribute(input_type))
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", input_name), StringAttribute(input_name))

    -- set Light Path Expression
    if input_lpe ~= "" then
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", input_name), StringAttribute("string"))
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", input_name), StringAttribute(input_lpe))
    end

end



-- add "Ci" and "a" channels
PrmanOutputChannelDefine("Ci", "")
PrmanOutputChannelDefine("a", "", "varying float")

-- add "occluded" and "shadow" outputChannels
PrmanOutputChannelDefine("occluded", "color lpe:holdouts;C[DS]+<L.>")
PrmanOutputChannelDefine("shadow", "color lpe:holdouts;unoccluded;C[DS]+<L.>")




-- get path for render outputs and name of the current shot
local shot_path = Attribute.GetStringValue(Interface.GetAttr("user.shotPath"), "")
local shot_name = Attribute.GetStringValue(Interface.GetAttr("user.shotName"), "")

-- create full path string to save multi-channeled exr file
local output_path = pystring.os.path.join(shot_path, string.format("%s_shadow.exr", shot_name) )
      output_path = pystring.os.path.normpath(output_path)


-- Create one render output for all "holdout" outputChannels
Interface.SetAttr("renderSettings.outputs.holdout.type", StringAttribute("raw"))
Interface.SetAttr("renderSettings.outputs.holdout.rendererSettings.channel", StringAttribute(channel_list))
Interface.SetAttr("renderSettings.outputs.holdout.locationType", StringAttribute("file"))
Interface.SetAttr("renderSettings.outputs.holdout.locationSettings.renderLocation", StringAttribute(output_path))




-- create statistic file at will
if CheckBox_StatisticFile > 0.0 then

    -- create full path string to save multi-channeled exr file
    local statistic_path = pystring.os.path.join(shot_path, string.format("%s_shadow.xml", shot_name) )
          statistic_path = pystring.os.path.normpath(statistic_path)

    -- switch on statistics output
    Interface.SetAttr("prmanGlobalStatements.options.statistics.level", IntAttribute(1))
    Interface.SetAttr("prmanGlobalStatements.options.statistics.xmlfilename", StringAttribute(statistic_path))

end
