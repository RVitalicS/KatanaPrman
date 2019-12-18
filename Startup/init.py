

from Katana import Callbacks
from Katana import QtWidgets

import os
import sys



resources_path = os.getenv('PRMAN_RESOURCES')
if os.path.exists(resources_path):
    if resources_path not in sys.path:
        sys.path.append(resources_path)





def onStartupComplete(objectHash):

    from Startup import prmanRunButton
        
    from Scripts import scenegraph
    tree = scenegraph.get_tree()
    if tree:
        tree.setLocationExpandedRecursive('/root', '/root')




def onSceneLoad(objectHash, filename):

    if filename:
        from Scripts import backup
        backup.make(filename)
        
        from Scripts import onload
        reload(onload)
        onload.main()





if QtWidgets.qApp.applicationState() == 4:

    Callbacks.addCallback(Callbacks.Type.onStartupComplete, onStartupComplete)
    Callbacks.addCallback(Callbacks.Type.onSceneLoad, onSceneLoad)
