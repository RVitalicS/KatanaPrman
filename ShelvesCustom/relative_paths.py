"""
NAME: Relative Paths
ICON: icon.png
KEYBOARD_SHORTCUT:
SCOPE:
Search paths in nodes and make them relative ones

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
from ks_core.parameter import make_relative


# for all node in Node Graph
# find path parameters and make their values relative ones
for node in NodegraphAPI.GetAllNodes():

	# for Renderman Shading Nodes
	if node.getType() == 'PrmanShadingNode':

		# get Renderman node type
		prman_node_type = node.getParameter('nodeType').getValue(0)

		# for MultiTexture nodes only
		if prman_node_type == 'PxrMultiTexture':
			for i in range(10):
				path_param = node.getParameter('parameters.filename%d.value' % i)
				make_relative(path_param)

		# for other but MultiTexture nodes
		if prman_node_type in ['PxrTexture', 'PxrNormalMap', 'PxrBump']:
			path_param = node.getParameter('parameters.filename.value')
			make_relative(path_param)

	# for Alembic nodes
	if node.getType() in ['Alembic_In', 'Alembic_In_Prman']:
		path_param = node.getParameter('abcAsset')
		make_relative(path_param)

	# for Material nodes
	if node.getType() == 'Material':
		path_param = node.getParameter('shaders.prmanLightParams.lightColorMap.value')
		make_relative(path_param)

	# for LookFileBake nodes
	if node.getType() == 'LookFileBake':
		path_param = node.getParameter('saveTo')
		make_relative(path_param)
