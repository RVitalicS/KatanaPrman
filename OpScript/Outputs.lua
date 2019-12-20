

local Outputs = {}



package.loaded.Channels = nil
package.loaded.Prman    = nil
package.loaded.Data     = nil

local Channels = require 'Channels'
local Prman    = require 'Prman'
local Data     = require 'Data'





function Outputs.Define ( outputName, outputType, channelList, outputPath )

    if channelList == '' then return nil end


    Interface.SetAttr(string.format('renderSettings.outputs.%s.type', outputName), StringAttribute(outputType))
    Interface.SetAttr(string.format('renderSettings.outputs.%s.rendererSettings.channel', outputName), StringAttribute(channelList))


    outputPath = outputPath or ''

    if outputPath ~= '' then
        Interface.SetAttr(string.format('renderSettings.outputs.%s.locationType', outputName), StringAttribute('file'))
        Interface.SetAttr(string.format('renderSettings.outputs.%s.locationSettings.renderLocation', outputName), StringAttribute(outputPath))
    end
end





local function getPath ( extraTag )


    extraTag = extraTag or ''

    if extraTag ~= '' then
        extraTag = '_' .. extraTag
    end


    -- get path for render outputs and name of the current shot
    local shotPath = Attribute.GetStringValue(Interface.GetAttr('user.shotPath'), '')
    local shotName = Attribute.GetStringValue(Interface.GetAttr('user.shotName'), '')

    -- get string value to add to output files
    local filenameTag = Attribute.GetStringValue(Interface.GetOpArg('user.FilenameTag'), '')
    if    filenameTag ~= '' then filenameTag = '_' .. filenameTag end

    -- create full path string to save multi-channeled exr file
    local outputPath = pystring.os.path.join(shotPath, string.format('%s%s%s.exr', shotName, filenameTag, extraTag) )
          outputPath = pystring.os.path.normpath(outputPath)

    return outputPath
end





local function ExpandOutputItems ( outputItems, groupItems, groupType )


    if #groupItems > 1 then


        local templates = Data.Clone(outputItems)
        outputItems = {}

        groupItems = Prman.LpeGroupConvert(groupItems)


        for index=1, #templates do
            local templateItem = templates[index]


            for groupName, groupExpression in pairs(groupItems) do
                local groupOutput = Data.Clone(templateItem)


                if groupName == 'default' then
                    if groupType == 'lpeGroup'   then groupName = 'defGroup' end
                    if groupType == 'lightGroup' then groupName = 'defLight' end
                end


                groupOutput['tag'] = groupOutput['tag'] .. string.format( '_%s', groupName)
                groupOutput[groupType] = groupExpression


                table.insert(outputItems, groupOutput)
            end

        end

    end


    return outputItems
end





function Outputs.PrmanEssentials()


    local outputItems = { {tag='', lpeGroup='', lightGroup=''} }
    local SearchGroup = Interface.GetOpArg('user')


    if Channels.CheckboxMatch( SearchGroup, 'byLPE' ) then
        outputItems = ExpandOutputItems( outputItems, Prman.GetLpeGroups(),   'lpeGroup'   )
    end

    if Channels.CheckboxMatch( SearchGroup, 'byLight' ) then
        outputItems = ExpandOutputItems( outputItems, Prman.GetLightGroups(), 'lightGroup' )
    end


    for outputIndex=1, #outputItems do

        local outputItem = outputItems[outputIndex]

        local tag = outputItem['tag']
        local lpeGroup   = outputItem['lpeGroup']
        local lightGroup = outputItem['lightGroup']


        local outputName  = 'PrmanEssentials' .. tag
        local outputType = 'raw'
        local channelList = Channels.PrmanEssentials(tag, lpeGroup, lightGroup)
        local outputPath = getPath( tag:gsub('^_+', '') )


        Outputs.Define(outputName, outputType, channelList, outputPath)

    end

end





function Outputs.PrmanDenoise()

    local outputName  = 'Denoise'
    local outputType = 'raw'
    local channelList = Channels.PrmanDenoise()
    local outputPath = getPath('variance')

    Outputs.Define(outputName, outputType, channelList, outputPath)

end





function Outputs.BuiltInAOVs()

    local outputName  = 'BuiltInAOVs'
    local outputType = 'raw'
    local channelList = Channels.BuiltInAOVs()
    local outputPath = getPath()

    Outputs.Define(outputName, outputType, channelList, outputPath)

end





return Outputs
