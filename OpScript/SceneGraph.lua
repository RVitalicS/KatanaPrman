

local SceneGraph = {}





function SceneGraph.Walker ( functionArgument, inputLocation, collector )

    -- set default values for input arguments
    inputLocation = inputLocation or Interface.GetInputLocationPath()
    collector     = collector     or {}


    -- main action
    local result = functionArgument(inputLocation)

    if result ~= '' and result ~= nil then
        table.insert(collector, result)
    end


    -- do the same for all children
    local inputChildren = Interface.GetPotentialChildren(inputLocation):getNearestSample(0)

    if #inputChildren > 0 then
        for indexChild=1, #inputChildren do

            collector = SceneGraph.Walker(
                            functionArgument,
                            inputLocation .. "/" .. inputChildren[indexChild],
                            collector )
        end
    end


    return collector
end





return SceneGraph
