--[[

Location: /root
renderer: arnold

Add outputChannel attributes to create render output as multichanneled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- get string value from added earlier user-defined attribute that contains path for render outputs
path_project = Interface.GetAttr("user.shotPath")
path_project = Attribute.GetStringValue(path_project, "")

-- get string value from added earlier user-defined attribute that contains name of the current shot
name = Interface.GetAttr("user.shotName")
name = Attribute.GetStringValue(name, "")



function ArnoldOutput (name, lpe, group)

    --[[
    Create outputChannel and local render output using name and Light Path Expression

    Arguments:
        name  (string): name of outputChannel
        lpe   (string): Light Path Expression ("color lpe:C.*[<L.>O]")
        group (string): name of the part that was separated by expression
    ]]


    -- define output data type with one exception
    local channel_type = "RGB"
    if name == "primary" then channel_type = "RGBA" end

    -- adjust outputChannel name if LightGroup is set
    if group == "" then name = name
    else name = name .. "_" .. group end

    -- add current LPE channel to global variable
    if channels == "" then channels = name
    else channels = channels .. "," .. name end


    -- create outputChannel by name
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.name", name), StringAttribute(name))
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.type", name), StringAttribute(channel_type))
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.channel", name), StringAttribute(name))

    -- add driver attributes
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.driverParameters.half_precision", name), IntAttribute(0))
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.driverParameters.tiled", name), IntAttribute(0))
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.driverParameters.color_space", name), StringAttribute("linear"))
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.driverParameters.autocrop", name), IntAttribute(0))

    -- set Light Path Expression
    Interface.SetAttr(string.format("arnoldGlobalStatements.outputChannels.%s.lightPathExpression", name), StringAttribute(lpe))


    -- create render output for current outputChannel
    Interface.SetAttr(string.format("renderSettings.outputs.%s.type", name), StringAttribute("raw"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.channel", name), StringAttribute(name))

end



-- global variable that collect all defined in 'RenderOutputDefine' LPE outputChannels as a string
-- and will be used to adjust renderSettings.output attribute
channels = ""



function RenderOutputDefine (group, inversion)

    --[[
    Create render output for Basic LPE workflow
    as multi-channeled exr file depending on input LightGroup

    Arguments:
        group   (string): single group name or string of group items separated by comma symbol
        inversion (bool): flag to create LightGroups expression with exception
    ]]


    -- define expression and output name tag variables as arguments for 'ArnoldOutput' function
    local lpe_value = ""
    local lpe_group = ""

    -- define tag and output variables to adjust renderSettings.output attribute
    local file_tag = ""
    local output = "multichanneled"


    -- adjust variables depending on input arguments:

    if group=="default" then -- leave all variables as they are

    elseif inversion then -- create inverted for all defined LightGroups expression part

        -- split string to table separated by comma symbol
        local items_table = {}
        for item in string.gmatch(group, "([^"..",".."]+)") do table.insert(items_table, item) end

        -- concatenate LightGroups wrapped in quote symbols
        local all_groups = ""
        for i=1, #items_table do
            local value = string.format("'%s'", items_table[i])

            if all_groups == "" then all_groups = value
            else all_groups = all_groups .. value end
        end

        -- adjust variables
        lpe_value = "'default'"
        lpe_group = "default"
        file_tag = "_" .. lpe_group .. "LightGroup"
        output = output .. file_tag

    else -- create expression part for single LightGroup

        -- adjust variables
        lpe_value = string.format("['%s']", group)
        lpe_group = group
        file_tag = "_" .. lpe_group .. "LightGroup"
        output = output .. file_tag
    end


    -- reset global variable for new render output
    channels = ""


    -- add 'beauty' channels
    ArnoldOutput("primary", string.format("C.*[<L.%s>O]", lpe_value), lpe_group)

    -- add all other built-in channels
    ArnoldOutput("diffuseDirect", string.format("C<RD>[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("diffuseIndirect", string.format("C<RD>[DSVOB].*[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("specularDirect", string.format("C<RS[^'coat''sheen']>[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("specularIndirect", string.format("C<RS[^'coat''sheen']>[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("sheenDirect", string.format("C<RS'sheen'>[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("sheenIndirect", string.format("C<RS'sheen'>[DSVOB].*[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("coatDirect", string.format("C<RS'coat'>[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("coatIndirect", string.format("C<RS'coat'>[DSVOB].*[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("transmissionDirect", string.format("C<TS>[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("transmissionIndirect", string.format("C<TS>[DSVOB].*[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("sssDirect", string.format("C<TD>[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("sssIndirect", string.format("C<TD>[DSVOB].*[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("volumeDirect", string.format("CV[<L.%s>O]", lpe_value), lpe_group)
    ArnoldOutput("volumeIndirect", string.format("CV[DSVOB].*[<L.%s>O]", lpe_value), lpe_group)

    ArnoldOutput("emission", "C[LO]", lpe_group)


    -- create full path string to save multi-channeled exr file
    local path = pystring.os.path.join(path_project, string.format("%s%s.exr", name, file_tag) )
    path = pystring.replace(path, "\\", "/")

    -- Merge all render outputs to multi-channeled exr file
    -- switch location type to 'file' mode and set 'renderLocation' parameter
    Interface.SetAttr(string.format("renderSettings.outputs.%s.type", output), StringAttribute("merge"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.mergeOutputs", output), StringAttribute(channels))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.locationType", output), StringAttribute("file"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.locationSettings.renderLocation", output), StringAttribute(path))

end



-- define LightGroup collector
local light_groups = {}


-- for each light
local light_list = Interface.GetAttr("lightList", "/root/world")
for i=0, light_list:getNumberOfChildren()-1 do

    -- get SceneGraph path of current light
    local light_attributes = light_list:getChildByIndex(i)
    local SceneGraph_path = light_attributes:getChildByName("path")
    SceneGraph_path = Attribute.GetStringValue(SceneGraph_path, "")


    -- get LightGroup of current light
    local light_group = Interface.GetAttr("material.arnoldLightParams.aov", SceneGraph_path)

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
    if value~="default" then
        if not hash[value] then
            group_items[#group_items+1] = value
            hash[value] = true
        end
    elseif value=="default" then
        empties=true
    end
end

light_groups = group_items



-- for each LightGroup create its own render output as multi-channeled exr file
for i=1, #light_groups do RenderOutputDefine(light_groups[i]) end

-- if there is at least one light without LightGroup
if empties then
    if #light_groups > 0 then

        -- if there are some lights with LightGroups and some without LightGroups
        -- then create one render output for all empty LightGroups
        RenderOutputDefine(table.concat(light_groups, ","), true)

    else
        -- if there is no LightGroup at all
        -- then create one render output as multi-channeled exr file
        RenderOutputDefine("default")

    end
end
