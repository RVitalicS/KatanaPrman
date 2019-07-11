--[[

    location: /root
    renderer: prman

    Add outputChannel attributes for AOVs and create render output as multi-channeled exr file

    Required attributes:
        user.BuiltIn.shotPath           (string) path where result render file will be saved
        user.BuiltIn.shotName           (string) frame numbered name ("shotName_F%03d"%frame -> AttributeSet)

    Required user defined parameters:
        user.Holdout.outputAOVs          (number) switch to include "occluded" and "shadow" channels to multi-channeled exr file

        user.BuiltIn.Ci                 (number) switch to include built-in AOV channel to multi-channeled exr file
        user.BuiltIn.a                  (number) ...
        ...

        user.Tee.diffuseColor           (number) switch to include unchanged shader value for diffuse color to multi-channeled exr file
        user.Tee.primSpecEdgeColor      (number) ...
        ...

        user.Extra. ...                 (string array) optionally generated parameter with python script (button):

                                                           user_parameter = NodegraphAPI.GetNode("RenderAOVs").getParameter("user.Extra")
                                                           new_parameter = user_parameter.createChildStringArray("AOV1", 2)

                                                           new_parameter.getChildByIndex(0).setValue("aovName", 0)
                                                           new_parameter.getChildByIndex(1).setValue("varying color (float, vector, normal)", 0)


        user.FilenameTag                (string) string that will be added to name of output file

        user.CreateStatisticFile        (number) switch to create statistic file

]]




-- define output name
local outputName = "aovs"

-- get switches to include channel to multi-channeled exr files
local CheckBox_holdouts      = Attribute.GetFloatValue(Interface.GetOpArg("user.Holdout.outputAOVs"), 0.0)

-- get switch from user defined parameter to create statistic file
local CheckBox_StatisticFile = Attribute.GetFloatValue(Interface.GetOpArg("user.CreateStatisticFile"), 0)

-- get string value to add to output files
local FilenameTag  = Attribute.GetStringValue(Interface.GetOpArg("user.FilenameTag"), "")
if FilenameTag ~= "" then
    outputName  = ""  .. FilenameTag .. ""
    FilenameTag = "_" .. FilenameTag end


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





function CheckboxSearcher(groupAttr, channelTable, forceRed, teeTag)

    --[[
        Looks for selected checkboxes
        in input group attribute (recursively)
        and creates outputChannels

        Arguments:
            groupAttr  (class GroupAttribute): user defined group with any hierarchy
            channelTable              (table): list of parameters for outputChannels
                                               {{name, type, lpe}, {...}}
            forceRed                   (bool): to move float outputChannel to "red" channel forcibly
            teeTag                     (bool): to add "tee_" prefix to outputChannel name
    ]]


    -- set default argument values
    forceRed = forceRed or false
    teeTag   = teeTag   or false


    -- in all items in input group
    for indexChild=1, groupAttr:getNumberOfChildren() do
        local item = groupAttr:getChildByIndex(indexChild-1)

        -- find group attributes and dive inside
        if Attribute.IsGroup(item) then
            CheckboxSearcher(item, channelTable, forceRed, teeTag) end

        -- find selected checkboxes
        if Attribute.IsFloat(item) then
        if Attribute.GetFloatValue(item, 0.0) > 0.0 then

            -- compare attribute name with outputChannel names
            local itemName  = groupAttr:getChildName(indexChild-1)
            for indexOutput=1, #channelTable do
            if itemName == channelTable[indexOutput][1] then

                -- get parameters and create outputChannel
                local channelName = channelTable[indexOutput][1]
                local channelType = channelTable[indexOutput][2]
                local channelLpe  = channelTable[indexOutput][3]

                if teeTag then
                    channelName  = "tee_" .. channelName
                    channelLpe   = "" .. channelName .. "" end

                if forceRed and channelType == "varying float" then
                    channelName = channelName .. ".r" end


                PrmanOutputChannelDefine(channelName, channelType, channelLpe)

            end
            end

        end
        end

    end
end





