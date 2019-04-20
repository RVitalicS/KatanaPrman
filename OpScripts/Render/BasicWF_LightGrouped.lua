--[[

Location: /root
renderer: prman

Add outputChannel attributes for Basic LPE workflow for each LightGroup
and create render outputs as multi-channeled exr files

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

Run after 'NamedEmptyLightGroup' script only

]]



-- get string value from added earlier user-defined attribute that contains path for render outputs
path_project = Interface.GetAttr("user.shotPath")
path_project = Attribute.GetStringValue(path_project, "")

-- get string value from added earlier user-defined attribute that contains name of the current shot
name = Interface.GetAttr("user.shotName")
name = Attribute.GetStringValue(name, "")



function PrmanOutputChannelDefine (name, lpe, group, type)
    --[[
    Works as the PrmanOutputChannelDefine node

    Arguments:
        name  (string): name of outputChannel
        lpe   (string): Light Path Expression ("color lpe:C.*[<L.>O]")
        group (string): name of the part that was separated by expression
        type  (string): type of current output ("varying color")
    ]]

    -- adjust outputChannel name if LightGroup is set
    if group == "" then name = name
    else name = name .. "_" .. group end

    -- set default value for the 'type' argument
    type=type or "varying color"

    -- add current LPE channel to global variable
    if channels == "" then channels = name
    else channels = channels .. "," .. name end

    -- create outputChannel by name
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", name), StringAttribute(type))
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", name), StringAttribute(name))

    -- set Light Path Expression
    if lpe ~= "" then
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", name), StringAttribute("string"))
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", name), StringAttribute(lpe))
    end

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

    -- define expression and output name tag variables as arguments for 'PrmanOutputChannelDefine' function
    local lpe_value = ""
    local lpe_group = ""

    -- define tag and output variables to adjust renderSettings.output attribute
    local file_tag = ""
    local output = "primary"


    -- adjust variables depending on input arguments:

    if group=="__empty__" then -- leave all variables as they are

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
        lpe_value = string.format("[^%s]", all_groups)
        lpe_group = "others"
        file_tag = "_" .. lpe_group .. "LightGroup"
        output = "basicWF" .. file_tag

    else -- create expression part for single LightGroup

        -- adjust variables
        lpe_value = string.format("['%s']", group)
        lpe_group = group
        file_tag = "_" .. lpe_group .. "LightGroup"
        output = "basicWF" .. file_tag
    end


    -- reset global variable for new render output
    channels = ""


    -- add 'Ci' and 'a' channels
    if output ~= "primary" then
        PrmanOutputChannelDefine("Ci", string.format("color lpe:C.*[<L.%s>O]", lpe_value), lpe_group)
    end
    PrmanOutputChannelDefine("a","", "", "varying float")

    -- add channels for Basic LPE workflow
    PrmanOutputChannelDefine("directDiffuse", string.format("color lpe:C<RD>[<L.%s>O]", lpe_value), lpe_group)
    PrmanOutputChannelDefine("indirectDiffuse", string.format("color lpe:C<RD>[DS]+[<L.%s>O]", lpe_value), lpe_group)

    PrmanOutputChannelDefine("directSpecular", string.format("color lpe:C<RS>[<L.%s>O]", lpe_value), lpe_group)
    PrmanOutputChannelDefine("indirectSpecular", string.format("color lpe:C<RS>[DS]+[<L.%s>O]", lpe_value), lpe_group)

    PrmanOutputChannelDefine("subsurface", string.format("color lpe:C<TD>[DS]*[<L.%s>O]", lpe_value), lpe_group)
    PrmanOutputChannelDefine("transmissive", string.format("color lpe:C<TS>[DS]*[<L.%s>O]", lpe_value), lpe_group)
    PrmanOutputChannelDefine("emissive", string.format("color lpe:C[<L.%s>O]", lpe_value), lpe_group)


    -- create full path string to save multi-channeled exr file
    local path = pystring.os.path.join(path_project, string.format("%s_basicWF%s.exr", name, file_tag) )
    path = pystring.replace(path, "\\", "/")

    -- Create one render output for all defined here LPE outputChannels
    -- add 'name' and 'raw' type parameters, switch location type to 'file' mode and set 'renderLocation' parameter
    Interface.SetAttr(string.format("renderSettings.outputs.%s.type", output), StringAttribute("raw"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.rendererSettings.channel", output), StringAttribute(channels))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.locationType", output), StringAttribute("file"))
    Interface.SetAttr(string.format("renderSettings.outputs.%s.locationSettings.renderLocation", output), StringAttribute(path))

end



-- define LightGroup collector
local light_groups = {}

-- for each light
local light_list = Interface.GetGlobalAttr("lightList", "/root/world")
for i=0, light_list:getNumberOfChildren()-1 do

    -- get SceneGraph path of current light
    local light_attributes = light_list:getChildByIndex(i)
    local SceneGraph_path = light_attributes:getChildByName("path")
    SceneGraph_path = Attribute.GetStringValue(SceneGraph_path, "")

    -- get LightGroup of current light
    local light_group = Interface.GetGlobalAttr("material.prmanLightParams.lightGroup", SceneGraph_path)
    light_group = Attribute.GetStringValue(light_group, '')

    -- add LightGroup to collector
    light_groups[#light_groups+1] = light_group

end



-- get rid of empty and duplicate items
-- check if there is at least one light without LightGroup
local group_items = {}
local hash = {}
local empties = false

for i=1, #light_groups do
    local value = light_groups[i]
    if value~="__empty__" then
        if not hash[value] then
            group_items[#group_items+1] = value
            hash[value] = true
        end
    elseif value=="__empty__" then
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
        RenderOutputDefine("__empty__")

    end
end
