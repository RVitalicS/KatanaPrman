
from Katana import NodegraphAPI
time = int(NodegraphAPI.GetCurrentTime())




def node ( node_type, parent, position ):
    
    node_object = NodegraphAPI.CreateNode("PrmanShadingNode", parent)
    node_object.getParameter('nodeType').setValue( node_type, time)

    NodegraphAPI.SetNodePosition(node_object, position)
    node_object.checkDynamicParameters()

    return node_object
