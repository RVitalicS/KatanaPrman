

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





function Data.MergeTables ( receiverTable, senderTable )

   for key, value in pairs(senderTable) do

      table.insert(receiverTable, value)
      
   end 
 
   return receiverTable
end





function Data.RemoveDoubles ( inputTable )

    local sortedItems = {}
    local hash = {}


    for index=1, #inputTable do

        local item = inputTable[index]

        if not hash[item] then

            table.insert(sortedItems, item)
            hash[item] = true

        end
    end


    return sortedItems

end





return Data
