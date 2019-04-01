
# 'ShalvesCustom' folder contains scripts that stored in ~.katana\Shelves\Custom
# Directory of 'ShalvesCustom' folder has to be added to 'PYTHONPATH' environment variable
# For some scripts contents of the Icon folder must be placed to KATANA_HOME\bin\python\UI4\Resources\Icons


import os
import sys
import shutil
import ctypes


# CHECK CONDITIONS

# exit if environment variable KATANA_HOME is not set
if not os.getenv('KATANA_HOME'):
	input('Set KATANA_HOME environment variable')
	sys.exit()

# exit if script has not run as administrator
if not ctypes.windll.shell32.IsUserAnAdmin():
	input('Run script as administrator')
	sys.exit()


# COPY SCRIPTS

# collect script paths to copy
scripts_directory = os.path.join(os.path.dirname(__file__), 'ShelvesCustom')
scripts_list = [
	os.path.join(scripts_directory, x)
	for x in os.listdir(scripts_directory)
	if os.path.splitext(x)[1] == '.py'
	]

# get path to copy scripts to
shelves_directory = os.path.join(os.path.expanduser('~'), '.katana/Shelves/Custom')

# check if path to copy exists
if not os.path.exists(shelves_directory):
	input('Scripts have not been copied\n{} to copy does not exist'.format(shelves_directory))
	sys.exit()

# copy all scripts from 'ShalvesCustom' folder
if os.path.exists(shelves_directory):
	for script in scripts_list:
		script_name = os.path.basename(script)
		script_copy = os.path.join(shelves_directory, script_name)
		shutil.copyfile(script, script_copy)

print('Scripts have been copied to {}\n'.format(shelves_directory))


# COPY ICONS

# collect icon paths to copy
icon_directory = os.path.join(os.path.dirname(__file__), 'Icons')
icon_list = [
	os.path.join(icon_directory, x)
	for x in os.listdir(icon_directory)
	if os.path.splitext(x)[1] == '.png'
	]

# get path to copy icons to
katana_home = os.getenv("KATANA_HOME")
katana_directory = os.path.join(katana_home, r'bin\python\UI4\Resources\Icons')

# check if path to copy exists
if not os.path.exists(katana_directory):
	input('Icons have not been copied\n{} to copy does not exist'.format(katana_directory))
	sys.exit()

# copy all icons  from 'Icon' folder
if os.path.exists(katana_directory):
	for icon in icon_list:
		icon_name = os.path.basename(icon)
		icon_copy = os.path.join(katana_directory, icon_name)
		shutil.copyfile(icon, icon_copy)

print('Icons have been copied to {}\n'.format(katana_directory))


# ADD ENVIRONMENT VARIABLE

# add ShelvesCustom directory to PYTHTONPATH
bat_directory = os.path.join(scripts_directory, 'env_current_directory.bat')
os.system(bat_directory)
