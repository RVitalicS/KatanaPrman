--[[

Location: /root
renderer: prman

Add outputChannel attributes for AOVs and create render output as multi-channeled exr file

Required attributes:
    user.BuiltIn.shotPath           (string) path where result render file will be saved
    user.BuiltIn.shotName           (string) frame numbered name ("shotName_F%03d"%frame -> AttributeSet)

Required user defined parameters:
    user.Holdout.ouputAOVs          (number) switch to include "occluded" and "shadow" channels to multi-channeled exr files

    user.BuiltIn.Ci                 (number) switch to include built-in AOV channel to multi-channeled exr files
    user.BuiltIn.a                  (number) ...
    user.BuiltIn.time               (number) ...
    user.BuiltIn.Oi                 (number) ...
    user.BuiltIn.id                 (number) ...
    user.BuiltIn.rawId              (number) ...
    user.BuiltIn.cpuTime            (number) ...
    user.BuiltIn.sampleCount        (number) ...
    user.BuiltIn.curvature          (number) ...
    user.BuiltIn.mpSize             (number) ...
    user.BuiltIn.biasR              (number) ...
    user.BuiltIn.biasT              (number) ...
    user.BuiltIn.incidentRayRadius  (number) ...
    user.BuiltIn.incidentRaySpread  (number) ...
    user.BuiltIn.P                  (number) ...
    user.BuiltIn.Po                 (number) ...
    user.BuiltIn.dPdu               (number) ...
    user.BuiltIn.dPdv               (number) ...
    user.BuiltIn.dPdw               (number) ...
    user.BuiltIn.PRadius            (number) ...
    user.BuiltIn.du                 (number) ...
    user.BuiltIn.dv                 (number) ...
    user.BuiltIn.dw                 (number) ...
    user.BuiltIn.u                  (number) ...
    user.BuiltIn.v                  (number) ...
    user.BuiltIn.w                  (number) ...
    user.BuiltIn.Ngn                (number) ...
    user.BuiltIn.Nn                 (number) ...
    user.BuiltIn.dPdtime            (number) ...
    user.BuiltIn.Non                (number) ...
    user.BuiltIn.motionBack         (number) ...
    user.BuiltIn.motionFore         (number) ...
    user.BuiltIn.Tn                 (number) ...
    user.BuiltIn.Vn                 (number) ...
    user.BuiltIn.VLen               (number) ...
    user.BuiltIn.z                  (number) ...
    user.BuiltIn.outsideIOR         (number) ...

    user.Extra. ...                 (string array) optionally generated parameter with python script (button):

                                                       user_parameter = NodegraphAPI.GetNode("RenderAOVs").getParameter("user.Extra")
                                                       new_parameter = user_parameter.createChildStringArray("AOV1", 2)

                                                       new_parameter.getChildByIndex(0).setValue("aovName", 0)
                                                       new_parameter.getChildByIndex(1).setValue("varying color (float, vector, normal)", 0)


    user.FilenameTag                (string) string that will be added to name of output files

    user.CreateStatisticFile        (number) switch to create statistic file

]]





-- get switches to include channel to multi-channeled exr files
local CheckBox_holdouts          = Attribute.GetFloatValue(Interface.GetOpArg("user.Holdout.ouputAOVs"), 0.0)

local CheckBox_Ci                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Ci"), 0.0)
local CheckBox_a                 = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.a"), 0.0)
local CheckBox_time              = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.time"), 0.0)
local CheckBox_Oi                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Oi"), 0.0)
local CheckBox_id                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.id"), 0.0)
local CheckBox_rawId             = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.rawId"), 0.0)
local CheckBox_cpuTime           = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.cpuTime"), 0.0)
local CheckBox_sampleCount       = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.sampleCount"), 0.0)
local CheckBox_curvature         = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.curvature"), 0.0)
local CheckBox_mpSize            = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.mpSize"), 0.0)
local CheckBox_biasR             = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.biasR"), 0.0)
local CheckBox_biasT             = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.biasT"), 0.0)
local CheckBox_incidentRayRadius = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.incidentRayRadius"), 0.0)
local CheckBox_incidentRaySpread = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.incidentRaySpread"), 0.0)
local CheckBox_P                 = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.P"), 0.0)
local CheckBox_Po                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Po"), 0.0)
local CheckBox_dPdu              = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.dPdu"), 0.0)
local CheckBox_dPdv              = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.dPdv"), 0.0)
local CheckBox_dPdw              = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.dPdw"), 0.0)
local CheckBox_PRadius           = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.PRadius"), 0.0)
local CheckBox_du                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.du"), 0.0)
local CheckBox_dv                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.dv"), 0.0)
local CheckBox_dw                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.dw"), 0.0)
local CheckBox_u                 = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.u"), 0.0)
local CheckBox_v                 = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.v"), 0.0)
local CheckBox_w                 = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.w"), 0.0)
local CheckBox_Ngn               = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Ngn"), 0.0)
local CheckBox_Nn                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Nn"), 0.0)
local CheckBox_dPdtime           = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.dPdtime"), 0.0)
local CheckBox_Non               = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Non"), 0.0)
local CheckBox_motionBack        = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.motionBack"), 0.0)
local CheckBox_motionFore        = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.motionFore"), 0.0)
local CheckBox_Tn                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Tn"), 0.0)
local CheckBox_Vn                = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.Vn"), 0.0)
local CheckBox_VLen              = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.VLen"), 0.0)
local CheckBox_z                 = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.z"), 0.0)
local CheckBox_outsideIOR        = Attribute.GetFloatValue(Interface.GetOpArg("user.BuiltIn.outsideIOR"), 0.0)

