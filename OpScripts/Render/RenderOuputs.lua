--[[

Location: /root
renderer: prman

Add outputChannel attributes for each LightGroup
and create render outputs as multi-channeled exr files

Required attributes:
    user.shotPath             (string) path where result render file will be saved
    user.shotName             (string) frame numbered name ("shotName_F%03d"%frame -> AttributeSet)

Required user defined parameters:
    user.ExrCombine           (string) path to "ExrCombine.exe" console program (path.join(getenv("KATANA_HOME", ""), "bin", "ExrCombine.exe"))

    user.LightGrouped         (number) switch to generate separated output files for each light with defined group name

    user.CreateStatisticFile  (number) switch to create statistic file

    user.beauty                                           (number) switch to include "Ci,a" channels to multi-channeled exr files

    user.BasicOutputs.directDiffuse                       (number) switch to include "directDiffuse" channel to multi-channeled exr files
    user.BasicOutputs.indirectDiffuse                     (number) ...
    user.BasicOutputs.directSpecular                      (number) ...
    user.BasicOutputs.indirectSpecular                    (number) ...
    user.BasicOutputs.subsurface                          (number) ...
    user.BasicOutputs.transmissive                        (number) ...
    user.BasicOutputs.emissive                            (number) ...

    user.PerLobeOutputs.directDiffuseLobe                 (number) ...
    user.PerLobeOutputs.indirectDiffuseLobe               (number) ...
    user.PerLobeOutputs.directSpecularPrimaryLobe         (number) ...
    user.PerLobeOutputs.indirectSpecularPrimaryLobe       (number) ...
    user.PerLobeOutputs.directSpecularRoughLobe           (number) ...
    user.PerLobeOutputs.indirectSpecularRoughLobe         (number) ...
    user.PerLobeOutputs.directSpecularClearcoatLobe       (number) ...
    user.PerLobeOutputs.indirectSpecularClearcoatLobe     (number) ...
    user.PerLobeOutputs.directSpecularIridescenceLobe     (number) ...
    user.PerLobeOutputs.indirectSpecularIridescenceLobe   (number) ...
    user.PerLobeOutputs.directSpecularFuzzLobe            (number) ...
    user.PerLobeOutputs.indirectSpecularFuzzLobe          (number) ...
    user.PerLobeOutputs.directSpecularGlassLobe           (number) ...
    user.PerLobeOutputs.indirectSpecularGlassLobe         (number) ...
    user.PerLobeOutputs.transmissiveGlassLobe             (number) ...
    user.PerLobeOutputs.transmissiveSingleScatterLobe     (number) ...
    user.PerLobeOutputs.subsurfaceLobe                    (number) ...
    user.PerLobeOutputs.emissive                          (number) ...

    user.Extra. ...                                       (string array) optionally generated parameter with python script (button) for custom lpe:

                                                                         user_parameter = NodegraphAPI.GetNode("RenderOutputs").getParameter("user.Extra")
                                                                         new_parameter = user_parameter.createChildStringArray("LPE1", 2)

                                                                         new_parameter.getChildByIndex(0).setValue("lpeName", 0)
                                                                         new_parameter.getChildByIndex(1).setValue("color lpe:C.*[<L.>O]", 0)


    user.FilenameTag                                      (string) string that will be added to name of output files

]]




-- get path for render outputs and name of the current shot
local shot_path                                 = Attribute.GetStringValue(Interface.GetAttr("user.shotPath"), "")
local shot_name                                 = Attribute.GetStringValue(Interface.GetAttr("user.shotName"), "")

-- get string value of path to "ExrCombine.exe"
local ExrCombine_path                           = Attribute.GetStringValue(Interface.GetOpArg("user.ExrCombine"), "")

-- get string value to add to output files
local FilenameTag                               = Attribute.GetStringValue(Interface.GetOpArg("user.FilenameTag"), "")
if    FilenameTag ~= "" then FilenameTag = "_" .. FilenameTag end

-- get switch from user defined parameter to separate output files
local lightGroupedOutputs                        = Attribute.GetFloatValue(Interface.GetOpArg("user.LightGrouped"), 0)

