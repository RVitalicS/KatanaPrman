--[[

    location: *
    renderer: *

    Copies and expands bounding box attributes from children nodes

	Required user defined parameters:
        user.boundGeneration  (number): look for "bound" attribute down the hierarchy to a certain child (generation count)

]]





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






-- get count of children generations to search bounding box attributes
local boundGeneration = Attribute.GetFloatValue(Interface.GetOpArg("user.boundGeneration"), 0.0)

-- set bounding box attribute for current location
Interface.SetAttr("bound", DoubleAttribute(BoundCollector(Interface.GetInputLocationPath(), boundGeneration), 2))
