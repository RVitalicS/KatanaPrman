--[[

    location: *
    renderer: prman


    Creates "instance" from any SceneGraph location (deletes geometry attributes)
    and assigns randomly chosen item from group of "instance sources"
    
    Also:
        - has option to copy "bound" attribute from "instance source"
        - has option to assign textures for reading in render time
        - has option to create "instances" depending on camera position (LODs)
        - has option to create "instances" as a percentage of all input locations


    Required user defined parameters:

        user.instanceSource                       (string): SceneGraph locations that has "instance source" type (CEL statement)
        user.sourceSeed                           (number): seed number to change variations of choosing instance sources
        user.sourceProxy                          (string): directory to proxy geometry that will be assigned to instances

        user.getSourceBound                       (number): copy "bound" attribute from "instance source"
        user.boundGeneration                      (number): look for "bound" attribute down the hierarchy to a certain child (generation count)

        user.rendertimeTextures.diffuseColor      (string): parameter with texture path (<sequence> expression)
        user.rendertimeTextures.primSpecEdgeColor (string): ...
        ...

        user.rendertimeTextures.textureSeed       (number): seed number to change variations of textures distribution

        user.visibility.cameraName                (string): SceneGraph locations of camera to calculate distance
        user.visibility.minvisible                (number): distance from camera to start creating instances
        user.visibility.maxvisible                (number): distance from camera to stop creating instances

        user.visibility.randomMask                (number): create instances as a percentage of all input locations
        user.visibility.maskSeed                  (number): seed number to change variations of percentage distribution

]]





function CELsolver ( input_expression, input_parent, input_children, output_table )

    --[[
        Recursive function that translate CEL expression string
        to table of SceneGraph locations

        Arguments:
            input_expression  (string): CEL expression
            input_parent      (string): SceneGraph location without expressions        (at will)
            input_children     (table): list of location levels with CEL expressions   (at will)
            output_table       (table): list of collected locations                    (at will)

        Return:
            (table): list recursively filled with SceneGraph locations
    ]]


    -- set default values for input arguments
    input_parent   = input_parent   or pystring.os.path.dirname( string.gsub(input_expression, "()(%*.*)", "") )
    input_children = input_children or {}
    output_table   = output_table   or {}


    -- for the first level of recursion
    -- create list of locations with CEL expressions
    if input_expression ~= "" then
        while input_expression ~= input_parent do

            local location_item = pystring.os.path.basename(input_expression)
            if string.match(input_expression, "//%*") then
                location_item = "//*" else
                location_item = string.gsub(location_item, "%*", "%.%*") end

            table.insert(input_children, 1, location_item)
            input_expression = pystring.os.path.dirname(input_expression)
        end
    end

    
    -- get children names for current parent (without expressions)
    local children = Interface.GetPotentialChildren(input_parent):getNearestSample(0)

    if #children > 0 then
        for index=1, #children do


            -- create string to match with
            local match_string = ".*"
            if input_children[1] ~= "//*" then
                match_string = input_children[1] end
            

            -- for each children find match with the first item from CEL expression list
            local expression_match = string.match(children[index], match_string)
            if expression_match then

                local level_parent = input_parent .. "/" .. expression_match


                -- go to the next children
                if #input_children > 1 then

                    local level_children = {}
                    for i=2, #input_children do
                        table.insert(level_children, input_children[i]) end

                    output_table = CELsolver("", level_parent, level_children, output_table)
                end

                if input_children[1] == "//*" then
                    output_table = CELsolver("", level_parent, input_children, output_table) end


                -- add path to output list for the completely matching strings of CEL expressions
                if #input_children < 2 or input_children[1] == "//*" then
                    table.insert(output_table, level_parent) end
            end
        end

    end


    -- share result
    return output_table

end