-- get switch from user defined parameter to create statistic file
local CheckBox_StatisticFile                     = Attribute.GetFloatValue(Interface.GetOpArg("user.CreateStatisticFile"), 0)


-- get switches to include channel to multi-channeled exr files
local CheckBox_beauty                            = Attribute.GetFloatValue(Interface.GetOpArg("user.beauty"), 0.0)

local CheckBox_directDiffuse                     = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.directDiffuse"), 0.0)
local CheckBox_indirectDiffuse                   = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.indirectDiffuse"), 0.0)
local CheckBox_directSpecular                    = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.directSpecular"), 0.0)
local CheckBox_indirectSpecular                  = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.indirectSpecular"), 0.0)
local CheckBox_subsurface                        = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.subsurface"), 0.0)
local CheckBox_transmissive                      = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.transmissive"), 0.0)
local CheckBox_emissive_basic                    = Attribute.GetFloatValue(Interface.GetOpArg("user.BasicOutputs.emissive"), 0.0)

local CheckBox_directDiffuseLobe                 = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directDiffuseLobe"), 0.0)
local CheckBox_indirectDiffuseLobe               = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectDiffuseLobe"), 0.0)
local CheckBox_directSpecularPrimaryLobe         = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directSpecularPrimaryLobe"), 0.0)
local CheckBox_indirectSpecularPrimaryLobe       = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectSpecularPrimaryLobe"), 0.0)
local CheckBox_directSpecularRoughLobe           = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directSpecularRoughLobe"), 0.0)
local CheckBox_indirectSpecularRoughLobe         = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectSpecularRoughLobe"), 0.0)
local CheckBox_directSpecularClearcoatLobe       = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directSpecularClearcoatLobe"), 0.0)
local CheckBox_indirectSpecularClearcoatLobe     = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectSpecularClearcoatLobe"), 0.0)
local CheckBox_directSpecularIridescenceLobe     = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directSpecularIridescenceLobe"), 0.0)
local CheckBox_indirectSpecularIridescenceLobe   = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectSpecularIridescenceLobe"), 0.0)
local CheckBox_directSpecularFuzzLobe            = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directSpecularFuzzLobe"), 0.0)
local CheckBox_indirectSpecularFuzzLobe          = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectSpecularFuzzLobe"), 0.0)
local CheckBox_directSpecularGlassLobe           = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.directSpecularGlassLobe"), 0.0)
local CheckBox_indirectSpecularGlassLobe         = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.indirectSpecularGlassLobe"), 0.0)
local CheckBox_transmissiveGlassLobe             = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.transmissiveGlassLobe"), 0.0)
local CheckBox_transmissiveSingleScatterLobe     = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.transmissiveSingleScatterLobe"), 0.0)
local CheckBox_subsurfaceLobe                    = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.subsurfaceLobe"), 0.0)
local CheckBox_emissive_lobe                     = Attribute.GetFloatValue(Interface.GetOpArg("user.PerLobeOutputs.emissive"), 0.0)


local Group_BasicOutputs = {
    CheckBox_directDiffuse,
    CheckBox_indirectDiffuse,
    CheckBox_directSpecular,
    CheckBox_indirectSpecular,
    CheckBox_subsurface,
    CheckBox_transmissive,
    CheckBox_emissive_basic}

local Group_PerLobeOutputs = {
    CheckBox_directDiffuseLobe,
    CheckBox_indirectDiffuseLobe,
    CheckBox_directSpecularPrimaryLobe,
    CheckBox_indirectSpecularPrimaryLobe,
    CheckBox_directSpecularRoughLobe,
    CheckBox_indirectSpecularRoughLobe,
    CheckBox_directSpecularClearcoatLobe,
    CheckBox_indirectSpecularClearcoatLobe,
    CheckBox_directSpecularIridescenceLobe,
    CheckBox_indirectSpecularIridescenceLobe,
    CheckBox_directSpecularFuzzLobe,
    CheckBox_indirectSpecularFuzzLobe,
    CheckBox_directSpecularGlassLobe,
    CheckBox_indirectSpecularGlassLobe,
    CheckBox_transmissiveGlassLobe,
    CheckBox_transmissiveSingleScatterLobe,
    CheckBox_subsurfaceLobe,
    CheckBox_emissive_lobe}



