

from Katana import NodegraphAPI

time = int(NodegraphAPI.GetCurrentTime())



from Scripts import (
    typed_value,
    create )

import re






def check (node):

    if node.getType() == "PrmanShadingNode":
        if node.getParameter("nodeType").getValue(time) == "PxrManifold2D":

            return node

    return None






def get_data (node):

    if not check(node): return None
    
    data = dict(
        angle=None,
        scaleS=None,
        scaleT=None,
        offsetS=None,
        offsetT=None,
        invertS=None,
        invertT=None,
        primvarS=None,
        primvarT=None )

    for item in data:

        parameter_path = "parameters.{}.value".format(item)
        parameter = node.getParameter(parameter_path)
        data[item] = typed_value.get(parameter)

    data["position"] = NodegraphAPI.GetNodePosition(node)
    data["name"] = typed_value.get(node.getParameter("name"))

    return data






def  become_cube (node):

    cube_node = None

    data = get_data(node)
    if data:

        cube_node = create.node("PxrRoundCube", node.getParent(), data["position"])
        node.delete()


        data["name"]["value"] = re.sub("Manifold", "CubeManifold", data["name"]["value"])

        value = data["name"]
        parameter = cube_node.getParameter("name")
        typed_value.set(value, parameter)


        for attr in ["scale", "offset", "invert"]:

            for st in ["S", "T"]:
                value = data["{}{}".format(attr, st)]

                for xyz in ["X", "Y", "Z"]:

                    parameter_string = "parameters.{}{}{}".format(attr, st, xyz)
                    parameter = cube_node.getParameter("{}.value".format(parameter_string))

                    typed_value.set(value, parameter)

                    enable = cube_node.getParameter("{}.enable".format(parameter_string))
                    enable.setValue( float(True), time )


    return cube_node




def  become_random (node):

    random_node = None

    data = get_data(node)
    if data:

        random_node = create.node("PxrRandomTextureManifold", node.getParent(), data["position"])
        node.delete()


        data["name"]["value"] = re.sub("Manifold", "RandomManifold", data["name"]["value"])

        value = data["name"]
        parameter = random_node.getParameter("name")
        typed_value.set(value, parameter)


        parameter = random_node.getParameter("parameters.angle.value")
        typed_value.set(data["angle"], parameter)
        random_node.getParameter("parameters.angle.enable").setValue( float(True), time )


        for st in ["S", "T"]:
            
            for attr in ["scale", "offset", "primvar", "invert"]:

                value = data["{}{}".format(attr, st)]

                parameter_string = "parameters.{}{}".format(attr, st)
                parameter = random_node.getParameter("{}.value".format(parameter_string))

                if parameter:

                    typed_value.set(value, parameter)

                    enable = random_node.getParameter("{}.enable".format(parameter_string))
                    enable.setValue( float(True), time )


    return random_node
