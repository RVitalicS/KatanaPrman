"""
Add prman render button at the top of the interface

"""

from PyQt5.QtWidgets import QLayout
from Katana import UI4

from ks_core.render import render_viewed
import os

# get icon for button
this_dir = os.path.dirname(__file__)
icon_file = os.path.join(this_dir, 'Icons', 'prman.png')

# create and adjust button widget
ToolbarButton = UI4.Widgets.ToolbarButton('Render', None, UI4.Util.IconManager.GetPixmap(icon_file))
ToolbarButton.setObjectName('RenderButton')
ToolbarButton.clicked.connect(render_viewed)


# search top layout in main window UI
app_layouts = UI4.App.MainWindow.CurrentMainWindow().findChildren(QLayout)

for layout_item in app_layouts:
	if layout_item.objectName() == 'topLayout':

		# add button to the top layout
		if layout_item.minimumSize().width() > 700:
			layout_item.insertWidget(15, ToolbarButton)
