

local Outputs = {}





package.loaded.Channels = nil
local Channels = require 'Channels'





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





function Outputs.PrmanEssentials()

    local outputName  = 'PrmanEssentials'
    local outputType = 'raw'
    local channelList = Channels.PrmanEssentials()
    local outputPath = getPath()

    Outputs.Define(outputName, outputType, channelList, outputPath)

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
