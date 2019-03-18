--[[

Location: /root
renderer: prman

Add outputChannels attributes for PerLobe LPE workflow

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


-- to correctly render PerLobe LPE in Katana, you need to declare how these are routed to the outputs
Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse2', StringAttribute("Diffuse"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse3', StringAttribute("Subsurface"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular2', StringAttribute("Specular"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular3', StringAttribute("RoughSpecular"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular4', StringAttribute("Clearcoat"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular5', StringAttribute("Iridescence"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular6', StringAttribute("Fuzz"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular7', StringAttribute("SingleScatter"))
Interface.SetAttr('prmanGlobalStatements.options.lpe.specular8', StringAttribute("Glass"))


-- define channels for PerLobe LPE workflow
PrmanOutputChannelDefine("directDiffuseLobe", "color lpe:CD2[<L.>O]")
PrmanOutputChannelDefine("indirectDiffuseLobe", "color lpe:CD2[DS]+[<L.>O]")
PrmanOutputChannelDefine("subsurfaceLobe", "color lpe:CD3[DS]*[<L.>O]")
PrmanOutputChannelDefine("directSpecularPrimaryLobe", "color lpe:CS2[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularPrimaryLobe", "color lpe:CS2[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularRoughLobe", "color lpe:CS3[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularRoughLobe", "color lpe:CS3[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularClearcoatLobe", "color lpe:CS4[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularClearcoatLobe", "color lpe:CS4[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularIridescenceLobe", "color lpe:CS5[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularIridescenceLobe", "color lpe:CS5[DS]+[<L.>O]")
PrmanOutputChannelDefine("directSpecularFuzzLobe", "color lpe:CS6[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularFuzzLobe", "color lpe:CS6[DS]+[<L.>O]")
PrmanOutputChannelDefine("transmissiveSingleScatterLobe", "color lpe:CS7[DS]*[<L.>O]")
PrmanOutputChannelDefine("directSpecularGlassLobe", "color lpe:C<RS8>[<L.>O]")
PrmanOutputChannelDefine("indirectSpecularGlassLobe", "color lpe:C<RS8>[DS]+[<L.>O]")
PrmanOutputChannelDefine("transmissiveGlassLobe", "color lpe:C<TS8>[DS]*[<L.>O]")
PrmanOutputChannelDefine("emissive", "color lpe:C[<L.>O]")


-- separately of all add 'Ci' and 'a' channels to merge them with LPEs later
Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.type', StringAttribute("varying color"))
Interface.SetAttr('prmanGlobalStatements.outputChannels.Ci.name', StringAttribute("Ci"))

Interface.SetAttr('prmanGlobalStatements.outputChannels.a.type', StringAttribute("varying float"))
Interface.SetAttr('prmanGlobalStatements.outputChannels.a.name', StringAttribute("a"))
