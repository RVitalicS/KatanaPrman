'''
    Delete directory
    if second argument is path and it exists
'''

import sys
import os
import re


# get arguments
args = sys.argv
if len(args) > 1:
    for gotten_path in args[1:]:

        # if directory exists
        gotten_path = os.path.normpath(gotten_path)
        if os.path.exists(gotten_path):

            # if argument is directory
            drive_match = re.match(r"[C-Z]:[\\/].*", gotten_path)
            network_match = re.match(r"\\\\.*", gotten_path)
            if drive_match or network_match:

                # inform of this script
                print("[INFO erase.py]: {} - directory will be erased".format(gotten_path))

                # delete directory
                os.remove(gotten_path)
