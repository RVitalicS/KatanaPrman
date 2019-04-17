--[[

Location: /root
renderer: prman

Add 'Ci' outputChannel attribute for each LightGroup

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

Run after 'NamedEmptyLightGroup' script only

]]



function PrmanOutputChannelDefine (name, lpe, group)
    --[[
    Works as the PrmanOutputChannelDefine node

    Arguments:
        name  (string): name of outputChannel
        lpe   (string): Light Path Expression ("color lpe:C.*[<L.>O]")
        group (string): name of the part that was separated by expression
    ]]

    -- adjust outputChannel name if LightGroup is set
    if group == "" then name = name
    else name = name .. "_" .. group end

    -- create outputChannel by name
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", name), StringAttribute("varying color"))
    Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", name), StringAttribute(name))

    -- set Light Path Expression
    if group ~= "" then
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", name), StringAttribute("string"))
        Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", name), StringAttribute(lpe))
    end
end


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

    else -- create expression part for single LightGroup

        -- adjust variables
        lpe_value = string.format("['%s']", group)
        lpe_group = group
    end

    -- add 'Ci' channel
    PrmanOutputChannelDefine("Ci", string.format("color lpe:C.*[<L.%s>O]", lpe_value), lpe_group)

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



-- for each LightGroup create its own 'Ci' outputChannel
for i=1, #light_groups do RenderOutputDefine(light_groups[i]) end

-- if there is at least one light without LightGroup
if empties then
    if #light_groups > 0 then

        -- if there are some lights with LightGroups and some without LightGroups
        -- then create one 'Ci' outputChannel for all empty LightGroups
        RenderOutputDefine(table.concat(light_groups, ","), true)

    else
        -- if there is no LightGroup at all
        -- then create one 'Ci' outputChannel
        RenderOutputDefine("__empty__")

    end
end
