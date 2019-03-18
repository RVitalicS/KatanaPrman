"""
NAME: Del Managers
ICON: icon.png
KEYBOARD_SHORTCUT:
SCOPE:
Delete custom SourcePath and Arguments parameters in PrmanShadingNode

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
from ks_core.parameter import del_tex_manager


filter_list = ['PxrTexture', 'PxrNormalMap', 'PxrBump', 'PxrMultiTexture']

# for all node in Node Graph
for node in NodegraphAPI.GetAllNodes():

	# find Renderman Shading Nodes
	if node.getType() == 'PrmanShadingNode':

		# get Renderman node type
		prman_node_type = node.getParameter('nodeType').getValue(0)

		# if there are 'SourcePath' parameters then delete those
		if prman_node_type in filter_list:
			del_tex_manager(node)
