

def get_connected (node):

    connected_nodes = []

    for input_port in node.getInputPorts():
        if input_port.getNumConnectedPorts() > 0:

            for target_port in input_port.getConnectedPorts():
                connected_nodes.append( target_port.getNode() )

    return connected_nodes




def walker ( node, function ):

    connected_nodes = get_connected(node)

    function(node)

    for connected_node in connected_nodes:
        walker(connected_node, function)
