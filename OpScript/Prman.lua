

local Prman = {}





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


    local outputName = "" .. inputName .. ""
          outputName = outputName:gsub("%.", "_")


    -- create outputChannel
    if inputName ~= 'beauty' then
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

    else
        Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.type', StringAttribute('color'))
        Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.name', StringAttribute('Ci'))

        Interface.SetAttr('prmanGlobalStatements.outputChannels.a.type', StringAttribute('float'))
        Interface.SetAttr('prmanGlobalStatements.outputChannels.a.name', StringAttribute('a'))
        
    end
end




return Prman
