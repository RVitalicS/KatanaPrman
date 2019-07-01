--[[

    location: {attr("type")=="level-of-detail"}
    renderer: *


    Calculates distance between camera and input object and
    if result fits to user defined range then sets "componentLodWeight" attribute value to 1.0 - ON  (known to "LodSelect" node)
    else                                      sets "componentLodWeight" attribute value to 0.0 - OFF


    Required user defined parameters:
        user.cameraName      (string): SceneGraph location for camera object
        user.minvisible      (number): minimum distance value from camera to center of object to be visible
        user.maxvisible      (number): maximum distance value from camera to center of object to be visible
        user.informDistance  (number): option to print distance to console window
        user.instanceID      (number): option to add "instance.ID" attribute for leaf-level instancing
]]



-- get visibility range values from user defined parameters
local minvisible = Attribute.GetFloatValue(Interface.GetOpArg("user.minvisible"), 0.0)
local maxvisible = Attribute.GetFloatValue(Interface.GetOpArg("user.maxvisible"), 1000000000.0)

-- get camera location
local cameraName = Attribute.GetStringValue(Interface.GetOpArg("user.cameraName"), "")

-- get switch to inform of current distance
local CheckBox_informDistance = Attribute.GetFloatValue(Interface.GetOpArg("user.informDistance"), 0.0)

-- get switch for leaf-level instancing
local CheckBox_instanceID = Attribute.GetFloatValue(Interface.GetOpArg("user.instanceID"), 0.0)





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





-- do calculate with camera defined only
if cameraName ~= "" then


    -- get bound attribute for input SceneGraph location
    local bounding_box = BoundCollector()

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


    -- option to show current distance
    if CheckBox_informDistance > 0.0 then
        print( string.format("[INFO DistanceFromCamera]: %15.10f %s", distance, Interface.GetInputLocationPath()) ) end


    -- if distance between camera and object is between user defined range
    -- set "componentLodWeight" attribute to known for "LodSelect" node value (1.0)
    if distance > minvisible and distance < maxvisible then
        Interface.SetAttr("info.componentLodWeight", FloatAttribute(1.0))
    else
        Interface.SetAttr("info.componentLodWeight", FloatAttribute(0.0))
    end


end


-- option to add "instance.ID" attribute
local id_name = pystring.os.path.basename(Interface.GetInputLocationPath())
if CheckBox_instanceID > 0.0 then Interface.SetAttr('instance.ID', StringAttribute(id_name)) end
