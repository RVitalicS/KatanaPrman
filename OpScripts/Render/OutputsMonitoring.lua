--[[

Location: /root
renderer: arnold

Add all defined outputChannels to local outputs
to use those as interactiveOutputs for viewing in Monitor tab

Also delete all multi-channeled outputs

]]


function RenderOutputDefine (channel)
    --[[ Works the same way as the RenderOutputDefine node ]]

    -- add two attributes grouped by input name
    -- these two attributes create local render output
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.type', channel), StringAttribute("raw"))
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.rendererSettings.channel', channel), StringAttribute(string.format ("%s", channel)))

end


-- get all defined outputChannels then get count of those
local outputChannels_root = Interface.GetAttr('arnoldGlobalStatements.outputChannels')
if outputChannels_root then local outputChannels_num = outputChannels_root:getNumberOfChildren()

    -- add each outputChannel to local output
    for i = 0, outputChannels_num-1 do RenderOutputDefine(outputChannels_root:getChildName(i)) end

end


-- get all defined render outputs then get count of those
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
