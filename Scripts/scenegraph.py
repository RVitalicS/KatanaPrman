

import os
from Katana import UI4

from Scripts import assets
reload(assets)




def get_tree ():

    tab = UI4.App.Tabs.FindTopTab("Scene Graph")
    if tab:
        
        tree = tab.getSceneGraphView()
        return tree



def load_tree (tree, node):

    tree.setViewNode(node)
    tree.setLocationExpandedRecursive("/root", "/root")





def show_tree ( path="/root", node=None ):

    if path=="/root": print("/root")

    for child_path in get_children(path, node=node):

        print( len(path) * " " + child_path[len(path):])
        show_tree(child_path, node=node)





def find_assets (path, items=[]):

    looks = assets.get_looks( os.path.basename(path) )
    if looks:
        items.append( [path, looks] )

    else:
        for child in get_children(path):
            items = find_assets(child, items)

    return items





def get_children ( path, tree=get_tree(), node=None ):

    if tree:

        if node:
            load_tree(tree, node)

        children = tree.getSceneGraphChildren(path)

        if children:
            children = [ "{}/{}".format(path, child) for child in children ]

        else:
            children = []


        return children

    else:
        return []
