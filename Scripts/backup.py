
import os
import re

import sys
import shutil
import time




def make (source_path):
    if os.path.exists(source_path):

        base_name = os.path.basename(source_path)
        if not re.match("^_backup_.*", base_name):

            this_dir = os.path.dirname(source_path)
            backup_dir = os.path.join(this_dir, "backups")

            if not os.path.exists(backup_dir):
                os.mkdir(backup_dir)


            time_format = "%d%b%I%p%M"
            time_tag = time.strftime(time_format, time.localtime())

            name_pair = os.path.splitext(base_name)
            name = "_backup_{}_{}{}".format(name_pair[0], time_tag, name_pair[1])

            destination_path = os.path.join(backup_dir, name)
            shutil.copy(source_path, destination_path)




if __name__ == "__main__":
    
    arguments = sys.argv
    if len(arguments)> 1:

        for source_path in arguments[1:]:
            make(source_path)
