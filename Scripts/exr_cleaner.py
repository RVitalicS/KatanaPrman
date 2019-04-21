'''

Renames exr channels using regular expressions
Getting rid of LightGroup tagging

'''


import OpenEXR
import Imath
import re
import os
import sys


def cut_tag(name):
	''' Replaces tagged name with standard for compositing channel name '''

	name = re.sub('Ci.*\.', '', name)
	name = re.sub('directDiffuse.*\.', 'directDiffuse.', name)
	name = re.sub('directSpecular.*\.', 'directSpecular.', name)
	name = re.sub('indirectDiffuse.*\.', 'indirectDiffuse.', name)
	name = re.sub('indirectSpecular.*\.', 'indirectSpecular.', name)
	name = re.sub('transmissive.*\.', 'transmissive.', name)
	name = re.sub('subsurface.*\.', 'subsurface.', name)
	name = re.sub('emissive.*\.', 'emissive.', name)

	return name


def exr_cleaner(path):
	''' Look for channel names with LightGroup tag and rename those ones  '''

	# get file data
	file = OpenEXR.InputFile(path)
	exr_data = file.header()

	# check if channels have LightGroup tag
	tag = False
	for channel in exr_data['channels']:
		if channel != cut_tag(channel):
			tag = True

	# if there are channels to rename
	if tag:

		# collect channels data
		channels_type = {}
		channels_data = {}

		for channel in exr_data['channels']:
			data_type = exr_data['channels'][channel]
			data_string = file.channel(channel, Imath.PixelType(Imath.PixelType.FLOAT))

			# rename channels
			channel = cut_tag(channel)

			channels_type[channel] = data_type
			channels_data[channel] = data_string

		# replace channels
		exr_data['channels'] = channels_type

		# inform of this script
		print('\n[INFO exr_cleaner.py: channels have been renamed - {}]\n'.format(file_path))

		# write data to file
		out = OpenEXR.OutputFile(file_path, exr_data)
		out.writePixels(channels_data)


# get arguments
args = sys.argv
if len(args) > 1:
	for i in args[1:]:

		# if directory exists
		file_path = os.path.normpath(i)
		if os.path.exists(file_path):

			# rename channels if it necessary
			exr_cleaner(file_path)
