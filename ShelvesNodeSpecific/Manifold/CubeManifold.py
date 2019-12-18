"""
NAME: CubeManifold
ICON: Icons/vertAlign.png
KEYBOARD_SHORTCUT: C
SCOPE:
Replaces planar PxrManifold2D with PxrRoundCube and PxrTexture with PxrMutiTexture

"""

# The following symbols are added when run as a shelf item script:
# exit():      Allows 'error-free' early exit from the script.
# console_print(message, raiseTab=False):
#              Prints the given message to the result area of the largest
#              available Python tab.
#              If raiseTab is passed as True, the tab will be raised to the
#              front in its pane.
#              If no Python tab exists, prints the message to the shell.
# console_clear(raiseTab=False):
#              Clears the result area of the largest available Python tab.
#              If raiseTab is passed as True, the tab will be raised to the
#              front in its pane.




from Katana import NodegraphAPI

from Scripts import (
    manifold2d,
    port,
    group,
    texture,
    create,
    parameter,
    typed_value )


time = int(NodegraphAPI.GetCurrentTime())






for shader_group in NodegraphAPI.GetAllEditedNodes():
    if shader_group.getType() == "Group":


        splices = group.find_splice(shader_group)
        manifolds = group.find_M2D(shader_group)

        for manifold_node in manifolds:



            connected_manifolds = []
            def manifold_connection (splice_parameter):

                manifold_name = manifold_node.getName()

                if splice_parameter.getValue(time) == manifold_name:
                    if splice_parameter.getName() == "connectFromNode":
                        parent = splice_parameter.getParent()
                        connected_manifolds.append(parent)

            for splice in splices:
                parameter.walker(splice.getParameters(), manifold_connection)



            open_ports = []



            connected_nodes = port.get_target_nodes(manifold_node)

            spliced_nodes = []
            for connection in connected_manifolds:
                from_node = connection.getChild('connectToNode')
                texture_node = NodegraphAPI.GetNode(from_node.getValue(time))
                if texture_node:
                    connected_nodes.append(texture_node)
                    spliced_nodes.append(texture_node)


            for texture_node in connected_nodes:

                connected_textures = []
                def texture_connection (texture_parameter):

                    texture_name = texture_node.getName()

                    if texture_parameter.getValue(time) == texture_name:
                        if texture_parameter.getName() == "connectToNode":
                            parent = texture_parameter.getParent()
                            connected_textures.append(parent)

                for splice in splices:
                    parameter.walker(splice.getParameters(), texture_connection)



                spliced = False
                if texture_node in spliced_nodes: spliced = True

                multi_texture_node = texture.become_multi(texture_node)

                if not spliced:
                    open_ports.append(multi_texture_node.getInputPort("manifoldMulti"))



                for connection in connected_textures:

                    to_node = connection.getChild('connectToNode')
                    to_port = connection.getChild('connectToPort')

                    expression = 'getNode("{}").getNodeName()'.format(multi_texture_node.getName())
                    to_node.setExpression(expression)
                    to_port.setValue("manifoldMulti", time)





            cube_node = manifold2d.become_cube(manifold_node)
            output_port = cube_node.getOutputPort("resultMulti")

            for target_port in open_ports:
                output_port.connect(target_port)



            for connection in connected_manifolds:

                from_node = connection.getChild('connectFromNode')
                from_port = connection.getChild('connectFromPort')

                expression = 'getNode("{}").getNodeName()'.format(cube_node.getName())
                from_node.setExpression(expression)
                from_port.setValue("resultMulti", time)
