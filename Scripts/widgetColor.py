

from Katana import (
    NodegraphAPI,
    QtWidgets,
    QtCore,
    QtGui,
    UI4 )

import json
import os
import re


time = int(NodegraphAPI.GetCurrentTime())





class ColorButton (QtWidgets.QWidget):

    def __init__ (self):
        super(ColorButton, self).__init__()

        self.color_data = [0.0, 0.0, 0.0]

        self.color = QtWidgets.QPushButton()
        self.color.setFlat(True)
        self.color.clicked.connect(self.applyColor)


        self.button_layout = QtWidgets.QVBoxLayout()
        self.button_layout.setSpacing(0)
        self.button_layout.setContentsMargins(0, 0, 0, 0)

        self.button_layout.addWidget(self.color)
        self.setLayout(self.button_layout)

        self.setColor("#808080")

    def setButtonSize (self, value):
        self.color.setMaximumSize(value, value)
        self.color.setMinimumSize(value, value)

    def setColor (self, value):
        self.color.setStyleSheet('''
            QPushButton {
                border: none;
                background: %s }
            QPushButton::pressed { 
                border: 6px solid #ffffff;}
            ''' % (value) )

    def setColorData (self, data):
        self.color_data = data

    def appendWidget (self, item):
        self.button_layout.addWidget(item)

    def applyColor (self):

        for parameter in self.getParameters():

            parameter[0].setValue( self.color_data[0], time )
            parameter[1].setValue( self.color_data[1], time )
            parameter[2].setValue( self.color_data[2], time )


    def getParameters (self):

        parameters = []

        for node in NodegraphAPI.GetAllEditedNodes():
            if node.getType() == "PrmanShadingNode":

                layerType = node.getParameter("nodeType").getValue(time)

                if layerType == "PxrLayeredBlend":

                    parameter = node.getParameter("parameters.backgroundRGB")
                    if parameter:
                        parameter.getChild("enable").setValue( float(True), time )

                        value0 = parameter.getChild("value.i0")
                        value1 = parameter.getChild("value.i1")
                        value2 = parameter.getChild("value.i2")

                        parameters.append([value0, value1, value2])

            if node.getType() == "Group":
                parameter = node.getParameter('user.Parameters.Surface.Albedo')
                if parameter:

                    value0 = parameter.getChild("i0")
                    value1 = parameter.getChild("i1")
                    value2 = parameter.getChild("i2")

                    parameters.append([value0, value1, value2])

            if node.getType() == "OpScript":
                parameter = node.getParameter('user.color')
                if parameter:

                    value0 = parameter.getChild("i0")
                    value1 = parameter.getChild("i1")
                    value2 = parameter.getChild("i2")

                    parameters.append([value0, value1, value2])

        return parameters


    def albedoMath (self, data):

        average = 0.0
        for i in data: average += i / len(data)

        desaturate_factor     = 4.0
        desaturate_multiplier = (1.0 - average**(1.0/2.2) ) ** desaturate_factor

        for i in range( len(data) ):
            value = data[i]
            value = value + (average - value) * desaturate_multiplier
            data[i] = value

        luminance_multiplier = 0.5
        data = [ i * luminance_multiplier for i in data]

        return data





class ColorSwatch (ColorButton):

    def __init__ (self, data):
        super(ColorSwatch, self).__init__()


        self.data = data
        self.setColorData( self.albedoMath(data["rgb"]) )

        self.space = "  "


        prefix = self.data["prefix"]
        suffix = self.data["suffix"]


        self.name = QtWidgets.QLabel()

        text = "{}{}".format(prefix, suffix)
        text = re.sub("[ ]+", " ", text)
        text = "{}{}".format(self.space, text)
        self.name.setText(text)

        self.name.setIndent(0)
        self.name.setAlignment(QtCore.Qt.AlignBottom)
        self.name.setStyleSheet('font: bold 10px "Segoe UI"; color: #303030; background: #ffffff')



        self.color_name = QtWidgets.QLabel()
        self.color_name.setIndent(0)
        self.color_name.setAlignment(QtCore.Qt.AlignTop)
        self.color_name.setStyleSheet('font: 10px "Segoe UI"; color: #606060; background: #ffffff')

        name = re.sub(prefix, "", self.data["name"])
        name = re.sub(suffix, "", name)
        self.color_name.setText("{}{}".format(self.space, name))


        self.button_layout.addWidget(self.name)
        self.button_layout.addWidget(self.color_name)

        self.setColor(self.data["hex"])


    def setWidgetSize(self, width, height):

        self.setMaximumSize(width, height)
        self.setMinimumSize(width, height)

        self.setButtonSize(width)

        name_size       = (height - width) * 0.375
        color_name_size =  height - width  - name_size

        self.name.setFixedHeight(name_size)
        self.color_name.setFixedHeight(color_name_size)







