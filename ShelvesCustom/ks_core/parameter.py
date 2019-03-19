from Katana import NodegraphAPI
from path import relative_path
import os


def set_relative_path(param_in, path_in):
	'''
	Convert absolute path to relative to current project
	and set it to a string Parameter object

	param_in <type 'Parameter'>: Parameter object
	path_in <type 'str'>: File path
	'''

	# if parameter has expression string or path not exists then get out of here
	if not os.path.exists(path_in):
		return None

	# find current project directory path
	file_project = NodegraphAPI.NodegraphGlobals.GetProjectFile()
	path_project = os.path.dirname(file_project)

	# create expression and set it to string parameter
	path_expression = relative_path(path_in, path_project)
	param_in.setExpression("%s" % path_expression)


def make_relative(param_in):
	'''
	Convert absolute path in filename Parameter object to relative.
	param_in <type 'Parameter'>: Parameter object
	'''

	# if input filename parameter object has value
	value = param_in.getValue(0)
	if value:

		# set back those value as an expression to current parameter
		set_relative_path(param_in, value)


def add_tex_manager(node_in):
	'''
	Add custom 'SourcePath' and 'Arguments' parameter objects

	node_in <class 'Nodes3DAPI. ...'>: Node object that contains custom parameter objects
	'''

	# get root parameter group of current node
	node_root = node_in.getParameters()

	# for MultiTexture node types only
	if node_in.getParameter('nodeType').getValue(0) == 'PxrMultiTexture':

		# add parameters group to root
		node_source_group = node_root.createChildGroup('SourcePath')

		# create group set per filename parameter
		for i in range(10):
			node_file_group = node_source_group.createChildGroup('Filename%d' % i)
			node_file_group.createChildString('Path', '')
			node_file_group.createChildString('Arguments', '-newer')

	# for all other node types
	# create two custom string parameters
	else:
		node_root.createChildString('SourcePath', '')
		node_root.createChildString('Arguments', '-newer')


def del_tex_manager(node_in):
	'''
	Delete custom 'SourcePath' and 'Arguments' parameter objects

	node <class 'Nodes3DAPI. ...'>: Node object that contains custom parameter objects
	'''

	# for MultiTexture node types only delete custom parameters
	if node_in.getParameter('nodeType').getValue(0) == 'PxrMultiTexture':
		source_group = node_in.getParameter('SourcePath')

		if source_group:
			node_in.getParameters().deleteChild(source_group)

	# for all other node types delete custom parameters
	else:
		source_string = node_in.getParameter('SourcePath')
		arguments_string = node_in.getParameter('Arguments')

		if source_string and arguments_string:
			node_in.getParameters().deleteChild(source_string)
			node_in.getParameters().deleteChild(arguments_string)
