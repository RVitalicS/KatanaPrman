from Katana import NodegraphAPI, LayeredMenuAPI, RenderingAPI
from RenderingAPI import RenderPlugins


def PopulateCallback(layeredMenu):
	'''
	Callback for the layered menu, which adds entries to the given
	C{layeredMenu} based on the available PRMan shaders.

	layeredMenu: The layered menu to add entries to
	'''

	# get DEFAULT_RENDERER
	renderer = RenderingAPI.RenderPlugins.GetDefaultRendererPluginName()

	# Obtain a list of names of available shaders from the renderer
	rendererInfo = RenderPlugins.GetInfoPlugin(renderer)
	shaderType = RenderingAPI.RendererInfo.kRendererObjectTypeShader
	shaderNames = rendererInfo.getRendererObjectNames(shaderType)

	# Iterate over the names of shaders and add a menu entry for each of them
	for shaderName in shaderNames:

		# define color depending on node type
		layer_color = (0.0, 0.6, 1.0)
		if 'Light' in shaderName: layer_color = (1.0, 0.8, 0.0)

		layeredMenu.addEntry(shaderName, text=shaderName, color=layer_color)


def ActionCallback(value):
	'''
	Callback for the layered menu, which creates a node and
	sets its nodeType parameter to the given value, which is the name of
	a shader as set for the menu entry in PopulateCallback.

	value: An arbitrary object that the menu entry that was chosen represents.

	return: An arbitrary object.
	'''

	# get DEFAULT_RENDERER
	renderer = RenderingAPI.RenderPlugins.GetDefaultRendererPluginName()

	# define node type depending on DEFAULT_RENDERER
	node_type = None
	if renderer == 'arnold': node_type = 'ArnoldShadingNode'
	elif renderer == 'prman': node_type = 'PrmanShadingNode'
	if not node_type: return None
	
	# Create the node, set its shader, and set the name with the shader name
	node = NodegraphAPI.CreateNode(node_type)
	node.getParameter('nodeType').setValue(value, 0)
	node.setName(value)
	node.getParameter('name').setValue(node.getName(), 0)

	node.checkDynamicParameters()

	return node


# Create and register a layered menu using the above callbacks
layeredMenu = LayeredMenuAPI.LayeredMenu(
	PopulateCallback,
	ActionCallback,
	'S',
	alwaysPopulate=False,
	onlyMatchWordStart=False
	)

LayeredMenuAPI.RegisterLayeredMenu(layeredMenu, 'getShadingNodes')
