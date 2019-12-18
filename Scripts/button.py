

import os
from Katana import NodegraphAPI

from Scripts import (
    scenegraph,
    path )

reload(scenegraph)
reload(path)



time = int(NodegraphAPI.GetCurrentTime())





def load_looks ():

    for node in NodegraphAPI.GetAllEditedNodes():


        tree = node.getParameter("user.tree")
        load = node.getParameter("user.load")

        if tree and load:


            scenegraph_path = tree.getValue(time)
            node.setName("{}Group".format(os.path.basename(scenegraph_path)))

            assets = scenegraph.find_assets(scenegraph_path)
            children = node.getChildren()


            if assets and children:


                child = children[-1]
                source = child.getInputPort("input").getConnectedPorts()[0]
                target = child.getOutputPort("output").getConnectedPorts()[0]
                child.delete()

                xPos = 0.0
                yPos = 0.0


                for item in assets:

                    scenegraph_path = item[0]
                    look_path = item[1]

                    if len(look_path) == 1:
                        look_path = look_path[0]

                    else:
                        # choose look widget (future)
                        look_path = look_path[0]        # [ "*.klf", "*.klf", ...]


                    new_node = NodegraphAPI.CreateNode("LookFileAssign", node)
                    new_node.setName(os.path.basename(scenegraph_path))
                    NodegraphAPI.SetNodePosition(new_node, (xPos, yPos))
                    yPos -= 50.0

                    source.connect(new_node.getInputPort("input"))
                    target.connect(new_node.getOutputPort("out"))

                    source = new_node.getOutputPort("out")


                    new_node.getParameter("CEL").setValue("(( {}))".format(scenegraph_path), time)

                    look = new_node.getParameter("args.lookfile.asset")
                    look.getChild("value").setValue(look_path, 0)
                    look.getChild("enable").setValue( float(True), 0)
                    path.set_relative(look.getChild("value"))




            root = node.getParameter("user")
            root.deleteChild(tree)
            root.deleteChild(load)
