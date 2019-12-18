

local Data = {}





function Data.SplitString ( inputString, separator, cutSpaces )

    separator = separator or '%s'
    cutSpaces = cutSpaces or true

    local outputTable ={}

    for itemString in string.gmatch(inputString, "([^"..separator.."]+)") do

            if cutSpaces then
                itemString = itemString:gsub('^%s+', ''):gsub('%s+$', '') end

            table.insert(outputTable, itemString)
    end

    return outputTable 
end





return Data
