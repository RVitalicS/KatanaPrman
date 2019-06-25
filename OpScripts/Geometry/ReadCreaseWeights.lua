--[[

    location: /root/world/geo//*{hasattr("geometry.arbitrary.creaseweight")}
    renderer: prman

    Read arbitrary 'creaseweight' attribute (from Houdini)
    and convert it to required Renderman format

]]



-- get creaseweight attribute
local creaseweight = Interface.GetAttr('geometry.arbitrary.creaseweight.value')
creaseweight = creaseweight:getNearestSample(0.0)

-- get startIndex attribute that contains links to the first point of polygon
local startIndex = Interface.GetAttr('geometry.poly.startIndex')
startIndex = startIndex:getNearestSample(0.0)

-- get vertexList attribute that contains links from vertex to point
local vertexList = Interface.GetAttr('geometry.poly.vertexList')
vertexList = vertexList:getNearestSample(0.0)



-- collect polygons as point groups
local polygonList = {}

for i=1, #startIndex do
    if i ~= #startIndex then

        -- create container
        local pointGroup = {}

        -- collect points
        for x=startIndex[i]+1, startIndex[i+1] do
            pointGroup[#pointGroup+1] = vertexList[x]
        end

        -- add container to global collector
        polygonList[#polygonList+1] = pointGroup
    end
end



-- collect point pairs with direct and reverse order
local pairsDirect = {}
local pairsReverse = {}

local vtxnum = 0

-- look for pairs in polygon point groups
for i=1, #polygonList do

    -- create containers for current iteratioin
    local pairD = {}
    local pairR = {}

    for p=1, #polygonList[i] do

        -- current vertex index
        vtxnum = vtxnum + 1

        -- create point pairs with direct order
        if creaseweight[vtxnum] ~= 0.0 then
            if p ~= #polygonList[i] then
                pairD[#pairD+1] = {
                    polygonList[i][p],
                    polygonList[i][p+1],
                    creaseweight[vtxnum]}
            else
                pairD[#pairD+1] = {
                    polygonList[i][p],
                    polygonList[i][1],
                    creaseweight[vtxnum]}
            end
        end

        local pr = #polygonList[i] - (p - 1)

        -- create point pairs with reverse order
        if creaseweight[vtxnum + pr -p] ~= 0.0 then
            if pr ~= 1 then
                pairR[#pairR+1] = {
                    polygonList[i][pr],
                    polygonList[i][pr-1],
                    creaseweight[vtxnum + pr -p]}
            else
                pairR[#pairR+1] = {
                    polygonList[i][pr],
                    polygonList[i][#polygonList[i]],
                    creaseweight[vtxnum + pr -p]}
            end
        end
    end

    -- add pair containers to global collector
    pairsDirect[#pairsDirect+1] = pairD
    pairsReverse[#pairsReverse+1] = pairR

end



-- create value variables to set attributes later
local creaseLengths = {}
local creaseIndices = {}
local creaseSharpness = {}


-- compare pairs with direct order and pairs with reverse order
for i=1, #pairsDirect do
    for d=1, #pairsDirect[i] do
        if pairsDirect[i][d][3] ~= 0.0 then
            for r=1, #pairsReverse[i] do

                -- add crease item to defined variables
                if pairsDirect[i][d][3] == pairsReverse[i][r][3] then

                    creaseLengths[#creaseLengths+1] = 2

                    creaseIndices[#creaseIndices+1] = pairsDirect[i][d][1]
                    creaseIndices[#creaseIndices+1] = pairsDirect[i][d][2]

                    creaseSharpness[#creaseSharpness+1] = pairsDirect[i][d][3]

                end
            end
        end
    end
end



-- get value from user defined 'creaseMultiplier' parameter
local creaseMultiplier = Interface.GetOpArg('user.creaseMultiplier')
creaseMultiplier = Attribute.GetFloatValue(creaseMultiplier, 0.0)

-- multiply values in creaseweight attribute
for i=1, #creaseSharpness do creaseSharpness[i]=creaseSharpness[i]*creaseMultiplier end



-- set crease attributes
Interface.SetAttr('geometry.creaseLengths', IntAttribute(creaseLengths))
Interface.SetAttr('geometry.creaseIndices', IntAttribute(creaseIndices))
Interface.SetAttr('geometry.creaseSharpness', FloatAttribute(creaseSharpness))
