'''
    Create new directory
    if second argument is path and it does not exist
'''

import sys
import os
import re


# get arguments
args = sys.argv
if len(args) > 1:

    # if directory does not exist
    new_path = os.path.normpath(args[1])
    if not os.path.exists(new_path):

        # if argument is directory
        drive_match = re.match(r"[D-Z]:[\\/].*", new_path)
        network_match = re.match(r"\\\\.*", new_path)
        if drive_match or network_match:

            # inform of this script
            print("[INFO subdirs.py]: {} - directory will be created".format(new_path))

            # create missing directories
            os.makedirs(new_path)
