--[[

Location: /root
renderer: prman

Save statistics XML file next to render output

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
path_attribute = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
name_attribute = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multi-channeled exr file
local path = pystring.os.path.join(path_attribute, string.format("%s.xml", name_attribute) )
path = pystring.replace(path, '\\', '/')



-- switch on statistics output
Interface.SetAttr('prmanGlobalStatements.options.statistics.level', IntAttribute(1))
Interface.SetAttr('prmanGlobalStatements.options.statistics.xmlfilename', StringAttribute(path))