-- get switch from user defined parameter to create statistic file
local CheckBox_StatisticFile     = Attribute.GetFloatValue(Interface.GetOpArg("user.CreateStatisticFile"), 0)

-- get string value to add to output files
local FilenameTag               = Attribute.GetStringValue(Interface.GetOpArg("user.FilenameTag"), "")
if    FilenameTag ~= "" then FilenameTag = "_" .. FilenameTag end


-- variable that collect all defined here AOV channels as a string
-- and will be used to adjust renderSettings.output attribute
local channel_list = ""



function PrmanOutputChannelDefine (input_name, input_type, input_lpe)

    --[[
    Works the same way as the PrmanOutputChannelDefine node plus collect defined channels

    Arguments:
        input_name  (string): name of outputChannel
        input_type  (string): type of channel data
        input_lpe   (string): Light Path Expression ("color lpe:C.*[<L.>O]")
    ]]


    -- set default value for the "input_lpe" argument
    input_lpe = input_lpe or ""

    -- add current AOV channel to global variable
    if channel_list == "" then
        channel_list = "" .. input_name .. ""
    else
        channel_list = channel_list .. "," .. input_name
    end

    -- edit name for single channel output (replace dot character by underscore)
    local outputChannel_name = "" .. input_name .. ""
          outputChannel_name = outputChannel_name:gsub("%.", "_")

    -- create outputChannel
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", outputChannel_name), StringAttribute(input_type))
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", outputChannel_name), StringAttribute(input_name))

        -- set Light Path Expression
    if input_lpe ~= "" then
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", outputChannel_name), StringAttribute("string"))
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", outputChannel_name), StringAttribute(input_lpe))
    end

end




-- add built-in AOV channels to include to multi-channeled exr files
if CheckBox_Ci > 0.0 then                PrmanOutputChannelDefine("Ci",                "varying color")  end
if CheckBox_a > 0.0 then                 PrmanOutputChannelDefine("a",                 "varying float")  end
if CheckBox_time > 0.0 then              PrmanOutputChannelDefine("time",              "varying float")  end
if CheckBox_Oi > 0.0 then                PrmanOutputChannelDefine("Oi",                "varying color")  end
if CheckBox_id > 0.0 then                PrmanOutputChannelDefine("id",                "varying float")  end
if CheckBox_rawId > 0.0 then             PrmanOutputChannelDefine("rawId",             "varying float")  end
if CheckBox_cpuTime > 0.0 then           PrmanOutputChannelDefine("cpuTime",           "varying float")  end
if CheckBox_sampleCount > 0.0 then       PrmanOutputChannelDefine("sampleCount",       "varying float")  end
if CheckBox_curvature > 0.0 then         PrmanOutputChannelDefine("curvature",         "varying float")  end
if CheckBox_mpSize > 0.0 then            PrmanOutputChannelDefine("mpSize",            "varying float")  end
if CheckBox_biasR > 0.0 then             PrmanOutputChannelDefine("biasR",             "varying float")  end
if CheckBox_biasT > 0.0 then             PrmanOutputChannelDefine("biasT",             "varying float")  end
if CheckBox_incidentRayRadius > 0.0 then PrmanOutputChannelDefine("incidentRayRadius", "varying float")  end
if CheckBox_incidentRaySpread > 0.0 then PrmanOutputChannelDefine("incidentRaySpread", "varying float")  end
if CheckBox_P > 0.0 then                 PrmanOutputChannelDefine("P",                 "varying vector") end
if CheckBox_Po > 0.0 then                PrmanOutputChannelDefine("Po",                "varying vector") end
if CheckBox_dPdu > 0.0 then              PrmanOutputChannelDefine("dPdu",              "varying vector") end
if CheckBox_dPdv > 0.0 then              PrmanOutputChannelDefine("dPdv",              "varying vector") end
if CheckBox_dPdw > 0.0 then              PrmanOutputChannelDefine("dPdw",              "varying vector") end
if CheckBox_PRadius > 0.0 then           PrmanOutputChannelDefine("PRadius",           "varying float")  end
if CheckBox_du > 0.0 then                PrmanOutputChannelDefine("du",                "varying float")  end
if CheckBox_dv > 0.0 then                PrmanOutputChannelDefine("dv",                "varying float")  end
if CheckBox_dw > 0.0 then                PrmanOutputChannelDefine("dw",                "varying float")  end
if CheckBox_u > 0.0 then                 PrmanOutputChannelDefine("u",                 "varying float")  end
if CheckBox_v > 0.0 then                 PrmanOutputChannelDefine("v",                 "varying float")  end
if CheckBox_w > 0.0 then                 PrmanOutputChannelDefine("w",                 "varying float")  end
if CheckBox_Ngn > 0.0 then               PrmanOutputChannelDefine("Ngn",               "varying normal") end
if CheckBox_Nn > 0.0 then                PrmanOutputChannelDefine("Nn",                "varying normal") end
if CheckBox_dPdtime > 0.0 then           PrmanOutputChannelDefine("dPdtime",           "varying vector") end
if CheckBox_Non > 0.0 then               PrmanOutputChannelDefine("Non",               "varying normal") end
if CheckBox_motionBack > 0.0 then        PrmanOutputChannelDefine("motionBack",        "varying vector") end
if CheckBox_motionFore > 0.0 then        PrmanOutputChannelDefine("motionFore",        "varying vector") end
if CheckBox_Tn > 0.0 then                PrmanOutputChannelDefine("Tn",                "varying vector") end
if CheckBox_Vn > 0.0 then                PrmanOutputChannelDefine("Vn",                "varying vector") end
if CheckBox_VLen > 0.0 then              PrmanOutputChannelDefine("VLen",              "varying float")  end
if CheckBox_z > 0.0 then                 PrmanOutputChannelDefine("z",                 "varying float")  end
if CheckBox_outsideIOR > 0.0 then        PrmanOutputChannelDefine("outsideIOR",        "varying float")  end


