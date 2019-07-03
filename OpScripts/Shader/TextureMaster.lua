--[[

    location: //*{hasattr("geometry.arbitrary.diffuseColor")} + ...
    renderer: prman

    Creates string attributes that will be automatically read by RenderMan
    and passed from the geometry to shader parameters at render time

    Required User Parameters:
        user.texturesPath  (string): path to created textures
        user.defaultsPath  (string): path to default textures

]]



-- possible tags
local shader_parameters = {
    "diffuseGain",
    "diffuseColor",
    "diffuseRoughness",
    "primSpecEdgeColor",
    "primSpecRefractionIndex",
    "primSpecExtinctionCoeff",
    "primSpecRoughness",
    "roughSpecEdgeColor",
    "roughSpecRefractionIndex",
    "roughSpecExtinctionCoeff",
    "roughSpecRoughness",
    "clearcoatEdgeColor",
    "clearcoatRefractionIndex",
    "clearcoatRoughness",
    "iridescenceFaceGain",
    "iridescenceEdgeGain",
    "iridescenceRoughness",
    "iridescenceThickness",
    "fuzzColor",
    "subsurfaceGain",
    "subsurfaceColor",
    "subsurfaceDmfpColor",
    "singlescatterGain",
    "singlescatterColor",
    "singlescatterMfpColor",
    "glassRefractionGain",
    "glassReflectionGain",
    "glassRefractionColor",
    "glassRoughness",
    "anisotropy",
    "anisotropyDirection",
    "glowColor",
    "bump",
    "normal",
    "presence",
    "displacementScalar",
    "displacementVector",
    "mask",
    "dirtColor"}



-- get path strings from user defined "texturesPath" and "defaultsPath" parameters
local texturesPath = Attribute.GetStringValue(Interface.GetOpArg("user.texturesPath"), "")
local defaultsPath = Attribute.GetStringValue(Interface.GetOpArg("user.defaultsPath"), "")



-- look for all possible shader parameter tag
for i=1, #shader_parameters do

    -- get attribute name
    local attr = shader_parameters[i]


    -- if there was found current tag
    -- create full path to texture file and set parameter
    local shader_parameter = Interface.GetAttr(string.format("geometry.arbitrary.%s.value", attr))
    if shader_parameter then

        local path = texturesPath .. string.format("/%s", Attribute.GetStringValue(shader_parameter,""))
        Interface.SetAttr(string.format("textures.%s", attr), StringAttribute(path))


    -- if there wasn't found current tag
    -- create full path to default texture file and set parameter
    else
        local path = defaultsPath .. string.format("/%s_MAPID_.tex", attr)

        if  Interface.GetAttr(string.format("textures.%s", attr)) == nil then
            Interface.SetAttr(string.format("textures.%s", attr), StringAttribute(path)) end

    end
end
