
import os
import re

from Katana import NodegraphAPI

from Scripts import get_port
from Scripts import typed_value
from Scripts import create


time = int(NodegraphAPI.GetCurrentTime())





def data_get ( node ):

    data = dict()


    data["position"] = NodegraphAPI.GetNodePosition(node)
    data["parent"]   = node.getParent()


    channel = ""
    name_value = node.getParameter("name").getValue(time)
    if re.match(".*primSpecRefractionIndex.*", name_value): channel = "primSpecRefractionIndex"
    if re.match(".*primSpecExtinctionCoeff.*", name_value): channel = "primSpecExtinctionCoeff"
    if re.match(".*normal.*", name_value): channel = "normal"
    if re.match(".*bump.*", name_value): channel = "bump"
    if re.match(".*displacementScalar.*", name_value): channel = "displacementScalar"
    data["channel"] = channel


    data["name"]      = typed_value.get( node.getParameter("name") )
    data["operation"] = typed_value.get( node.getParameter("parameters.operation.value") )
    data["alpha"]     = typed_value.get( node.getParameter("parameters.topA.value") )
    data["red"]       = typed_value.get( node.getParameter("parameters.bottomRGB.value.i0") )
    data["green"]     = typed_value.get( node.getParameter("parameters.bottomRGB.value.i1") )
    data["blue"]      = typed_value.get( node.getParameter("parameters.bottomRGB.value.i2") )

    delete_node = None
    if channel=="normal" and data["blue"]["value"] == 0.5:
        data["blue"]["value"] = 1.0
        delete_node = NodegraphAPI.GetNode(name_value + "Correct")


    data["port_source"] = get_port.source(node)

    sender_node = node
    if delete_node: sender_node = delete_node
    data["port_target"] = get_port.target(sender_node)


    node.delete()
    if delete_node: delete_node.delete()

    return data




def data_move ( data, parameter ):

    children = parameter.getChildren()
    
    if not children:
        typed_value.set(data, parameter)

    else:

        parameter_enable = parameter.getChild("enable")
        if parameter_enable:
            parameter_enable.setValue( float(True), time )


        parameter_value  = parameter.getChild("value")

        if type(data) == type(tuple()):

            new_red   = parameter_value.getChild("i0")
            new_green = parameter_value.getChild("i1")
            new_blue  = parameter_value.getChild("i2")

            red    = data[0]
            green  = data[1]
            blue   = data[2]

            typed_value.set(red, new_red)
            typed_value.set(green, new_green)
            typed_value.set(blue, new_blue)

        else:
            typed_value.set(data, parameter_value)





def adjust ( node, channel="" ):

    for i in range(8):

        layer_enable = node.getParameter("parameters.enable_{}".format(i))
        layer_enable.getChild("enable").setValue( float(True), time )
        layer_enable.getChild("value").setValue( float(True), time )

        layer_alpha = node.getParameter("parameters.A_{}".format(i))
        layer_alpha.getChild("enable").setValue( float(True), time )
        layer_alpha.getChild("value").setValue( 0.0, time )

        if channel=="bump" or channel=="normal":
            layer_operation = node.getParameter("parameters.operation_{}".format(i))
            layer_operation.getChild("enable").setValue( float(True), time )
            layer_operation.getChild("value").setValue( 20.0, time )

            layer_color = node.getParameter("parameters.RGB_{}".format(i))
            layer_color.getChild("enable").setValue( float(True), time )
            layer_color.getChild("value.i0").setValue( 0.5, time )
            layer_color.getChild("value.i1").setValue( 0.5, time )

            if channel=="bump":
                layer_color.getChild("value.i2").setValue( 0.5, time )
            else:
                layer_color.getChild("value.i2").setValue( 1.0, time )


        if channel=="displacementScalar":
            layer_operation = node.getParameter("parameters.operation_{}".format(i))
            layer_operation.getChild("enable").setValue( float(True), time )
            layer_operation.getChild("value").setValue( 16.0, time )


    clamp = node.getParameter("parameters.clampOutput")
    clamp.getChild("enable").setValue( float(True), time )

    if channel=="primSpecRefractionIndex" or channel=="primSpecExtinctionCoeff":
        clamp.getChild("value").setValue( float(False), time )
    else:
        clamp.getChild("value").setValue( float(True), time )





def transit ( source_node ):

    layerType = source_node.getParameter("nodeType").getValue(time)
    if layerType != "PxrBlend": return source_node


    data = data_get(source_node)
    node = create.node("PxrLayeredBlend", data["parent"], data["position"])

    adjust(node, data["channel"])


    port_source = data["port_source"]
    if port_source:

        for connections in port_source:
            for port_name in connections:
                for port in connections[port_name]:

                    node_input  = node.getInputPort("RGB_7")
                    node_input.connect(port)


    port_target = data["port_target"]
    if port_target:

        for connections in port_target:
            for port_name in connections:
                for port in connections[port_name]:

                    node_output = node.getOutputPort(port_name)
                    node_output.connect(port)


    new_name      = node.getParameter("name")
    new_operation = node.getParameter("parameters.operation_7")
    new_alpha     = node.getParameter("parameters.A_7")
    new_color     = node.getParameter("parameters.backgroundRGB")


    move_tuple = (
        ( data["name"], new_name ),
        ( (data["red"], data["green"], data["blue"]), new_color ),
        ( data["alpha"], new_alpha ),
        ( data["operation"], new_operation ) )

    for pair in move_tuple:
        data_move( pair[0], pair[1] )


    return node



def color_transit ( node, parameter ):

    source = None
    value = parameter.getChild("value")

    if value.getChildren():
        red   = typed_value.get( value.getChild("i0") )
        green = typed_value.get( value.getChild("i1") )
        blue  = typed_value.get( value.getChild("i2") )

        source = (red, green, blue)

    else:
        scalar = typed_value.get( value )
        source = (scalar, scalar, scalar)

    target = node.getParameter("parameters.backgroundRGB")
    if source:
        data_move( source, target )
