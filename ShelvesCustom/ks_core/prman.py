from subprocess import Popen, PIPE
import sys
import os

from parameter import set_relative_path, add_tex_manager


def tex_format(arguments_string, source_path):
	'''
	Create command for txmake.exe and run it

	arguments_string <type 'str'>: [arguments] for command line >>> txmake [arguments] inputfile(s) outputfile
	source_path <type 'str'>: Texture file path from that will be converted to 'tex' format

	Returns <type 'str'>: Absolute texture file path that has been converted to 'tex' format
	'''

	# create output path by changing extension of an input file
	output_path = os.path.splitext(source_path)[0] + '.tex'

	# create complete required command line string
	command = ' '.join(['txmake', arguments_string, source_path, output_path])

	# convert texture and wait successful result
	process = Popen(
		command,
		shell=True,
		stdout=PIPE,
		stderr=PIPE
		)

	process.wait()

	# print error if was and stop here
	result = process.communicate()
	if process.returncode:
		print(result[1].decode())
		sys.exit()

	# output path if successful result
	return output_path


def tex_switch(param_in, node_in):
	'''
	This function gets string value from filename Parameter object
	and stores it as an expression in a new custom 'SourcePath' parameter

	Also it creates 'Arguments' parameter
	that stores commandline keys to convert texture

	Then it converts file from 'SourcePath'	with keys from 'Arguments'
	and set back resulted 'tex' formatted file path as an expression
	to filename Parameter object

	param_in <type 'Parameter'>: Parameter object
	node <class 'Nodes3DAPI. ...'>: Node object that contains Parameter object
	'''

	# if input filename parameter object has value
	value = param_in.getValue(0)
	if value:

		# if input filename parameter object already has tex formatted texture then just out of here
		if os.path.splitext(value)[-1] == '.tex':
			return None

		# get root parameter group of current node
		node_root = node_in.getParameters()

		# if node has not custom 'SourcePath' parameter
		# add custom 'SourcePath' parameter
		if not node_root.getChild('SourcePath'):
			add_tex_manager(node_in)

		# if current node is MultiTexture
		if node_in.getParameter('nodeType').getValue(0) == 'PxrMultiTexture':

			# for each string value in array of MultiTexture parameters
			# find index of current parameter by comparing string values
			for i in range(10):
				param_value = node_in.getParameter('parameters.filename%d.value' % i).getValue(0)
				if value == param_value:

					# copy texture path from current parameter and set it to custom new one as expression
					set_relative_path(node_root.getChild('SourcePath.Filename%d.Path' % i), value)

					# convert texture from custom parameter and set it to current parameter as expression
					source = node_root.getChild('SourcePath.Filename%d.Path' % i).getValue(0)
					arguments = node_root.getChild('SourcePath.Filename%d.Arguments' % i).getValue(0)

					path_out = tex_format(arguments, source)
					set_relative_path(param_in, path_out)

		# for all other nodes but MultiTexture
		# copy texture path from current parameter and set it to custom new one as expression
		else:
			set_relative_path(node_root.getChild('SourcePath'), value)

			# convert texture from custom parameter and set it to current parameter as expression
			source = node_root.getChild('SourcePath').getValue(0)
			arguments = node_root.getChild('Arguments').getValue(0)

			path_out = tex_format(arguments, source)
			set_relative_path(param_in, path_out)
