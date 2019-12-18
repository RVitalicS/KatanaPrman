"""
NAME: RelativePath
ICON: Icons/expressionHilite16.png
KEYBOARD_SHORTCUT: R
SCOPE:
Sets string parameters to expression type with relative paths

"""

# The following symbols are added when run as a shelf item script:
# exit():      Allows 'error-free' early exit from the script.
# console_print(message, raiseTab=False):
#              Prints the given message to the result area of the largest
#              available Python tab.
#              If raiseTab is passed as True, the tab will be raised to the
#              front in its pane.
#              If no Python tab exists, prints the message to the shell.
# console_clear(raiseTab=False):
#              Clears the result area of the largest available Python tab.
#              If raiseTab is passed as True, the tab will be raised to the
#              front in its pane.




from Katana import NodegraphAPI

from Scripts import (
    parameter,
    path )




# for all edited nodes
for node in NodegraphAPI.GetAllEditedNodes():


    # except "Importomatic"
    # find string parameters with dirictory value
    if node.getType() != "Importomatic":
        for item in parameter.find_strings(node):
            path.set_relative(item)


    # for import items in "Importomatic" node
    else:
        for alembicNode in node.getChildren():
            for alembicItem in alembicNode.getChildren():
                if alembicItem.getType() == "Alembic":
                                        
                    # set relative paths for "abcAsset" parameters
                    for child in alembicItem.getChildren():
                        path.set_relative(child.getParameters().getChild("abcAsset"))
