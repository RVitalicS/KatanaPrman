--[[

Create attributes with texture paths as default values
to avoid - Plugin error: PxrTexture could not open "{attr:textures. ...}"

]]



-- get path string from user defined 'texturePath' parameter
texPath = Interface.GetOpArg('user.texturePath')
texPath = texPath:getValue()


function SetDefaultTexture(attr, name)
    --[[
    Create attributes with texture paths for usage in shader filename parameters

    Arguments:
        attr (string): attribute name that will be used in {attr:textures.xxx} syntax
        name (string): file name that will be set to shader filename parameter
    ]]

    -- if there is no necessary parameter
    if not Interface.GetAttr(string.format('textures.%s', attr)) then

        -- create full path to texture file and set parameter
        local value = texPath .. string.format('/%s', name)
        Interface.SetAttr(string.format('textures.%s', attr), StringAttribute(value))

    end
end


-- set default texture values
SetDefaultTexture('diffuseColor', 'tex_Value0.1800.tex')
SetDefaultTexture('primSpecEdgeColor', 'tex_Value0.0000.tex')
SetDefaultTexture('primSpecRefractionIndex', 'tex_Value1.5000.tex')
SetDefaultTexture('primSpecExtinctionCoefficient', 'tex_Value0.0000.tex')
SetDefaultTexture('primSpecRoughness', 'tex_Value0.2000.tex')
SetDefaultTexture('normal', 'tex_Value_N.tex')
SetDefaultTexture('bump', 'tex_Value0.5000.tex')
