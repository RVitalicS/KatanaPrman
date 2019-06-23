--[[

Location: /root
renderer: prman

Create local render outputs from all defined outputChannels
to use those as interactiveOutputs for viewing in Monitor tab

Also delete all multi-channeled render outputs

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




-- get all defined outputChannels and add each one to local output
local outputChannels_root = Interface.GetAttr('prmanGlobalStatements.outputChannels')
if outputChannels_root then local outputChannels_num = outputChannels_root:getNumberOfChildren()

    for i = 0, outputChannels_num-1 do RenderOutputDefine(outputChannels_root:getChildName(i)) end

end




-- get all defined render outputs
local outputs_root = Interface.GetAttr('renderSettings.outputs')
if outputs_root then local outputs_num = outputs_root:getNumberOfChildren()

    -- read channel attribute form current render output
    for i = 0, outputs_num-1 do
        local output_name = outputs_root:getChildName(i)

        local output_format = string.format('renderSettings.outputs.%s.rendererSettings.channel', output_name)
        local output_attribute = Interface.GetAttr(output_format)
        local output_value = Attribute.GetStringValue(output_attribute, '')

        -- if channel has more then one item then delete current render output
        if string.find(output_value,',') then
            Interface.DeleteAttr(string.format('renderSettings.outputs.%s', output_name))
        end

    end

end
