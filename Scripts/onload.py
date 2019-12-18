
from Katana import NodegraphAPI

import os


from Scripts import (
    scenegraph,
    path )





def main():


    time = int(NodegraphAPI.GetCurrentTime())
    project_dir = os.path.dirname( NodegraphAPI.NodegraphGlobals.GetProjectFile() )


    abc_path = None
    for file in os.listdir(project_dir):

        extension = os.path.splitext(file)[-1]
        if extension == ".abc":
            abc_path = os.path.join(project_dir, file)




    Alembic_In_Prman = NodegraphAPI.GetNode("Alembic_In_Prman")
    if Alembic_In_Prman:

        abcAsset = Alembic_In_Prman.getParameter("abcAsset")
        if not abcAsset.getValue(time) and abc_path:

            abcAsset.setValue(abc_path, time)
            path.set_relative(abcAsset)

            NodegraphAPI.SetNodeViewed(Alembic_In_Prman, Alembic_In_Prman, exclusive=True)

            tree = scenegraph.get_tree()
            if tree:
                tree.setLocationExpandedRecursive('/root', '/root')
