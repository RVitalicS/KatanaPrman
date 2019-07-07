--[[

    location: //*{attr("materialAssign")=="PxrMasterSurface"}
    renderer: prman


    Adds "textures.xxx" attribute (with texture distribution option)
    that will be used in shader parameter at render start

    Examples:
        //path/name<15>.tex        (randomly replace number in brackets with number from 01 to 15 depending on node name)
        //path/name<15-10,05>.tex  (randomly replace number in brackets with number from 15 to 10 or with 05 depending on node name)


    Required user defined parameters:
        user.diffuseColor      (string): parameter with texture path (<sequence> expression)
        user.primSpecEdgeColor (string): ...
        ...

        user.textureSeed       (number): seed number to change variations of textures distribution

]]





function RandomChoice ( input_table, input_seed )

    --[[
        Randomly choices item from input table
        depending on name of current location basename

        Arguments:
            input_table  (table): list to choose from
            input_seed  (number): seed number (at will)

        Return:
            (*): randomly chosen item from list
    ]]


    -- set default value seed
    input_seed = input_seed or 0


    -- get current node name and create random seed
    local inputLocationPath = Interface.GetInputLocationPath()
    local local_seed = ExpressionMath.stablehash(inputLocationPath)
    math.randomseed(local_seed + input_seed)


    -- return random item from input table
    if #input_table > 0 then
        return input_table[math.random(#input_table)] else
        return nil end

end





function DistributeTexture ( input_attribute, input_texture, input_seed )

    --[[
        Adds "textures.xxx" attribute with texture distribution option

        Arguments:
            input_attribute  (string): attribute name that will be used in shader parameter
            input_texture    (string): path to texture with or without expression
            input_seed       (number): seed number  (at will)
    ]]


    -- set default value seed
    input_seed = input_seed or 0


    -- run if parameter value is valid
    if input_texture ~= "" then


        -- if it has sequence expression
        local sequenceExpression = string.match(input_texture, "<.+>")
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


            -- create string with specific file path and set attribute
            local textureFormat = string.gsub(input_texture, "(<.*>)", string.format("%%%%0%sd", sequenceLength))

            local textureString = string.format(textureFormat, RandomChoice(possibleNumbers, input_seed))
                  textureString = pystring.replace(textureString, "\\", "/")

            Interface.SetAttr(string.format("textures.%s", input_attribute), StringAttribute(textureString))



        -- if it has not sequence expression
        -- set attribute with input file path
        else
            input_texture = pystring.replace(input_texture, "\\", "/")
            Interface.SetAttr(string.format("textures.%s", input_attribute), StringAttribute(input_texture)) end

    end
end





-- get seed for texture distribution
local textureSeed = Attribute.GetFloatValue(Interface.GetOpArg("user.textureSeed"), 0)



-- for all used fields for setting shader parameters at render time create "textures.xxx" attributes
local textures_group = Interface.GetOpArg("user")
local child_count = textures_group:getNumberOfChildren()

if child_count > 0 then
    for index=0, child_count-1 do

        local child_name = textures_group:getChildName(index)
        local child_attr = Interface.GetOpArg(string.format("user.%s", child_name))

        if Attribute.IsString(child_attr) then
            local child_value = Attribute.GetStringValue(child_attr, "")

            DistributeTexture(child_name, child_value, textureSeed) end

    end
end