-- add built-in AOV channels to include to multi-channeled exr files
local builtInChannels = {
    {"Ci",                "varying color",  ""},
    {"a",                 "varying float",  ""},
    {"time",              "varying float",  ""},
    {"Oi",                "varying color",  ""},
    {"id",                "varying float",  ""},
    {"rawId",             "varying float",  ""},
    {"cpuTime",           "varying float",  ""},
    {"sampleCount",       "varying float",  ""},
    {"curvature",         "varying float",  ""},
    {"mpSize",            "varying float",  ""},
    {"biasR",             "varying float",  ""},
    {"biasT",             "varying float",  ""},
    {"incidentRayRadius", "varying float",  ""},
    {"incidentRaySpread", "varying float",  ""},
    {"P",                 "varying vector", ""},
    {"Po",                "varying vector", ""},
    {"dPdu",              "varying vector", ""},
    {"dPdv",              "varying vector", ""},
    {"dPdw",              "varying vector", ""},
    {"PRadius",           "varying float",  ""},
    {"du",                "varying float",  ""},
    {"dv",                "varying float",  ""},
    {"dw",                "varying float",  ""},
    {"u",                 "varying float",  ""},
    {"v",                 "varying float",  ""},
    {"w",                 "varying float",  ""},
    {"Ngn",               "varying normal", ""},
    {"Nn",                "varying normal", ""},
    {"dPdtime",           "varying vector", ""},
    {"Non",               "varying normal", ""},
    {"motionBack",        "varying vector", ""},
    {"motionFore",        "varying vector", ""},
    {"Tn",                "varying vector", ""},
    {"Vn",                "varying vector", ""},
    {"VLen",              "varying float",  ""},
    {"z",                 "varying float",  ""},
    {"outsideIOR",        "varying float",  ""}}

CheckboxSearcher(Interface.GetOpArg("user.BuiltIn"), builtInChannels)



-- add holdout channels to include to multi-channeled exr files
if CheckBox_holdouts > 0.0 then PrmanOutputChannelDefine("occluded", "varying color", "color lpe:holdouts;C[DS]+<L.>")
                                PrmanOutputChannelDefine("shadow",   "varying color", "color lpe:holdouts;unoccluded;C[DS]+<L.>") end



-- add "tee" AOV channels to include to multi-channeled exr files
local teeChannels = {
    {"diffuseColor",          "varying color", ""},
    {"primSpecEdgeColor",     "varying color", ""},
    {"primSpecRoughness",     "varying float", ""},
    {"roughSpecEdgeColor",    "varying color", ""},
    {"roughSpecRoughness",    "varying float", ""},
    {"clearcoatEdgeColor",    "varying color", ""},
    {"clearcoatRoughness",    "varying float", ""},
    {"subsurfaceColor",       "varying color", ""},
    {"subsurfaceDmfpColor",   "varying color", ""},
    {"singlescatterColor",    "varying color", ""},
    {"singlescatterMfpColor", "varying color", ""},
    {"glassRefractionColor",  "varying color", ""},
    {"glassRoughness",        "varying float", ""},
    {"glowColor",             "varying color", ""},
    {"bump",                  "varying float", ""},
    {"presence",              "varying float", ""},
    {"displacementScalar",    "varying float", ""},
    {"displacementVector",    "varying color", ""},
    {"mask",                  "varying float", ""}}

CheckboxSearcher(Interface.GetOpArg("user.Tee"), teeChannels, true, true)





-- optionally create aov channels to include to multi-channeled exr files
local extraAOVs = Interface.GetOpArg("user.Extra")
local extraDefaults = {"aovName", "varying color (float, vector, normal)"}

for indexChild=2, extraAOVs:getNumberOfChildren() do
    local extraAOV_Item = extraAOVs:getChildByIndex(indexChild-1):getNearestSample(0)

    local extraName = extraAOV_Item[1]
    local extraType = extraAOV_Item[2]
    local extraLpe  = "" .. extraName .. ""

    if extraType == "varying float" then
        extraName = extraName .. ".r" end

    if extraName ~= extraDefaults[1] and extraType ~= extraDefaults[2] then
        if extraName ~= "" and extraType ~= "" then

            PrmanOutputChannelDefine(extraName, extraType, extraLpe)

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

    Interface.SetAttr(string.format("renderSettings.outputs.%s.type", outputName), StringAttribute("raw"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.channel", outputName), StringAttribute(channel_list))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.locationType", outputName), StringAttribute("file"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.locationSettings.renderLocation", outputName), StringAttribute(output_path))


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
