 --[[

Location: /root/world/lgt//*{@type=="light"}
renderer: prman

Look for empty LightGroup parameter in all lights in SceneGraph
and set reserved "__empty__" name

]]



-- get LightGroup parameter
local LightGroup_parameter = Interface.GetAttr("material.prmanLightParams.lightGroup")
LightGroup_parameter = Attribute.GetStringValue(LightGroup_parameter, "")


-- find empty LightGroup parameter
if LightGroup_parameter=="" then

    -- set reserved LightGroup name
    Interface.SetAttr("material.prmanLightParams.lightGroup", StringAttribute("__empty__"))
end
