"""
NAME: Create Shelf
ICON: icon.png
KEYBOARD_SHORTCUT:
SCOPE:
Add render button at the top of the interface

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


from PyQt5.QtWidgets import QLayout
from Katana import UI4

from ks_core.render import render_viewed


# create and adjust button widget
ToolbarButton = UI4.Widgets.ToolbarButton('Render', None, UI4.Util.IconManager.GetPixmap('Icons/prman.png'))
ToolbarButton.setObjectName('RenderButton')
ToolbarButton.clicked.connect(render_viewed)


# search top layout in main window UI
app_layouts = UI4.App.MainWindow.CurrentMainWindow().findChildren(QLayout)

for layout_item in app_layouts:
	if layout_item.objectName() == 'topLayout':

		# add button to the top layout
		if layout_item.minimumSize().width() > 700:
			layout_item.insertWidget(18, ToolbarButton)
