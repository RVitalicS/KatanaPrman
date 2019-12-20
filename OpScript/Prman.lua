

local Prman = {}



package.loaded.SceneGraph = nil
package.loaded.Data       = nil

local SceneGraph = require 'SceneGraph'
local Data       = require 'Data'




function Prman.OutputChannelDefine (inputName, inputType, inputLpe, inputStatistics)

   --[[
   
       Works the same way as the PrmanOutputChannelDefine node plus collect defined channels

       Arguments:
            inputName       (string): name of outputChannel
            inputType       (string): type of channel data
            inputLpe        (string): Light Path Expression ('color lpe:C.*[<L.>O]')
            inputStatistics (string): choice of sampling type
   ]]


   inputType       = inputType       or 'color'
   inputLpe        = inputLpe        or ''
   inputStatistics = inputStatistics or ''


    local outputName = '' .. inputName .. ''
          outputName = outputName:gsub('%.', '_')


    -- create outputChannel
    Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.type', outputName), StringAttribute(inputType))
    Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.name', outputName), StringAttribute(inputName))


    if inputLpe ~= '' then
        Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.params.source.type', outputName), StringAttribute('string'))
        Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.params.source.value', outputName), StringAttribute(inputLpe))
    end


    if inputStatistics ~= '' then
        Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.params.statistics.type', outputName), StringAttribute('string'))
        Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.params.statistics.value', outputName), StringAttribute(inputStatistics))
    end

end




local function GetLpeGroupName ( inputLocation )

    local groupName = ''


    local attributePath = 'prmanStatements.attributes.identifier.lpegroup'
    local lpeGroup = Interface.GetGlobalAttr(attributePath, inputLocation)

    if lpeGroup then

        groupName = Attribute.GetStringValue(lpeGroup, '')

    end


    return groupName
end





local function OnlyDefautCleaner (inputTable)

    local outputTable = inputTable


    if #inputTable == 1 then
        if inputTable[1] == 'default' then

            outputTable = {}
        end
    end


    return outputTable
end





function Prman.GetLpeGroups ()

    local lpeGroups = {}


    local location = '/root/world/geo'

    if Interface.GetGlobalAttr('type', location) then

        lpeGroups = SceneGraph.Walker( GetLpeGroupName, location )
        lpeGroups = Data.RemoveDoubles(lpeGroups)

        table.insert(lpeGroups, 'default')
    end


    lpeGroups = OnlyDefautCleaner(lpeGroups)

    return lpeGroups
end





function Prman.GetLightGroups ()

    -- define LightGroup collector
    local lightGroups = {}


    -- for each light
    local lightList = Interface.GetGlobalAttr('lightList', '/root/world')
    for lightIndex=1, lightList:getNumberOfChildren() do

        -- get SceneGraph path
        local lightAttributes = lightList:getChildByIndex( lightIndex-1 )
        local SceneGraph_path = lightAttributes:getChildByName('path')
        SceneGraph_path  = Attribute.GetStringValue(SceneGraph_path, '')


        -- get LightGroup
        local lightGroup = Interface.GetGlobalAttr('material.prmanLightParams.lightGroup', SceneGraph_path)

        if lightGroup then
            lightGroup = Attribute.GetStringValue(lightGroup, '')
        else
            lightGroup = 'default'
        end


        -- check if light is on
        local mute = Interface.GetAttr('info.light.mute', SceneGraph_path)

        if mute then
            if Interface.GetAttr('info.light.mute', SceneGraph_path):getValue() == 1 then
                mute = true
            else
                mute = false
            end
        else
            mute = false
        end


        -- add LightGroup to collector
        if not mute then
            table.insert(lightGroups, lightGroup)
        end

    end



    lightGroups = Data.RemoveDoubles(lightGroups)
    lightGroups = OnlyDefautCleaner(lightGroups)

    return lightGroups

end





function Prman.LpeGroupConvert ( inputTable )

    local outputTable = {}


    local reverseString = "^"
    local hasDefault = false

    for index=1, #inputTable do

        local groupName = inputTable[index]
        if groupName ~= 'default' then

            outputTable[groupName] = string.format("['%s']", groupName)
            reverseString = reverseString .. string.format("'%s'", groupName)

        else
            hasDefault = true

        end
    end


    if hasDefault then
        outputTable['default'] = string.format("[%s]", reverseString)
    end


    return outputTable
end





return Prman
