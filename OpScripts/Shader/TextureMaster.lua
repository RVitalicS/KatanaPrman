--[[

Location: /root/world/geo/asset//*{@type == "polymesh"} /root/world/geo/asset//*{@type == "subdmesh"}
renderer: prman

Find shader parameter tags, read values of those attributes
and set texture attributes that will be read dynamically while render

Otherwise set texture attributes with default values

Required User Parameters:
    user.texturesPath: (string) path to right textures
    user.defaultsPath: (string) path to default textures

]]



-- possible tags
local shader_parameters = {
    'diffuseColor',
    'primSpecEdgeColor',
    'primSpecRefractionIndex',
    'primSpecExtinctionCoefficient',
    'primSpecRoughness',
    'normal',
    'bump'}



-- get path strings from user defined 'texturesPath' and 'defaultsPath' parameters
local texturesPath = Attribute.GetStringValue(Interface.GetOpArg('user.texturesPath'), '')
local defaultsPath = Attribute.GetStringValue(Interface.GetOpArg('user.defaultsPath'), '')



-- look for all possible shader parameter tag
for i=1, #shader_parameters do

    -- get attribute name
    local attr = shader_parameters[i]


    -- if there was found current tag
    -- create full path to texture file and set parameter
    local shader_parameter = Interface.GetAttr(string.format('geometry.arbitrary.%s.value', attr))
    if shader_parameter then

        local path = texturesPath .. string.format('/%s', Attribute.GetStringValue(shader_parameter,''))
        Interface.SetAttr(string.format('textures.%s', attr), StringAttribute(path))


    -- if there wasn't found current tag
    -- create full path to default texture file and set parameter
    else
        local path = defaultsPath .. string.format('/%s_MAPID_.tex', attr)
        Interface.SetAttr(string.format('textures.%s', attr), StringAttribute(path))

    end
end
