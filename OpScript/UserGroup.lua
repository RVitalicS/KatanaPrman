

local UserGroup = {}





function UserGroup.CheckboxSearcher (groupAttr, foundNames)

    --[[
        Looks for selected checkboxes
        in input group attribute (recursively)

        Arguments:
            groupAttr  (class GroupAttribute): user defined group with any hierarchy
    ]]


    if not groupAttr then return {} end
    foundNames = foundNames or {}


    -- in all items in input group
    for indexChild=1, groupAttr:getNumberOfChildren() do
        local item = groupAttr:getChildByIndex(indexChild-1)

        -- find group attributes and dive inside
        if Attribute.IsGroup(item) then
            foundNames = UserGroup.CheckboxSearcher(item, foundNames) end

        -- find selected checkboxes
        if Attribute.IsFloat(item) then
        if Attribute.GetFloatValue(item, 0.0) == 1.0 then

            foundNames[#foundNames+1] = groupAttr:getChildName(indexChild-1)

        end
        end

    end

    return foundNames
end




return UserGroup
