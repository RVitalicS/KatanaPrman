"""
    Add prman render buttons at the top of the interface
"""


from PyQt5.QtWidgets import QLayout
from Katana import UI4
from Katana import NodegraphAPI
from PyUtilModule import RenderManager
import os




def getViewedNode():

    '''
        Look for node that is displayed in the interface

        Return:
            <type 'Node2D'>: found node object
    '''


    # define placeholder for search result
    render_node = None

    # search viewed node
    all_nodes = NodegraphAPI.GetAllNodes()
    for node in all_nodes:

        # assign viewed node to placeholder
        if NodegraphAPI.IsNodeViewed(node):
            render_node = node

    # share result
    return render_node




def prmanPreview():

    ''' Start preview render from viewed node '''

    # start render for chosen node
    RenderManager.StartRender("previewRender", node=getViewedNode())


# get icon for button
this_dir = os.path.dirname(__file__)
icon_file = os.path.join(this_dir, "Icons", "prmanPreview.png")

# create and adjust button widget
PreviewRenderButton = UI4.Widgets.ToolbarButton("Renderman Preview Render", None, UI4.Util.IconManager.GetPixmap(icon_file))
PreviewRenderButton.setObjectName("PrmanPreview")
PreviewRenderButton.clicked.connect(prmanPreview)




def prmanLive():

    ''' Start live render from viewed node '''

    # start render for chosen node
    RenderManager.StartRender("liveRender", node=getViewedNode())


# get icon for button
this_dir = os.path.dirname(__file__)
icon_file = os.path.join(this_dir, "Icons", "prmanLive.png")

# create and adjust button widget
LiveRenderButton = UI4.Widgets.ToolbarButton("Renderman Live Render", None, UI4.Util.IconManager.GetPixmap(icon_file))
LiveRenderButton.setObjectName("PrmanLive")
LiveRenderButton.clicked.connect(prmanLive)




# search top layout in main window UI
app_layouts = UI4.App.MainWindow.CurrentMainWindow().findChildren(QLayout)

for layout_item in app_layouts:
    if layout_item.objectName() == 'topLayout':

        # add buttons to the top layout
        if layout_item.minimumSize().width() > 700:

            layout_item.insertWidget(15, PreviewRenderButton)
            layout_item.insertWidget(16, LiveRenderButton)
