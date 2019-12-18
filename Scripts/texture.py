

from Katana import NodegraphAPI

time = int(NodegraphAPI.GetCurrentTime())



from Scripts import typed_value
from Scripts import port
from Scripts import create


import re





def check (node):

    if node.getType() == "PrmanShadingNode":
        if node.getParameter("nodeType").getValue(time) == "PxrTexture":

            return node

    return None




def get_data (node):

    if not check(node): return None

    data = dict(
        filename=None,
        firstChannel=None,
        atlasStyle=None,
        invertT=None,
        filter=None,
        blur=None,
        lerp=None,
        linearize=None,
        manifold=None,
        saturation=None,
        alphaScale=None,
        alphaOffset=None,
        mipBias=None,
        maxResolution=None,
        optimizeIndirect=None,)

    for item in data:

        parameter_path = "parameters.{}.value".format(item)
        parameter = node.getParameter(parameter_path)
        data[item] = typed_value.get(parameter)

    data["position"] = NodegraphAPI.GetNodePosition(node)
    data["name"] = typed_value.get(node.getParameter("name"))

    return data






def become_multi (node):

    multi_node = None


    output_connections = port.get_target(node)
    data = get_data(node)

    if data:

        multi_node = create.node("PxrMultiTexture", node.getParent(), data["position"])
        node.delete()


        data["name"]["value"] = re.sub("Texture", "MultiTexture", data["name"]["value"])
        
        value = data["name"]
        parameter = multi_node.getParameter("name")
        typed_value.set(value, parameter)


        value = data["filename"]
        multi_node.getParameter("parameters.filename0.enable").setValue( float(True), time )
        parameter = multi_node.getParameter("parameters.filename0.value")
        typed_value.set(value, parameter)


        for connection in output_connections:
            for output_name in connection:

                output_port = multi_node.getOutputPort(output_name)
                for target_port in connection[output_name]:

                    output_port.connect(target_port)


        return multi_node
