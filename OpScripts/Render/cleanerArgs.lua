--[[

Looks for render outputs that will be saved as files
and adds paths of those to script command as arguments

]]


-- get string command of 'exr_cleaner' post render script
local scriptCommand = Interface.GetAttr("renderSettings.outputs.exr_cleaner.rendererSettings.scriptCommand")
scriptCommand = Attribute.GetStringValue(scriptCommand, "")

-- get all defined render outputs
local outputs_root = Interface.GetAttr('renderSettings.outputs')
if outputs_root then

    -- find render output that
    local outputs_num = outputs_root:getNumberOfChildren()
    for i = 0, outputs_num-1 do

        -- has 'type' attribute with 'raw' value
        local outtype = outputs_root:getChildByIndex(i):getChildByName("type")
        outtype = Attribute.GetStringValue(outtype, "")
        if outtype=="raw" then

            -- has 'locationType' attribute with 'file' value
            local locationType = outputs_root:getChildByIndex(i):getChildByName("locationType")
            locationType = Attribute.GetStringValue(locationType, "")
            if locationType=="file" then

                -- get render output path value
                local path = outputs_root:getChildByIndex(i):getChildByName("locationSettings"):getChildByName("renderLocation")
                path = Attribute.GetStringValue(path, "")

                -- edit post render script command
                scriptCommand = scriptCommand .. string.format(' "%s"', path)
            end
        end
    end
end

-- set back edited string command to 'exr_cleaner' post render script
Interface.SetAttr("renderSettings.outputs.exr_cleaner.rendererSettings.scriptCommand", StringAttribute(scriptCommand))
