
from Katana import NodegraphAPI, LayeredMenuAPI, RenderingAPI
import re


categories = dict(
    Construction=(1.000, 1.000, 1.000),
    Dirt=(0.669, 0.669, 0.669),
    Fabric=(0.531, 0.531, 0.531),
    Liquid=(0.305, 0.305, 0.305),
    Metal=(0.583, 0.583, 0.583),
    Paint=(0.217, 0.217, 0.217),
    Paper=(0.145, 0.145, 0.145),
    Plastic=(0.098, 0.098, 0.098),
    Organic=(0.047, 0.047, 0.047),
    Stone=(0.019, 0.019, 0.019),
    Vegetation=(0.005, 0.005, 0.005),
    Wood=(0.00, 0.00, 0.00)
)




def PopulateCallback ( layeredMenu ):

    '''
        Callback for the layered menu, which adds entries to the given
        C{layeredMenu} based on the available PRMan shaders.

        layeredMenu: The layered menu to add entries to
    '''


    # Obtain a list of names
    macroNames = []
    for name in NodegraphAPI.GetFlavorNodes("_macro"):

        if re.match(".+Shader", name):
            macroNames.append(name)


    # Iterate over the names and add a menu entry for each of them
    for macroName in macroNames:

        macroText = ""

        # define color
        layer_color = (0.0, 0.0, 0.0)

        for name in categories:

            if re.match(".+{}Shader".format(name), macroName):
                layer_color = categories[name]

                macroText = re.sub("{}Shader".format(name), "", macroName)
                macroText = "{}_{}".format(name, macroText)


        layeredMenu.addEntry(macroName, text=macroText, color=layer_color)





def ActionCallback ( value ):

    '''
        Callback for the layered menu, which creates a node and
        sets its nodeType parameter to the given value, which is the name of
        a shader as set for the menu entry in PopulateCallback.

        value: An arbitrary object that the menu entry that was chosen represents.

        return: An arbitrary object.
    '''


    # Create the node
    node = NodegraphAPI.CreateNode(value)

    newName = re.sub("_", "", value)
    for name in categories:
        newName = re.sub("{}Shader".format(name), "Shader", newName)

    node.setName(newName)

    return node





# Create and register a layered menu using the above callbacks
layeredMenu = LayeredMenuAPI.LayeredMenu(
    PopulateCallback,
    ActionCallback,
    'S',
    alwaysPopulate=False,
    onlyMatchWordStart=False
    )

LayeredMenuAPI.RegisterLayeredMenu(layeredMenu, 'getShaderNodes')