function GetCELAttr ( input_attribute )

    --[[
        Reads string from CEL parameter
        and convert it to list of SceneGraph locations

        Arguments:
            input_attribute  (string): path to CEL parameter of current node

        Return:
            (table): list filled with SceneGraph locations
    ]]


    -- define locations collector
    local solvedLocations = {}

    -- get CEL statement
    local CELstatement = Attribute.GetStringValue(Interface.GetOpArg(input_attribute), "")
    if CELstatement ~= "" then


        -- for each CEL statement item
        for statement in string.gmatch(CELstatement, "([^%+]+)") do


            -- first of all check if it is CEL expression
            local CEL = string.match(statement, "(%(%(.+%)%))")
            if CEL then
                CEL = string.gsub(CEL, "(%(*)(%)*)", "")

                -- add "locations" to collector (not "CEL expressions")
                for item in string.gmatch(CEL, "([^ ]+)") do
                    if string.find(item, "%*") == nil then
                        solvedLocations[#solvedLocations+1] = item

                    -- or get "locations" from "CEL expressions"
                    -- and add those ones to collector
                    else
                        local CEL_items = CELsolver(item)
                        for i=1, #CEL_items do
                            table.insert(solvedLocations, CEL_items[i])
                        end
                    end

                end
            

            else -- then check other types
                local notCEL = string.gsub(statement, "(%(*)(%)*)", "")

                -- add "locations" to collector (not "collections")
                for item in string.gmatch(notCEL, "([^ ]+)") do
                    if string.find(item, "%$") == nil and item ~= "FLATTEN" then
                        solvedLocations[#solvedLocations+1] = item
                    end

                end

            end
        end
    end


    -- share result
    return solvedLocations

end





function GetXform ( input_location )

    --[[
        Gets "Xform" attribute from desired SceneGraph location

        Arguments:
            input_location  (string): SceneGraph path to get "Xform" attribute

        Return:
            (class Imath.M44d): found "Xform" attribute
    ]]


    -- try to get "xform" attribute
    local attrXform = Interface.GetGlobalAttr("xform", input_location)
    if attrXform then
      
        -- calculate the matrix representing the global transform
        attrXform = XFormUtils.CalcTransformMatrixAtExistingTimes(attrXform)
        attrXform = Imath.M44d(attrXform:getNearestSample(0.0))
      
    end

    -- share found result
    return attrXform

end





function BoundCollector ( input_location, input_diver, input_boundMin, input_boundMax )

    --[[
        Recursive function that merges bounding box of current node
        with bounding boxes of all children nodes

        Arguments:
            input_location          (string): SceneGraph location for current node                         (at will)
            input_diver             (number): number of generations for children to calculate bounding box (at will)
            input_boundMin (class Imath.V3d): default value for bounding box minimum values                (at will)
            input_boundMax (class Imath.V3d): default value for bounding box maximum values                (at will)

        Return:
            boundBox                 (table): 6 values for bounding box attribute
    ]]


    -- set default values for input arguments
    input_location = input_location or Interface.GetInputLocationPath()
    input_diver    = input_diver    or 10
  
     -- recursive vector collectors
    input_boundMin = input_boundMin or Imath.V3d({0.0, 0.0, 0.0})
    input_boundMax = input_boundMax or Imath.V3d({0.0, 0.0, 0.0})
  

    -- search "bound" attribute
    local attrBound = Interface.GetGlobalAttr("bound", input_location)
    if attrBound then  attrBound = attrBound:getNearestSample(0)
      
        -- create vectors for minimum and maximum values for found bounding box
        local boundMin = Imath.V3d({attrBound[1], attrBound[3], attrBound[5]})
        local boundMax = Imath.V3d({attrBound[2], attrBound[4], attrBound[6]})
      
        -- update values for output vectors
        if boundMin.x < input_boundMin.x then input_boundMin.x = boundMin.x end
        if boundMin.y < input_boundMin.y then input_boundMin.y = boundMin.y end
        if boundMin.z < input_boundMin.z then input_boundMin.z = boundMin.z end

        if boundMax.x > input_boundMax.x then input_boundMax.x = boundMax.x end
        if boundMax.y > input_boundMax.y then input_boundMax.y = boundMax.y end
        if boundMax.z > input_boundMax.z then input_boundMax.z = boundMax.z end

    end


    -- convert vectors to output table
    local boundBox = {
        input_boundMin.x, input_boundMax.x,
        input_boundMin.y, input_boundMax.y,
        input_boundMin.z, input_boundMax.z}


    -- do the same for all children and update output vectors
    local input_children = Interface.GetPotentialChildren(input_location):getNearestSample(0)

    if #input_children > 0 and input_diver > 0 then
        input_diver = input_diver - 1
        for index=1, #input_children do

            local child_location = input_location .. "/" .. input_children[index]
            boundBox = BoundCollector(child_location, input_diver, input_boundMin, input_boundMax)

        end
    end


    -- search "xform" attribute
    local attrXform = GetXform(input_location)
    if attrXform then

        -- recalculate bounding box
        local boundMin = Imath.V3d({boundBox[1], boundBox[3], boundBox[5]}) * attrXform
        local boundMax = Imath.V3d({boundBox[2], boundBox[4], boundBox[6]}) * attrXform

        boundBox = {
            boundMin.x, boundMax.x,
            boundMin.y, boundMax.y,
            boundMin.z, boundMax.z}
    end
  

    -- share result
    return boundBox

end





function ParentHasAttr ( input_attribute, input_path )

    --[[
        Recursive function that search any attribute in parent nodes

        Arguments:
            input_attribute  (string): attribute name to find
            input_path       (string): SceneGraph path of child node  (at will)

        Return:
            (string): SceneGraph path of found node
    ]]


    -- set default value for input argument
    input_path = pystring.os.path.dirname(input_path) or pystring.os.path.dirname(Interface.GetInputLocationPath())
  
    -- try to get desired attribute
    local wanted = Interface.GetAttr(input_attribute, input_path)

    -- do the same for all parents
    -- update path variable to share result
    if wanted == nil and input_path ~= "/" then
        input_path = ParentHasAttr(input_attribute, pystring.os.path.dirname(input_path))
    end

    -- share found result
    if input_path == "/" then
        return nil
    else
        return input_path
    end

end





function XformCollector ( input_vector, input_location )

    --[[
        Recursive function that multiplies input vector
        by all found "Xform" attribute in parent nodes

        Arguments:
            input_vector  (class Imath.V3d): vector variable to edit
            input_location         (string): SceneGraph location to use as child (at will)

        Return:
            (class Imath.V3d): edited vector variable
    ]]


    -- set default value for input argument
    input_location = input_location or Interface.GetInputLocationPath()
  

    -- try to get "Xform" attribute
    local attrXform = GetXform(input_location)
    if attrXform then
      
        -- recalculate input vector
        input_vector = input_vector * attrXform
    end
  

    -- get parent SceneGraph path that has "Xform" attribute
    local xform_location = ParentHasAttr("xform", input_location)
    if xform_location then

        -- do the same for all children and update output vector
        input_vector = XformCollector(input_vector, xform_location)

    end


    -- share result
    return input_vector

end





function InstanceClean ( input_group )

    --[[
        Recursive function to find and delete attributes
        that describe surface of geometry

        Arguments:
            input_group (string): attribute path to start searching (at will)
    ]]
   

    -- set default attribute path and get attribute
    input_group = input_group or "geometry"
    local group = Interface.GetAttr(input_group)

    -- define attribute names to delete
    local delete_list = {"Texture", "st", "vertex", "poly", "point"}

   
    -- check if attribute is "Group" type and get children
    if Attribute.IsGroup(group) then
        local child_count = group:getNumberOfChildren()
       
        -- compare children names with names from "delete_list"
        for index=0, child_count-1 do
           
            local group_name = group:getChildName(index)
            local group_path = input_group .. "." .. group_name
           
            local check_children = false
            for attr_index=1, #delete_list do


                -- delete found attributes
                if delete_list[attr_index] == group_name then
                    Interface.DeleteAttr(group_path)
                else
                    check_children = true
                end
            end


            -- if attribute has not been found
            -- then check children of current group
            if check_children then InstanceClean(group_path) end

        end
    end
end






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
    local input_name = pystring.os.path.basename(Interface.GetInputLocationPath())
    local local_seed = 0

    for i in string.gmatch(input_name, ".") do
        math.randomseed(string.byte(i))
        local_seed = math.random(9) + local_seed
        math.randomseed(local_seed + input_seed)
    end
  
  
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
            local path_head, sequence, path_tail = string.match(input_texture, "(.+)(<.+>)(.+)")
            local textureFormat = path_head .. string.format("%%0%sd", sequenceLength) .. path_tail

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





-- get SceneGraph location paths for instance sources
local instanceSource = GetCELAttr("user.instanceSource")

-- get seed for instance sources distribution
local sourceSeed = Attribute.GetFloatValue(Interface.GetOpArg("user.sourceSeed"), 0.0)

-- get proxy geometry for instance source
local sourceProxy = Attribute.GetStringValue(Interface.GetOpArg("user.sourceProxy"), "")

-- get switch to get bounding box from children
local CheckBox_sourceBound = Attribute.GetFloatValue(Interface.GetOpArg("user.getSourceBound"),  0.0)
local boundGeneration      = Attribute.GetFloatValue(Interface.GetOpArg("user.boundGeneration"), 0.0)

-- get seed for texture distribution
local textureSeed = Attribute.GetFloatValue(Interface.GetOpArg("user.rendertimeTextures.textureSeed"), 0)

-- get camera location
local cameraName = Attribute.GetStringValue(Interface.GetOpArg("user.visibility.cameraName"), "")

-- get visibility range values
local minvisible = Attribute.GetFloatValue(Interface.GetOpArg("user.visibility.minvisible"), 0.0)
local maxvisible = Attribute.GetFloatValue(Interface.GetOpArg("user.visibility.maxvisible"), 1000000000.0)


-- get values for hiding instances randomly
local randomMask = Attribute.GetFloatValue(Interface.GetOpArg("user.visibility.randomMask"), 100.0)
local maskSeed   = Attribute.GetFloatValue(Interface.GetOpArg("user.visibility.maskSeed"), 0.0)

local maskAccepted = true
if randomMask < 100.0 then

    local maskRange = {}
    for i=0, 99 do table.insert(maskRange, i) end

    if randomMask < RandomChoice(maskRange, maskSeed) then
        maskAccepted = false end end




function InstanceSourceAssign ( input_source )

    --[[
        Creates required attributes for hierarchical instancing

        Arguments:
            input_source  (string): SceneGraph location that has "instance source" type
    ]]


    -- delete surface attributes and set "type" attribute for current location
    InstanceClean()
    Interface.SetAttr('type', StringAttribute("instance"))


    -- set "instanceSource" ("bound", "proxy") attribute for current location
    Interface.SetAttr('geometry.instanceSource', StringAttribute(input_source))

    if CheckBox_sourceBound > 0.0 then
        Interface.SetAttr("bound", DoubleAttribute(BoundCollector(input_source, boundGeneration), 2)) end

    if sourceProxy ~= "" then
        Interface.SetAttr("proxies.viewer", StringAttribute(sourceProxy)) end


    -- for all used fields to set shader parameters at render time create "textures.xxx" attributes
    local textures_group = Interface.GetOpArg("user.rendertimeTextures")
    local child_count = textures_group:getNumberOfChildren()

    if child_count > 0 then
        for index=0, child_count-1 do

            local child_name = textures_group:getChildName(index)
            local child_attr = Interface.GetOpArg(string.format("user.rendertimeTextures.%s", child_name))

            if Attribute.IsString(child_attr) then
                local child_value = Attribute.GetStringValue(child_attr, "")

                DistributeTexture(child_name, child_value, textureSeed) end

        end
    end

end




-- create instances as a percentage of all input locations
if maskAccepted then


    -- if camera is defined
    -- distribute instance sources only to positions in the specified range
    if cameraName ~= "" then
      
        -- choose item from instance sources
        local source = RandomChoice(instanceSource, sourceSeed)
        if source then
            
            -- get bound attribute for input SceneGraph location
            local bounding_box = BoundCollector(source, boundGeneration)
          
            local min = Imath.V3d(bounding_box[1], bounding_box[3], bounding_box[5])
            local max = Imath.V3d(bounding_box[2], bounding_box[4], bounding_box[6])


            -- apply all transformations from parent nodes
            min = XformCollector(min)
            max = XformCollector(max)
          

            -- define object and camera positions
            local geoCenter = (max-min)/2 + min
            local camCenter = Imath.V3d(0.0, 0.0, 0.0)
          

            -- get camera "xform" attribute
            local attrXform = GetXform(cameraName)
            if attrXform then

                -- get camera position
                camCenter = attrXform.translation(attrXform) end
              

            -- find distance between camera and object
            local distance = camCenter - geoCenter
            distance = distance.length(distance)
          

            -- if distance between camera and object is between user defined range
            if distance > minvisible and distance < maxvisible then
                InstanceSourceAssign(source) end

        end



    -- if camera is not defined
    -- distribute instance sources to all positions
    else
        local source = RandomChoice(instanceSource, sourceSeed)
        if source then
            InstanceSourceAssign(source) end
    end


end
