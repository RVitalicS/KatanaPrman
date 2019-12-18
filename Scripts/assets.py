
import os
import re





def get_looks ( name, path=os.getenv("ASSETS", "") ):

    directories = []
    looks = []


    for directory in os.listdir(path):
        directory = os.path.join(path, directory)

        if os.path.isfile(directory):
            if os.path.splitext(directory)[-1] == ".klf":

                look = os.path.basename(directory)
                expression = r"^{}_.+\.klf$".format(name)

                if re.match(expression, look):
                    directory = os.path.normpath(directory)
                    looks.append(directory)

        elif os.path.isdir(directory):
            directories.append(directory)


    if looks:
        return looks

    for directory in directories:
        looks = get_looks(name, path=directory)

        if looks:
            return looks

