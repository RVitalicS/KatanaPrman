"""
NAME: Render Converted
ICON: icon.png
KEYBOARD_SHORTCUT: \
SCOPE:
Convert textures to tex format in filename parameters of PrmanShadingNode

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
from PyUtilModule import RenderManager

from ks_core.render import render_viewed
from ks_core.prman import tex_switch


# stop current render
RenderManager.StartRender('previewRender', node=None)


# for all node in Node Graph
for node in NodegraphAPI.GetAllNodes():

	# find Renderman Shading Nodes
	if node.getType() == 'PrmanShadingNode':

		# get Renderman node type
		prman_node_type = node.getParameter('nodeType').getValue(0)

		# for MultiTexture nodes only
		# convert textures if it needed and set those 'tex' formatted textures to parameters
		if prman_node_type == 'PxrMultiTexture':
			for order in range(10):
				filename_param = node.getParameter('parameters.filename%d.value' % order)
				tex_switch(filename_param, node)

		# for all other nodes with texture parameters
		# convert textures if it needed and set those 'tex' formatted textures to parameters
		if prman_node_type in ['PxrTexture', 'PxrNormalMap', 'PxrBump']:
			filename_param = node.getParameter('parameters.filename.value')
			tex_switch(filename_param, node)


# render viewed node
render_viewed()
