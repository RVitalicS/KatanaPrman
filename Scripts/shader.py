

from Katana import NodegraphAPI
from Scripts import typed_value


time = int(NodegraphAPI.GetCurrentTime())





def mathAlbedo (data, strength):

    data = [i*strength for i in data]

    average = 0.0
    for i in data: average += i / len(data)


    for i in range( len(data) ):
        value = data[i]
        value = value + (average - value) * 0.1
        data[i] = value

    return data





def mathSpecular (data, strength):

    data = [i*strength for i in data]

    average = 0.0
    for i in data: average += i / len(data)

    multiplier = (1.0 - (average/2.5))** 0.15
    data = [ i * multiplier for i in data]

    return data





def mathSimple (data, strength):
    data =  [i*strength for i in data]
    return data





def data_edit (data, function, strength):
    
    values = [i["value"] for i in data]
    values = function(values, strength)

    for index in range( len(data) ):
        data[index]["value"] = values[index]

    return data





def brightness (node, strength):

    name_node  = node.getParameter('user.name').getValue(time)

    targets = [
        ["Albedo", "diffuseColor", mathAlbedo],
        ["AlbedoIntensity", "", mathSimple],
        ["Specular", "primSpecEdgeColor", mathSpecular],
        ["SpecularIntensity", "", mathSimple]
    ]

    for item in targets:

        parameter = node.getParameter( "user.Parameters.Surface.{}".format(item[0]) )
        if not parameter:

            blend_node = NodegraphAPI.GetNode("{}_{}_Blend".format(name_node, item[1]))
            if blend_node:
                parameter = blend_node.getParameter("parameters.backgroundRGB.value")

        if parameter:

            children = parameter.getChildren()
            if not children: children = [parameter]

            value = [ typed_value.get(i) for i in children ]
            value = data_edit(value, item[2], strength)

            for index in range( len(children) ):
                typed_value.set(value[index], children[index])

