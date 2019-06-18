--[[

Location: //*{attr("materialAssign")=="PxrMasterSurface"}
renderer: prman

Adds "textures.xxx" attribute with texture distribution

Examples:
    //path/name<15>.tex        (randomly replace number in brackets with number from 01 to 15 depending on node name)
    //path/name<15-10,05>.tex  (randomly replace number in brackets with number from 15 to 10 or with 05 depending on node name)

]]



-- get seed value from user defined parameter to add it to local seed
globalSeed = Attribute.GetFloatValue(Interface.GetOpArg("user.globalSeed"), 0)



function DistributeTextures (sequenceString, attributeName)

    --[[ Adds "textures.xxx" attribute with texture distribution ]]


    -- run if parameter value is valid
    -- and it has sequence expression
    if sequenceString ~= "" then
        local sequenceExpression = string.match(sequenceString, "<.+>")
        if sequenceExpression then


            -- get length of variable numbers get rid of brackets
            local sequenceLength = # string.match(sequenceExpression, "%d+")
            sequenceExpression = string.gsub(sequenceExpression, "(<*)(>*)", "")


            -- collect single numbers and number pairs
            local pairStrings = {}
            for pairString in string.gmatch(sequenceExpression, '([^,]+)') do
                pairStrings[#pairStrings+1] = pairString
            end


            -- expand number pairs to sequence of numbers
            -- and create list of all possible numbers
            local possibleNumbers = {}
            for i=1, #pairStrings do local pairString = pairStrings[i]

                -- convert string to tuple for number pair
                local pair = {}
                for number in string.gmatch(pairString, '([^-]+)') do
                    pair[#pair+1] = tonumber(number)
                end


                -- for single numbers
                if #pair == 1 then

                    -- if there is only one number in sequence expression
                    -- then create sequence of numbers from one to input number
                    -- and append each one to list of possible numbers
                    if #pairStrings == 1 then
                        for number=1, pair[1] do possibleNumbers[#possibleNumbers+1] = number end

                    -- or append single number to list of possible numbers
                    else possibleNumbers[#possibleNumbers+1] = pair[1] end
                end


                -- for pair numbers
                if #pair == 2 then

                    -- switch iterator for reverse pairs
                    local i_begin, i_end = nil, nil
                    if pair[1] < pair[2] then
                        i_begin = pair[1]
                        i_end = pair[2]
                    else
                        i_begin = pair[2]
                        i_end = pair[1]
                    end

                    -- expand sequence of numbers from lower to higher number
                    -- and append each one to list of possible numbers
                    for number=i_begin, i_end do
                        possibleNumbers[#possibleNumbers+1] = number
                    end
                end

            end


            -- get current node name and create random seed
            local nodeName = pystring.os.path.basename(Interface.GetInputLocationPath())
            local localSeed = ""

            for i in string.gmatch(nodeName, ".") do
                math.randomseed(string.byte(i))
                localSeed = string.format("%s%s", math.random(9), localSeed)
            end

            math.randomseed(tonumber(localSeed) + globalSeed)


            -- create string with specific file path and set attribute
            local path_head, sequence, path_tail = string.match(sequenceString, "(.+)(<.+>)(.+)")
            local textureFormat = path_head .. string.format("%%0%sd", sequenceLength) .. path_tail

            local textureString = string.format(textureFormat, possibleNumbers[math.random(#possibleNumbers)])
            Interface.SetAttr(string.format("textures.%s", attributeName), StringAttribute(textureString))

        end
    end
end



-- distribute textures for all defined parameters
DistributeTextures(Attribute.GetStringValue(Interface.GetOpArg("user.diffuseSequence"), ""), "diffuseColor")
DistributeTextures(Attribute.GetStringValue(Interface.GetOpArg("user.primSpecEdgeSequence"), ""), "primSpecEdgeColor")
DistributeTextures(Attribute.GetStringValue(Interface.GetOpArg("user.primSpecRoughnessSequence"), ""), "primSpecRoughness")
DistributeTextures(Attribute.GetStringValue(Interface.GetOpArg("user.normalSequence"), ""), "normal")
DistributeTextures(Attribute.GetStringValue(Interface.GetOpArg("user.bumpSequence"), ""), "bump")
DistributeTextures(Attribute.GetStringValue(Interface.GetOpArg("user.displacementScalarSequence"), ""), "displacementScalar")
