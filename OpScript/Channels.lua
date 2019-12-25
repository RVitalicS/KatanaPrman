

local Channels = {}



package.loaded.UserGroup = nil
package.loaded.Prman     = nil
package.loaded.Data      = nil

local UserGroup = require 'UserGroup'
local Prman     = require 'Prman'
local Data      = require 'Data'





function Channels.Checkboxed ( inputGroup, channelTable, forceRed, teeTag )

    local channelString = ''


    forceRed = forceRed or false
    teeTag   = teeTag   or false


    for indexChannel=1, #channelTable do



        local checked = false

        local checkboxName = channelTable[indexChannel][1]
        checkboxName = checkboxName:gsub('^_+', '')
        checkboxName = checkboxName:gsub('_.+$', '')

        if Channels.CheckboxMatch( inputGroup, checkboxName ) then
            checked = true
        end

        if checkboxName == 'Ci' or checkboxName == 'a' then
            if Channels.CheckboxMatch( inputGroup, 'beauty' ) then
                checked = true
            end
        end



        if checked then

            local channelName = channelTable[indexChannel][1]
            local channelType = channelTable[indexChannel][2]
            local channelLpe  = channelTable[indexChannel][3]
            local channelStat = channelTable[indexChannel][4]


            if teeTag then
                channelName  = 'tee_' .. channelName
                channelLpe   = '' .. channelName .. '' end

            if forceRed and channelType == 'float' then
                channelName = channelName .. '.r' end


            Prman.OutputChannelDefine(channelName, channelType, channelLpe, channelStat)


            if channelString == '' then
                channelString = channelName
            else
                channelString = channelString .. ',' .. channelName end

        end

    end


    return channelString
end





function Channels.CheckboxMatch ( group, wantedName )


    local foundNames = UserGroup.CheckboxSearcher(group)

    for indexFound=1, #foundNames do
        local foundName = foundNames[indexFound]

        if foundName == wantedName then

            return true
        end

    end


    return false
end





local function MakeGrouped ( channelTable, tag, lpeGroup, lightGroup )


    for indexChannel=1, #channelTable do

        local channelName = channelTable[indexChannel][1]
        local channelLpe  = channelTable[indexChannel][3]

        if string.find(channelLpe, 'lpe:') then 

            channelName = channelName .. tag

            if lpeGroup ~= '' then
                channelLpe  = channelLpe:gsub( "lpe:C", string.format("lpe:C%s", lpeGroup) )
            end

            if lightGroup ~= '' then
                channelLpe  = channelLpe:gsub( "<L.>", string.format("<L.%s>", lightGroup) )
            end

        end

        channelTable[indexChannel][1] = channelName
        channelTable[indexChannel][3] = channelLpe

    end


    return channelTable
end





