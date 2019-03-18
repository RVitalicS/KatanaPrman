
# 'ShalvesCustom' folder contains scripts that stored in ~.katana\Shelves\Custom
# Directory of 'ShalvesCustom' folder has to be added to 'PYTHONPATH' environment variable
# For some scripts contents of the Icon folder must be placed to KATANA_HOME\bin\python\UI4\Resources\Icons


import os
import shutil


# collect script paths to copy
scripts_directory = os.path.join(os.path.dirname(__file__), 'ShelvesCustom')
scripts_list = [
	os.path.join(scripts_directory, x)
	for x in os.listdir(scripts_directory)
	if os.path.splitext(x)[1] == '.py'
	]

# get path to copy scripts to
shelves_directory = os.path.join(os.path.expanduser('~'), '.katana/Shelves/Custom')

# copy all scripts from 'ShalvesCustom' folder
if os.path.exists(shelves_directory):
	for script in scripts_list:
		script_name = os.path.basename(script)
		script_copy = os.path.join(shelves_directory, script_name)
		shutil.copyfile(script, script_copy)


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

# copy all icons  from 'Icon' folder
if os.path.exists(katana_directory):
	for icon in icon_list:
		icon_name = os.path.basename(icon)
		icon_copy = os.path.join(katana_directory, icon_name)
		shutil.copyfile(icon, icon_copy)
