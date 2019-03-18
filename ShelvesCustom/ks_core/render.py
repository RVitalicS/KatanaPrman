from Katana import NodegraphAPI
from PyUtilModule import RenderManager


def render_viewed():
	''' Start render from viewed node '''

	# which node to render
	render_node = None

	# search viewed node
	all_nodes = NodegraphAPI.GetAllNodes()
	for node in all_nodes:

		# assign viewed node to variable for render
		if NodegraphAPI.IsNodeViewed(node):
			render_node = node

	# start render for chosen node
	RenderManager.StartRender('previewRender', node=render_node)
