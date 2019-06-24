--[[

Location: /root
renderer: prman

Switches on interactiveOutputs in RenderSettings
Creates local render outputs from all defined outputChannels to see those ones in Monitor tab
Deletes all multi-channeled and single channeled ("*.r") render outputs

]]




function RenderOutputDefine (input_channel)

    --[[
    Works the same way as the RenderOutputDefine node

    Arguments:
        input_channel  (string): name of outputChannel
    ]]


    Interface.SetAttr(string.format ('renderSettings.outputs.%s.type', input_channel), StringAttribute("raw"))
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.rendererSettings.channel', input_channel), StringAttribute(string.format ("%s", input_channel)))

end




-- for all defined outputChannels
local outputChannels_root = Interface.GetAttr('prmanGlobalStatements.outputChannels')
if outputChannels_root then local outputChannels_num = outputChannels_root:getNumberOfChildren()

    for i = 0, outputChannels_num-1 do

        -- get outputChannel name
        local outputChannel_name = outputChannels_root:getChildName(i)


        -- edit name for single channel output
        if string.match(outputChannel_name, "_r") == "_r" then

            -- get values from existing attributes
            local output_type  = Attribute.GetStringValue(Interface.GetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", outputChannel_name)), "")
            local source_type  = Attribute.GetStringValue(Interface.GetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", outputChannel_name)), "")
            local source_value = Attribute.GetStringValue(Interface.GetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", outputChannel_name)), "")


            -- delete all existing attributes
            Interface.DeleteAttr(string.format("prmanGlobalStatements.outputChannels.%s", outputChannel_name))


            -- edit name
            outputChannel_name = string.gsub(outputChannel_name, "_r", "")


            -- create new attributes with edited name
            if output_type ~= "" then
                Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.type", outputChannel_name), StringAttribute(output_type))
                Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.name", outputChannel_name), StringAttribute(outputChannel_name))
            end

            if source_type ~= "" then
                Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.type", outputChannel_name), StringAttribute(source_type))
                Interface.SetAttr(string.format("prmanGlobalStatements.outputChannels.%s.params.source.value", outputChannel_name), StringAttribute(source_value))
            end


            -- create local render output
            RenderOutputDefine(outputChannel_name)


        else
            -- create local render output
            RenderOutputDefine(outputChannel_name)
        end

    end

end




-- for all defined render outputs
local outputs_root = Interface.GetAttr('renderSettings.outputs')
if outputs_root then local outputs_num = outputs_root:getNumberOfChildren()

    -- read channel attribute
    for i = 0, outputs_num-1 do
        local output_name = outputs_root:getChildName(i)

        local output_format = string.format('renderSettings.outputs.%s.rendererSettings.channel', output_name)
        local output_attribute = Interface.GetAttr(output_format)
        local output_value = Attribute.GetStringValue(output_attribute, '')

        -- if channel has more then one item then delete current render output
        if string.find(output_value,',') then
            Interface.DeleteAttr(string.format('renderSettings.outputs.%s', output_name))
        end

        -- if channel is a single channel output then delete current render output
        if string.find(output_value,'.') then
            Interface.DeleteAttr(string.format('renderSettings.outputs.%s', output_name))
        end
    end

end




-- adjust RenderSettings to see all defined outputChannels
Interface.SetAttr("renderSettings.interactiveOutputs", StringAttribute(""))