class PaletteGroup (QtWidgets.QWidget):

    def __init__ (self, data):
        super(PaletteGroup, self).__init__()

        self.layout = QtWidgets.QHBoxLayout()
        self.layout.setSpacing(0)
        self.layout.setContentsMargins(0, 0, 0, 0)


        for hex_value in data:

            color = ColorButton()
            color.setColor(hex_value)

            hex_value = re.sub("#", "", hex_value)

            color_data = self.hexToFloat(hex_value)
            color_data = self.albedoMath(color_data)

            color.setColorData(color_data)
            color.setMaximumSize(100, 140)
            color.setMinimumSize(100, 140)
            color.setButtonSize(100)

            index = 0
            for float_value in color_data:

                value = QtWidgets.QLabel()
                value.setIndent(0)
                value.setStyleSheet('font: 8px "Segoe UI"; color: #303030; background: #ffffff')
                value.setText("    {:0.4f}".format(float_value))

                if index == 0:
                    value.setFixedHeight(15)
                    value.setAlignment(QtCore.Qt.AlignBottom)
                elif index == 1:
                    value.setFixedHeight(8)
                elif index == 2:
                    value.setFixedHeight(17)
                    value.setAlignment(QtCore.Qt.AlignTop)

                color.appendWidget(value)
                index += 1

            self.layout.addWidget(color)


        self.setLayout(self.layout)


    def setWidgetSize (self, width, height):
        self.setMaximumSize(width, height)
        self.setMinimumSize(width, height)


    def hexToFloat (self, value):
        intList = [int(value[i:i+2], 16) for i in (0, 2, 4)]
        floatList = [1.0/255.0*float(i) for i in intList]
        return floatList






class ColorBook (UI4.Tabs.BaseTab):


    def __init__(self, parent):
        UI4.Tabs.BaseTab.__init__(self, parent)

        self.swatches_data = []


        self.layout = QtWidgets.QVBoxLayout()


        self.color_grid = QtWidgets.QListWidget()
        self.color_grid.itemClicked.connect(self.setLast)

        self.gridX = 100
        self.gridY = 140
        space = 2

        self.color_grid.setViewMode(QtWidgets.QListView.IconMode)
        self.color_grid.setIconSize(QtCore.QSize(self.gridX + space, self.gridY + space))

        self.color_grid.setMovement(QtWidgets.QListView.Static)
        self.color_grid.setGridSize(QtCore.QSize(self.gridX + space, self.gridY + space))

        self.color_grid.setResizeMode(QtWidgets.QListView.Adjust)
        self.color_grid.setSelectionMode(QtWidgets.QAbstractItemView.SingleSelection)


        self.last_swatch = QtWidgets.QLabel()
        self.last_swatch.setFixedHeight(200)
        self.last_swatch.setStyleSheet(" background: #000000 " )

        self.layout.addWidget(self.color_grid)
        # self.layout.addWidget(self.last_swatch)
        self.setLayout(self.layout)


    def setLast (self, item):
        data = item.data(QtCore.Qt.UserRole)
        self.last_swatch.setStyleSheet(" background: %s " % (data["hex"]) )


    def sorter (self, value):

        value = value["code"]

        dot = False
        float_sting = ""

        for character in value:

            if character.isdigit():
                float_sting += character

            elif character in ["-", " "]:
                if not dot:
                    dot = True
                    float_sting += "."
            else:
                float_sting += str(ord(character))

        if not dot:
            float_sting += ".0"

        return float(float_sting)


    def loadSwatches (self, path):

        if os.path.exists(path):

            with open(path, 'r') as file:
                data = json.load(file)
                if data:

                    prefix = data["prefix"]
                    suffix = data["suffix"]

                    data = data["records"]
                    data = [data[i] for i in data]

                    for i in range( len(data) ):
                        data[i]["prefix"] = prefix
                        data[i]["suffix"] = suffix

                    data = sorted( data, key=lambda x: self.sorter(x) )

                    self.swatches_data = data
                    self.buildSwatches()


    def buildSwatches (self):

        for index in range( len(self.swatches_data) ):

            item = QtWidgets.QListWidgetItem(self.color_grid)
            item.setSizeHint(QtCore.QSize(self.gridX, self.gridY))

            color_item = ColorSwatch(self.swatches_data[index])
            color_item.setWidgetSize(self.gridX, self.gridY)

            self.color_grid.setItemWidget(item, color_item)

            item.setData(QtCore.Qt.UserRole, self.swatches_data[index])





class PaletteBook (UI4.Tabs.BaseTab):


    def __init__(self, parent):
        UI4.Tabs.BaseTab.__init__(self, parent)

        self.palette_data = []


        self.layout = QtWidgets.QHBoxLayout()


        self.palette_grid = QtWidgets.QListWidget()

        self.gridX = 500
        self.gridY = 140
        space = 4

        self.palette_grid.setViewMode(QtWidgets.QListView.IconMode)
        self.palette_grid.setIconSize(QtCore.QSize(self.gridX + space, self.gridY + space))

        self.palette_grid.setMovement(QtWidgets.QListView.Static)
        self.palette_grid.setGridSize(QtCore.QSize(self.gridX + space, self.gridY + space))

        self.palette_grid.setResizeMode(QtWidgets.QListView.Adjust)
        self.palette_grid.setSelectionMode(QtWidgets.QAbstractItemView.SingleSelection)

        self.layout.addWidget(self.palette_grid)
        self.setLayout(self.layout)


    def loadPalettes (self, path):

        if os.path.exists(path):

            with open(path, 'r') as file:
                data = json.load(file)
                if data:

                    self.palette_data = data
                    self.buildPalettes()


    def buildPalettes (self):

        for data in self.palette_data:

            item = QtWidgets.QListWidgetItem(self.palette_grid)
            item.setSizeHint(QtCore.QSize(self.gridX, self.gridY))

            palette_item = PaletteGroup(data)
            palette_item.setWidgetSize(self.gridX, self.gridY)

            self.palette_grid.setItemWidget(item, palette_item)
