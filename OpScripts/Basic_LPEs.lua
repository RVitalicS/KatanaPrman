--[[

Location: /root
renderer: prman

Add outputChannels attributes for Basic LPE workflow

]]


function PrmanOutputChannelDefine (name, lpe)
	--[[ Works the same way as the PrmanOutputChannelDefine node ]]

    -- add two attributes grouped by input name
    -- these two attributes create base of outputChannel
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.type', name), StringAttribute("varying color"))
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.name', name), StringAttribute(string.format ("%s", name)))

    -- these attributes are for working with Light Path Expressions
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.source.type', name), StringAttribute("string"))
    Interface.SetAttr(string.format ('prmanGlobalStatements.outputChannels.%s.params.source.value', name), StringAttribute(string.format ("%s", lpe)))

end


-- define channels for Basic LPE workflow
PrmanOutputChannelDefine("directDiffuse", "color lpe:C<RD>[<L.>O]")
PrmanOutputChannelDefine("indirectDiffuse", "color lpe:C<RD>[DS]+[<L.>O]")

PrmanOutputChannelDefine("directSpecular", "color lpe:C<RS>[<L.>O]")
PrmanOutputChannelDefine("indirectSpecular", "color lpe:C<RS>[DS]+[<L.>O]")

PrmanOutputChannelDefine("subsurface", "color lpe:C<TD>[DS]*[<L.>O]")
PrmanOutputChannelDefine("transmissive", "color lpe:C<TS>[DS]*[<L.>O]")
PrmanOutputChannelDefine("emissive", "color lpe:C[<L.>O]")


-- separately of all add 'Ci' and 'a' channels to merge them with LPEs later
Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.type', StringAttribute("varying color"))
Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.name', StringAttribute("Ci"))

Interface.SetAttr('prmanGlobalStatements.outputChannels.a.type', StringAttribute("varying float"))
Interface.SetAttr('prmanGlobalStatements.outputChannels.a.name', StringAttribute("a"))
