

def get_source ( node ):

    source_ports = []

    for i in node.getInputPorts():
        if i.getNumConnectedPorts() > 0:

            source_ports.append( {i.getName(): i.getConnectedPorts()} )

    return source_ports




def get_target ( node ):

    target_ports = []

    for i in node.getOutputPorts():
        if i.getNumConnectedPorts() > 0:

            target_ports.append( {i.getName(): i.getConnectedPorts()} )

    return target_ports




def get_target_nodes ( node ):

    nodes = []

    target_ports = get_target(node)

    for connections in target_ports:
        for output_name in connections:
            for target_port in connections[output_name]:

                nodes.append(target_port.getNode())

    return nodes