-- check if there is at least one channel included
-- check if at least one PerLobe channel included
local hasOutputs = false
local hasLobes  = false


if CheckBox_beauty > 0.0 then
    hasOutputs = true
end


for i=1, #Group_BasicOutputs do
    if Group_BasicOutputs[i] > 0.0 then
        hasOutputs = true
    end
end


for i=1, #Group_PerLobeOutputs do
    if Group_PerLobeOutputs[i] > 0.0 then
        hasOutputs = true
        hasLobes  = true
    end
end


local extraLPEs = Interface.GetOpArg("user.Extra")
local extraDefaults = {"lpeName", "color lpe:C.*[<L.>O]"}

for i=2, extraLPEs:getNumberOfChildren() do
    local extraLPE_Item = extraLPEs:getChildByIndex(i-1):getNearestSample(0)

    local extraL_channel_name = extraLPE_Item[1]
    local extraL_channel_lpe  = extraLPE_Item[2]

    if extraL_channel_name ~= extraDefaults[1] and extraL_channel_lpe ~= extraDefaults[2] then
        if extraL_channel_name ~= "" and extraL_channel_lpe ~= "" then

            hasOutputs = true

        end
    end

end



-- to correctly render PerLobe LPE in Katana, you need to declare how these are routed to the outputs
if hasLobes then
    Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse2',  StringAttribute("Diffuse"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse3',  StringAttribute("Subsurface"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular2', StringAttribute("Specular"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular3', StringAttribute("RoughSpecular"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular4', StringAttribute("Clearcoat"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular5', StringAttribute("Iridescence"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular6', StringAttribute("Fuzz"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular7', StringAttribute("SingleScatter"))
    Interface.SetAttr('prmanGlobalStatements.options.lpe.specular8', StringAttribute("Glass"))
end


-- create global variables to use as buffers
local ExrCombine = ""
local deleteCommand = ""
local scriptCommand = ""

local channel_name = ""




function OutputChannelDefine (input_name, input_lpe, input_group, input_type)

    --[[
    Create outputChannel and local render output

    Arguments:
        input_name  (string): name of outputChannel
        input_lpe   (string): Light Path Expression ("color lpe:C.*[<L.>O]")
        input_group (string): single group name or string of group items separated by comma symbol
        input_type  (string): type of channel data ("varying color")
    ]]


    -- set default value for the "input_type" argument
    input_type  = input_type  or "varying color"

    -- adjust outputChannel name if LightGroup is set
    if input_group == "" then channel_name = "" .. input_name .. ""
    else channel_name = input_name .. "_" .. input_group
    end
    if channel_name == "Ci" then channel_name = input_name .. "_multichanneled" end


    -- create outputChannel
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", channel_name), StringAttribute(input_type))
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", channel_name), StringAttribute(channel_name))

    -- set Light Path Expression
    if input_lpe ~= "" then
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", channel_name), StringAttribute("string"))
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", channel_name), StringAttribute(input_lpe))
    end


    -- do not create render output as temporary "exr" file for alpha channel
    if channel_name ~= "a" then

        -- exceptions for combined "Ci,a" channel
        local exrChannel = "" .. input_name .. ""
        local channel_name_value = "" .. channel_name .. ""
        if input_name == "Ci" then
            exrChannel = "primary"
            channel_name_value = channel_name .. ",a" end

        -- create path to save channel as temporary "exr" file
        local combineItem_path = pystring.os.path.join(shot_path, string.format("_temp_%s.exr", channel_name) )
              combineItem_path = pystring.os.path.normpath(combineItem_path)

        -- add path to temporary "exr" file for current channel as argument to "ExrCombine.exe"
        -- the same for delete command
        ExrCombine = ExrCombine .. string.format(' "%s" ', combineItem_path) .. exrChannel
        deleteCommand = deleteCommand .. string.format(' "%s"', combineItem_path)

        -- create render output for current outputChannel
        Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.channel", channel_name), StringAttribute(channel_name_value))
        Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.convertSettings.exrBitDepth", channel_name), StringAttribute("32"))
        Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.convertSettings.exrOptimize", channel_name), StringAttribute("No"))
        Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.colorConvert", channel_name), StringAttribute("No"))
        Interface.SetAttr(string.format("renderSettings.outputs.%s.locationType", channel_name), StringAttribute("file"))
        Interface.SetAttr(string.format("renderSettings.outputs.%s.locationSettings.renderLocation", channel_name), StringAttribute(combineItem_path))
    end

end



function RenderOutput (input_group, inversion_flag)

    --[[
    Create render output as multi-channeled exr file depending on input LightGroup

    Arguments:
        input_group   (string): single group name or string of group items separated by comma symbol
        inversion_flag  (bool): flag to create LightGroups expression with exception
    ]]


    -- define expression and output name tag variables as arguments for "OutputChannelDefine" function
    local lpe_value  = ""
    local lpe_group  = ""

    -- define tag and output variables to adjust renderSettings.output attribute
    local group_tag  = ""
    local output     = "multichanneled"


    -- adjust variables depending on input arguments:

    if input_group == "default" then -- leave all variables as they are

    elseif inversion_flag then -- create inverted for all defined LightGroups expression part

        -- split string to table separated by comma symbol
        local items_table = {}
        for item in string.gmatch(input_group, "([^"..",".."]+)") do table.insert(items_table, item) end

        -- concatenate LightGroups wrapped in quote symbols
        local all_groups = ""
        for i=1, #items_table do
            local value = string.format("'%s'", items_table[i])

            if all_groups == "" then all_groups = value
            else all_groups = all_groups .. value end
        end

        -- adjust variables
        lpe_value = string.format("[^%s]", all_groups)
        lpe_group = "default"
        group_tag = "_" .. lpe_group .. "LightGroup"
        output    = output .. group_tag

    else -- create expression part for single LightGroup

        -- adjust variables
        lpe_value = string.format("['%s']", input_group)
        lpe_group = input_group
        group_tag = "_" .. lpe_group .. "LightGroup"
        output    = output .. group_tag
    end


    -- reset global variables to default state
    ExrCombine    = string.format('"%s"', pystring.os.path.normpath(ExrCombine_path))
    deleteCommand = "del"


    -- add "Ci" and "a" channels
    if CheckBox_beauty > 0.0 then
    OutputChannelDefine("a", "", "", "varying float")
    OutputChannelDefine("Ci", string.format("color lpe:C.*[<L.%s>O]", lpe_value), lpe_group) end


    -- add channels for PerLobe LPE workflow
    if CheckBox_directDiffuseLobe > 0.0               then OutputChannelDefine("directDiffuseLobe",               string.format("color lpe:CD2[<L.%s>O]",         lpe_value), lpe_group) end
    if CheckBox_indirectDiffuseLobe > 0.0             then OutputChannelDefine("indirectDiffuseLobe",             string.format("color lpe:CD2[DS]+[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_directSpecularPrimaryLobe > 0.0       then OutputChannelDefine("directSpecularPrimaryLobe",       string.format("color lpe:CS2[<L.%s>O]",         lpe_value), lpe_group) end
    if CheckBox_indirectSpecularPrimaryLobe > 0.0     then OutputChannelDefine("indirectSpecularPrimaryLobe",     string.format("color lpe:CS2[DS]+[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_directSpecularRoughLobe > 0.0         then OutputChannelDefine("directSpecularRoughLobe",         string.format("color lpe:CS3[<L.%s>O]",         lpe_value), lpe_group) end
    if CheckBox_indirectSpecularRoughLobe > 0.0       then OutputChannelDefine("indirectSpecularRoughLobe",       string.format("color lpe:CS3[DS]+[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_directSpecularClearcoatLobe > 0.0     then OutputChannelDefine("directSpecularClearcoatLobe",     string.format("color lpe:CS4[<L.%s>O]",         lpe_value), lpe_group) end
    if CheckBox_indirectSpecularClearcoatLobe > 0.0   then OutputChannelDefine("indirectSpecularClearcoatLobe",   string.format("color lpe:CS4[DS]+[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_directSpecularIridescenceLobe > 0.0   then OutputChannelDefine("directSpecularIridescenceLobe",   string.format("color lpe:CS5[<L.%s>O]",         lpe_value), lpe_group) end
    if CheckBox_indirectSpecularIridescenceLobe > 0.0 then OutputChannelDefine("indirectSpecularIridescenceLobe", string.format("color lpe:CS5[DS]+[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_directSpecularFuzzLobe > 0.0          then OutputChannelDefine("directSpecularFuzzLobe",          string.format("color lpe:CS6[<L.%s>O]",         lpe_value), lpe_group) end
    if CheckBox_indirectSpecularFuzzLobe > 0.0        then OutputChannelDefine("indirectSpecularFuzzLobe",        string.format("color lpe:CS6[DS]+[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_directSpecularGlassLobe > 0.0         then OutputChannelDefine("directSpecularGlassLobe",         string.format("color lpe:C<RS8>[<L.%s>O]",      lpe_value), lpe_group) end
    if CheckBox_indirectSpecularGlassLobe > 0.0       then OutputChannelDefine("indirectSpecularGlassLobe",       string.format("color lpe:C<RS8>[DS]+[<L.%s>O]", lpe_value), lpe_group) end

    if CheckBox_transmissiveGlassLobe > 0.0           then OutputChannelDefine("transmissiveGlassLobe",           string.format("color lpe:C<TS8>[DS]*[<L.%s>O]", lpe_value), lpe_group) end
    if CheckBox_transmissiveSingleScatterLobe > 0.0   then OutputChannelDefine("transmissiveSingleScatterLobe",   string.format("color lpe:CS7[DS]*[<L.%s>O]",    lpe_value), lpe_group) end

    if CheckBox_subsurfaceLobe > 0.0                  then OutputChannelDefine("subsurfaceLobe",                  string.format("color lpe:CD3[DS]*[<L.%s>O]",    lpe_value), lpe_group) end


    -- add channels for Basic LPE workflow
    if CheckBox_directDiffuse > 0.0                   then OutputChannelDefine("directDiffuse",                   string.format("color lpe:C<RD>[<L.%s>O]",       lpe_value), lpe_group) end
    if CheckBox_indirectDiffuse > 0.0                 then OutputChannelDefine("indirectDiffuse",                 string.format("color lpe:C<RD>[DS]+[<L.%s>O]",  lpe_value), lpe_group) end

    if CheckBox_directSpecular > 0.0                  then OutputChannelDefine("directSpecular",                  string.format("color lpe:C<RS>[<L.%s>O]",       lpe_value), lpe_group) end
    if CheckBox_indirectSpecular > 0.0                then OutputChannelDefine("indirectSpecular",                string.format("color lpe:C<RS>[DS]+[<L.%s>O]",  lpe_value), lpe_group) end

    if CheckBox_subsurface > 0.0                      then OutputChannelDefine("subsurface",                      string.format("color lpe:C<TD>[DS]*[<L.%s>O]",  lpe_value), lpe_group) end
    if CheckBox_transmissive > 0.0                    then OutputChannelDefine("transmissive",                    string.format("color lpe:C<TS>[DS]*[<L.%s>O]",  lpe_value), lpe_group) end


    if CheckBox_emissive_basic > 0.0 or CheckBox_emissive_lobe > 0.0 then
                                                           OutputChannelDefine("emissive",                        string.format("color lpe:C[<L.%s>O]",           lpe_value), lpe_group) end


    -- add extra lpe channels
    for i=2, extraLPEs:getNumberOfChildren() do
        local extraLPE_Item = extraLPEs:getChildByIndex(i-1):getNearestSample(0)

        local extraL_channel_name = extraLPE_Item[1]
        local extraL_channel_lpe  = extraLPE_Item[2]

        if extraL_channel_name ~= extraDefaults[1] and extraL_channel_lpe ~= extraDefaults[2] then
            if extraL_channel_name ~= "" and extraL_channel_lpe ~= "" then

                OutputChannelDefine(extraL_channel_name, extraL_channel_lpe, lpe_group)

            end
        end

    end



    -- create full path string to save multi-channeled exr file
    local output_path = pystring.os.path.join(shot_path, string.format("%s%s%s.exr", shot_name, FilenameTag, group_tag) )
          output_path = pystring.os.path.normpath(output_path)

    -- create "cmd" command
    scriptCommand = ExrCombine .. string.format(' "%s"', output_path)


    -- merge all render outputs to multi-channeled exr file
    Interface.SetAttr(string.format("renderSettings.outputs.%s.type", output), StringAttribute("script"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.scriptInput", output), StringAttribute(channel_name))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.scriptCommand", output), StringAttribute(scriptCommand))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.scriptHasOutput", output), IntAttribute(0))

    -- delete all temporary "exr" files
    Interface.SetAttr(string.format("renderSettings.outputs.%s_cleaner.type", output), StringAttribute("script"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s_cleaner.rendererSettings.scriptInput", output), StringAttribute(channel_name))
    Interface.SetAttr(string.format("renderSettings.outputs.%s_cleaner.rendererSettings.scriptCommand", output), StringAttribute(deleteCommand))
    Interface.SetAttr(string.format("renderSettings.outputs.%s_cleaner.rendererSettings.scriptHasOutput", output), IntAttribute(0))

end





-- define LightGroup collector
local light_groups = {}

-- for each light
local light_list = Interface.GetGlobalAttr("lightList", "/root/world")
for i=0, light_list:getNumberOfChildren()-1 do

    -- get SceneGraph path of current light
    local light_attributes = light_list:getChildByIndex(i)
    local SceneGraph_path  = light_attributes:getChildByName("path")
          SceneGraph_path  = Attribute.GetStringValue(SceneGraph_path, "")

    -- get LightGroup of current light
    local light_group = Interface.GetGlobalAttr("material.prmanLightParams.lightGroup", SceneGraph_path)

    if light_group ~= nil then light_group = Attribute.GetStringValue(light_group, '')
    else light_group = "default" end


    -- check if light is on
    local mute = Interface.GetAttr("info.light.mute", SceneGraph_path)

    if mute then
        if Interface.GetAttr("info.light.mute", SceneGraph_path):getValue() == 1 then mute = true
        else  mute = false end

    else mute = false end


    -- add LightGroup to collector
    if not mute then
        light_groups[#light_groups+1] = light_group
    end

end




-- get rid of empty and duplicate items
-- check if there is at least one light without LightGroup
local group_items = {}
local hash = {}
local empties = false

for i=1, #light_groups do
    local value = light_groups[i]
    if value ~= "default" then
        if not hash[value] then
            group_items[#group_items+1] = value
            hash[value] = true
        end
    elseif value == "default" then
        empties = true
    end
end

light_groups = group_items




-- create render outputs for included channels
if hasOutputs then

    -- if switch for separated files is ON
    -- then generate output files for each light with defined group name
    if lightGroupedOutputs > 0 then

        -- for each LightGroup create its own render output as multi-channeled exr file
        for i=1, #light_groups do RenderOutput(light_groups[i]) end

        -- if there is at least one light without LightGroup
        if empties then
            if #light_groups > 0 then

                -- if there are some lights with LightGroups and some without LightGroups
                -- then create one render output for all empty LightGroups
                RenderOutput(table.concat(light_groups, ","), true)

            else
                -- if there is no LightGroup at all
                -- then create one render output as multi-channeled exr file
                RenderOutput("default")

            end
        end


    -- if switch for separated files is OFF
    -- then create one render output as multi-channeled exr file
    else RenderOutput("default") end



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
