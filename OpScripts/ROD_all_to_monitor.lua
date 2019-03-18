--[[

Location: /root
renderer: prman

Add all defined outputChannels to local outputs
to use those as interactiveOutputs for viewing in Monitor tab

Required:
    * there has to be defined at least one outputChannel

]]


function RenderOutputDefine (channel)
    --[[ Works the same way as the RenderOutputDefine node ]]

    -- add two attributes grouped by input name
    -- these two attributes create local render output
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.type', channel), StringAttribute("raw"))
    Interface.SetAttr(string.format ('renderSettings.outputs.%s.rendererSettings.channel', channel), StringAttribute(string.format ("%s", channel)))

end


-- get all defined outputChannels then get count of those
local output_root = Interface.GetAttr('prmanGlobalStatements.outputChannels')
local children_num = output_root:getNumberOfChildren()

-- add each outputChannel to local output
for i = 0, children_num-1 do RenderOutputDefine(output_root:getChildName(i)) end
