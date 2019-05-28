--[[

Location: /root
renderer: arnold

Create outputChannels and render outputs for cryptomattes

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local file_name = Attribute.GetStringValue(name_attribute, '')



function CryptomatteOutput (name)
    --[[ Create outputChannel and local render output using input name ]]


    -- create outputChannel by name
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.name', name), StringAttribute(name))
    Interface.SetAttr(string.format('arnoldGlobalStatements.outputChannels.%s.channel', name), StringAttribute(name))


    -- define output tag
    local tag = ''
    if name == "crypto_asset" then  tag = 'CryptoAst'
    elseif name == "crypto_object" then tag = 'CryptoMat'
    elseif name == "crypto_material" then tag = 'CryptoObj'
    end

    -- create full path string to save as exr file
    local path = pystring.os.path.join(path_project, string.format("%s_%s.exr", file_name, tag))
    path = pystring.replace(path, '\\', '/')

    -- create render output for current outputChannel
    Interface.SetAttr(string.format('renderSettings.outputs.%s.type', name), StringAttribute('raw'))
    Interface.SetAttr(string.format('renderSettings.outputs.%s.rendererSettings.channel', name), StringAttribute(name))
    Interface.SetAttr(string.format('renderSettings.outputs.%s.locationType', name), StringAttribute('file'))
    Interface.SetAttr(string.format('renderSettings.outputs.%s.locationSettings.renderLocation', name), StringAttribute(path))

end



-- output cryptomattes
CryptomatteOutput("crypto_asset")
CryptomatteOutput("crypto_object")
CryptomatteOutput("crypto_material")