-- add holdout channels to include to multi-channeled exr files
if CheckBox_holdouts > 0.0 then          PrmanOutputChannelDefine("occluded",          "varying color", "color lpe:holdouts;C[DS]+<L.>")
                                         PrmanOutputChannelDefine("shadow",            "varying color", "color lpe:holdouts;unoccluded;C[DS]+<L.>") end



-- optionally create aov channels to include to multi-channeled exr files
local extraAOVs = Interface.GetOpArg("user.Extra")
local extraDefaults = {"aovName", "varying color (float, vector, normal)"}

for i=2, extraAOVs:getNumberOfChildren() do
    local extraAOV_Item = extraAOVs:getChildByIndex(i-1):getNearestSample(0)

    local channel_name = extraAOV_Item[1]
    local channel_type = extraAOV_Item[2]
    local cahennl_lpe  = "" .. channel_name .. ""

    if channel_type == "varying float" then
        channel_name = channel_name .. ".r"
    end

    if channel_name ~= extraDefaults[1] and channel_type ~= extraDefaults[2] then
        if channel_name ~= "" and channel_type ~= "" then

            PrmanOutputChannelDefine(channel_name, channel_type, cahennl_lpe)

        end
    end

end





-- get path for render outputs and name of the current shot
local shot_path = Attribute.GetStringValue(Interface.GetAttr("user.shotPath"), "")
local shot_name = Attribute.GetStringValue(Interface.GetAttr("user.shotName"), "")

-- create full path string to save multi-channeled exr file
local output_path = pystring.os.path.join(shot_path, string.format("%s%s.exr", shot_name, FilenameTag) )
      output_path = pystring.os.path.normpath(output_path)



-- Create one render output for chosen AOV outputChannels
if channel_list ~= "" then

    Interface.SetAttr('renderSettings.outputs.aovs.type', StringAttribute("raw"))
    Interface.SetAttr('renderSettings.outputs.aovs.rendererSettings.channel', StringAttribute(channel_list))
    Interface.SetAttr('renderSettings.outputs.aovs.locationType', StringAttribute("file"))
    Interface.SetAttr('renderSettings.outputs.aovs.locationSettings.renderLocation', StringAttribute(output_path))


        -- create statistic file at will
    if CheckBox_StatisticFile > 0.0 then

        -- create full path string to save multi-channeled exr file
        local statistic_path = pystring.os.path.join(shot_path, string.format("%s%s.xml", shot_name, FilenameTag) )
              statistic_path = pystring.os.path.normpath(statistic_path)

        -- switch on statistics output
        Interface.SetAttr("prmanGlobalStatements.options.statistics.level", IntAttribute(1))
        Interface.SetAttr("prmanGlobalStatements.options.statistics.xmlfilename", StringAttribute(statistic_path))
    end


end
