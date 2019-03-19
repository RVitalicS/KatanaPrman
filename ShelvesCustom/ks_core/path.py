import os


def relative_path(path_in, path_project, base='project.dir'):
	'''
	Recursion function that returns relative file path expression to project path

	path_in <type 'str'>: Texture file path that will be converted to relative
	path_project <type 'str'>: The directory of the Katana project file
	base <type 'str'>: Reserved Katana path variable (default 'project.dir')

	Return <type 'str'>: Relative file path (Python Parameter Expression)
	'''

	# make sure that paths have the save base symbols
	path_in = os.path.normpath(path_in)
	path_project = os.path.normpath(path_project)

	# find the joint base path for input and project paths
	if path_project not in path_in:

		# move one directory up
		level_up = os.path.dirname(path_project)

		# wrap base expression with move up action
		base_wrapped = 'path.dirname(%s)' % base

		# do it all again
		return relative_path(path_in, level_up, base_wrapped)

	# create output string expression and return it
	new_string = path_in[len(path_project):]
	expression = "re.sub(r'\\\\', '/', path.normpath(%s + r'%s'))" % (base, new_string)

	return expression
