
from Scripts import widgetColor
import os



def tab_class(path):

    class Tab (widgetColor.ColorBook):

        def __init__ (self, parent):
            super(Tab, self).__init__(parent)
            self.loadSwatches(path)

    return Tab



katana_path = os.getenv("PRMAN_RESOURCES")
colors_path = os.path.join(katana_path, "Tabs", "ColorBooks")



PluginRegistry = []

for item in os.listdir(colors_path):

    path = os.path.join(colors_path, item)
    name = os.path.splitext(item)[0]

    tab = ["KatanaPanel", 2.0, "Color Books/{}".format(name), tab_class(path)]
    PluginRegistry.append(tab)



PluginRegistry = [ tuple(i) for i in PluginRegistry]
