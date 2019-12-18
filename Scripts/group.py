

def find_M2D (group):
    nodes = []

    for node in group.getChildren():

        if node.getType() == "PrmanShadingNode":
            node_type = node.getParameter("nodeType")

            if node_type.getValue(0) == "PxrManifold2D":
                nodes.append(node)

    return nodes




def find_splice (group):

    nodes = []

    for node in group.getChildren():

        if node.getType() == "NetworkMaterialSplice":
            nodes.append(node)

    return nodes

