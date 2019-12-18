
from Katana import NodegraphAPI
import re

from Scripts import typed_value


time = int(NodegraphAPI.GetCurrentTime())




def get_core_name ( node ):

    name = typed_value.get( node.getParameter("name") )

    core_name = None

    if name["expression"]:

        left_catcher  = r'getNode\("'
        right_catcher = r'"\)'

        search_result = re.search(r'{}.*{}'.format(left_catcher, right_catcher), name["value"])
        if search_result:

            core_name = search_result.group(0)
            core_name = re.sub(left_catcher, "", core_name)
            core_name = re.sub(right_catcher, "", core_name)

    return core_name




def node_name ( channel, tail, core ):
    return r'"%s{}{}" % getNode("{}").getNodeName()'.format( channel, tail, core)