local function LobePatrol (channelString)

    local channelTable = Data.SplitString(channelString, ',')


    local hasLobe = false

    for index=1, #channelTable do
        local channelName = channelTable[index]

        if string.find(channelName, 'Lobe') then
            hasLobe = true
        end
    end


    if hasLobe then
        Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse2', StringAttribute("Diffuse,HairDiffuse"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.diffuse3', StringAttribute("Subsurface"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular2', StringAttribute("Specular,HairSpecularR"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular3', StringAttribute("RoughSpecular,HairSpecularTRT"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular4', StringAttribute("Clearcoat"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular5', StringAttribute("Iridescence"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular6', StringAttribute("Fuzz,HairSpecularGLINTS"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular7', StringAttribute("SingleScatter,HairSpecularTT"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.specular8', StringAttribute("Glass"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.user2', StringAttribute("Albedo,DiffuseAlbedo,SubsurfaceAlbedo,HairAlbedo"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.user3', StringAttribute("Position"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.user4', StringAttribute("UserColor"))
        Interface.SetAttr('prmanGlobalStatements.options.lpe.user6', StringAttribute("Normal,DiffuseNormal,HairTangent,SubsurfaceNormal,SpecularNormal,RoughSpecularNormal,SingleScatterNormal,FuzzNormal,IridescenceNormal,GlassNormal"))
    end

end





function Channels.PrmanEssentials ( tag, lpeGroup, lightGroup )

    lpeGroup   = lpeGroup   or ''
    lightGroup = lightGroup or ''


    local SearchGroup = Interface.GetOpArg('user')
    local EssentialChannels = {

        { 'directDiffuse'                  ,   'color',     "color lpe:C<RD>[<L.>O]"   ,    '' },
        { 'indirectDiffuse'                ,   'color',     "color lpe:C<RD>.+[<L.>O]" ,    '' },
        { 'directSpecular'                 ,   'color',     "color lpe:C<RS>[<L.>O]"   ,    '' },
        { 'indirectSpecular'               ,   'color',     "color lpe:C<RS>.+[<L.>O]" ,    '' },
        { 'subsurface'                     ,   'color',     "color lpe:C<TD>.*[<L.>O]" ,    '' },
        { 'transmissive'                   ,   'color',     "color lpe:C<TS>.*[<L.>O]" ,    '' },
        { 'emissive'                       ,   'color',     "color lpe:C[<L.>O]"       ,    '' },

        { 'directDiffuseLobe'              ,   'color',     "color lpe:CD2[<L.>O]"     ,    '' },
        { 'indirectDiffuseLobe'            ,   'color',     "color lpe:CD2.+[<L.>O]"   ,    '' },
        { 'directSpecularPrimaryLobe'      ,   'color',     "color lpe:CS2[<L.>O]"     ,    '' },
        { 'indirectSpecularPrimaryLobe'    ,   'color',     "color lpe:CS2.+[<L.>O]"   ,    '' },
        { 'directSpecularRoughLobe'        ,   'color',     "color lpe:CS3[<L.>O]"     ,    '' },
        { 'indirectSpecularRoughLobe'      ,   'color',     "color lpe:CS3.+[<L.>O]"   ,    '' },
        { 'directSpecularClearcoatLobe'    ,   'color',     "color lpe:CS4[<L.>O]"     ,    '' },
        { 'indirectSpecularClearcoatLobe'  ,   'color',     "color lpe:CS4.+[<L.>O]"   ,    '' },
        { 'directSpecularIridescenceLobe'  ,   'color',     "color lpe:CS5[<L.>O]"     ,    '' },
        { 'indirectSpecularIridescenceLobe',   'color',     "color lpe:CS5.+[<L.>O]"   ,    '' },
        { 'directSpecularFuzzLobe'         ,   'color',     "color lpe:CS6[<L.>O]"     ,    '' },
        { 'indirectSpecularFuzzLobe'       ,   'color',     "color lpe:CS6.+[<L.>O]"   ,    '' },
        { 'directSpecularGlassLobe'        ,   'color',     "color lpe:C<RS8>[<L.>O]"  ,    '' },
        { 'indirectSpecularGlassLobe'      ,   'color',     "color lpe:C<RS8>.+[<L.>O]",    '' },
        { 'transmissiveGlassLobe'          ,   'color',     "color lpe:C<TS8>.*[<L.>O]",    '' },
        { 'transmissiveSingleScatterLobe'  ,   'color',     "color lpe:CS7.*[<L.>O]"   ,    '' },
        { 'subsurfaceLobe'                 ,   'color',     "color lpe:CD3.*[<L.>O]"   ,    '' },

        { '__Pworld'                       ,   'color',     ""                         ,    '' },
        { '__Nworld'                       ,   'color',     ""                         ,    '' },
        { '__depth'                        ,   'color',     ""                         ,    '' },
        { '__st'                           ,   'color',     ""                         ,    '' },
        { '__Pref'                         ,   'color',     ""                         ,    '' },
        { '__Nref'                         ,   'color',     ""                         ,    '' },
        { '__WPref'                        ,   'color',     ""                         ,    '' },
        { '__WNref'                        ,   'color',     ""                         ,    '' }}

    if Channels.CheckboxMatch( SearchGroup, 'beauty' ) then

        local BeautyChannels = {
        { 'Ci'                             ,   'color',     "color lpe:C.*[<L.>O]"     ,    '' },
        { 'a'                              ,   'float',     ""                         ,    '' }}

        EssentialChannels = Data.MergeTables( BeautyChannels, EssentialChannels )
    end



    EssentialChannels = MakeGrouped(EssentialChannels, tag, lpeGroup, lightGroup)

    local channelString = Channels.Checkboxed(SearchGroup, EssentialChannels)
    LobePatrol(channelString)



    return channelString

end




function Channels.PrmanDenoise()

    local DenoiseChannels = {
        { 'Ci'            ,  'color'  ,   ""                                                                                           , ''         },
        { 'a'             ,  'float'  ,   ""                                                                                           , ''         },
        { 'mse'           ,  'color'  ,   "Ci"                                                                                         , 'mse'      },

        { 'albedo'        ,  'color'  ,   "color lpe:nothruput;noinfinitecheck;noclamp;unoccluded;overwrite;C<.S'passthru'>*((U2L)|O)" , ''         },
        { 'albedo_var'    ,  'color'  ,   "color lpe:nothruput;noinfinitecheck;noclamp;unoccluded;overwrite;C<.S'passthru'>*((U2L)|O)" , 'variance' },

        { 'diffuse'       ,  'color'  ,   "color lpe:C(D[DS]*[LO])|O"                                                                  , ''         },
        { 'diffuse_mse'   ,  'color'  ,   "color lpe:C(D[DS]*[LO])|O"                                                                  , 'mse'      },

        { 'specular'      ,  'color'  ,   "color lpe:CS[DS]*[LO]"                                                                      , ''         },
        { 'specular_mse'  ,  'color'  ,   "color lpe:CS[DS]*[LO]"                                                                      , 'mse'      },

        { 'zfiltered'     ,  'float'  ,   "float zfiltered"                                                                            , ''         },
        { 'zfiltered_var' ,  'float'  ,   "float zfiltered"                                                                            , 'variance' },

        { 'normal'        ,  'normal' ,   "normal Nn"                                                                                  , ''         },
        { 'normal_var'    ,  'normal' ,   "normal Nn"                                                                                  , 'variance' },

        { 'forward'       ,  'vector' ,   "vector motionFore"                                                                          , ''         },
        { 'backward'      ,  'vector' ,   "vector motionBack"                                                                          , ''         }}

    local channelString = ''

    for indexChannel=1, #DenoiseChannels do

        local channelName = DenoiseChannels[indexChannel][1]
        local channelType = DenoiseChannels[indexChannel][2]
        local channelLpe  = DenoiseChannels[indexChannel][3]
        local channelStat = DenoiseChannels[indexChannel][4]


        Prman.OutputChannelDefine(channelName, channelType, channelLpe, channelStat)

        if channelString == '' then
            channelString = channelName
        else
            channelString = channelString .. ',' .. channelName end

    end


    return channelString
end





function Channels.BuiltInAOVs()


    local SearchGroup = Interface.GetOpArg('user')
    local BuiltInAOVs = {
        { 'Ci'               ,    'color' ,     "color lpe:C.*[<L.>O]"                    ,   '' },
        { 'a'                ,    'float' ,     ""                                        ,   '' },

        { 'dPdtime'          ,    'vector',     ""                                        ,   '' },
        { 'motionBack'       ,    'vector',     ""                                        ,   '' },
        { 'motionFore'       ,    'vector',     ""                                        ,   '' },

        { 'Oi'               ,    'color' ,     ""                                        ,   '' },
        { 'biasR'            ,    'float' ,     ""                                        ,   '' },
        { 'biasT'            ,    'float' ,     ""                                        ,   '' },
        { 'Tn'               ,    'vector',     ""                                        ,   '' },
        { 'outsideIOR'       ,    'float' ,     ""                                        ,   '' },

        { 'dPdu'             ,    'vector',     ""                                        ,   '' },
        { 'dPdv'             ,    'vector',     ""                                        ,   '' },
        { 'dPdw'             ,    'vector',     ""                                        ,   '' },
        { 'du'               ,    'float' ,     ""                                        ,   '' },
        { 'dv'               ,    'float' ,     ""                                        ,   '' },
        { 'dw'               ,    'float' ,     ""                                        ,   '' },
        { 'u'                ,    'float' ,     ""                                        ,   '' },
        { 'v'                ,    'float' ,     ""                                        ,   '' },
        { 'w'                ,    'float' ,     ""                                        ,   '' },

        { 'curvature'        ,    'float' ,     ""                                        ,   '' },
        { 'mpSize'           ,    'float' ,     ""                                        ,   '' },
        { 'Ngn'              ,    'normal',     ""                                        ,   '' },
        { 'Nn'               ,    'normal',     ""                                        ,   '' },
        { 'Non'              ,    'normal',     ""                                        ,   '' },

        { 'P'                ,    'vector',     ""                                        ,   '' },
        { 'Po'               ,    'vector',     ""                                        ,   '' },

        { 'time'             ,    'float' ,     ""                                        ,   '' },
        { 'id'               ,    'float' ,     ""                                        ,   '' },
        { 'rawId'            ,    'float' ,     ""                                        ,   '' },
        { 'incidentRayRadius',    'float' ,     ""                                        ,   '' },
        { 'incidentRaySpread',    'float' ,     ""                                        ,   '' },
        { 'PRadius'          ,    'float' ,     ""                                        ,   '' },
        { 'Vn'               ,    'vector',     ""                                        ,   '' },
        { 'VLen'             ,    'float' ,     ""                                        ,   '' },
        { 'z'                ,    'float' ,     ""                                        ,   '' },

        { 'cpuTime'          ,    'float' ,     ""                                        ,   '' },
        { 'sampleCount'      ,    'float' ,     ""                                        ,   '' },

        { 'occluded'         ,    'color' ,     "color lpe:holdouts;C[DS]+<L.>"           ,   '' },
        { 'shadow'           ,    'color' ,     "color lpe:holdouts;unoccluded;C[DS]+<L.>",   '' }}

    local AOVString = Channels.Checkboxed(SearchGroup, BuiltInAOVs)


    local TeeGroup = Interface.GetOpArg('user.Tee')
    local TeeChannels = {
        { 'diffuseColor'         ,     'color',     "",     '' },

        { 'primSpecEdgeColor'    ,     'color',     "",     '' },
        { 'primSpecRoughness'    ,     'float',     "",     '' },

        { 'roughSpecEdgeColor'   ,     'color',     "",     '' },
        { 'roughSpecRoughness'   ,     'float',     "",     '' },

        { 'clearcoatEdgeColor'   ,     'color',     "",     '' },
        { 'clearcoatRoughness'   ,     'float',     "",     '' },

        { 'subsurfaceColor'      ,     'color',     "",     '' },
        { 'subsurfaceDmfpColor'  ,     'color',     "",     '' },

        { 'singlescatterColor'   ,     'color',     "",     '' },
        { 'singlescatterMfpColor',     'color',     "",     '' },

        { 'glassRefractionColor' ,     'color',     "",     '' },
        { 'glassRoughness'       ,     'float',     "",     '' },

        { 'glowColor'            ,     'color',     "",     '' },

        { 'normal'               ,     'color',     "",     '' },
        { 'bump'                 ,     'float',     "",     '' },

        { 'presence'             ,     'float',     "",     '' },

        { 'displacementScalar'   ,     'float',     "",     '' },
        { 'displacementVector'   ,     'color',     "",     '' },

        { 'mask'                 ,     'float',     "",     '' }}

    local TeeString = Channels.Checkboxed(TeeGroup, TeeChannels, true, true)


    local channelString = '' .. AOVString

    if TeeString ~= '' then
        if channelString ~= '' then
            channelString = channelString .. ',' .. TeeString
        else
            channelString = '' .. TeeString
        end
    end


    return channelString
end





return Channels
