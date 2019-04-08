--[[

Location: /root
renderer: prman

Add outputChannel attributes for AOVs and create render output as multi-channeled exr file

Required attributes:
    user.shotPath: (string) path where result render file will be saved
    user.shotName: (string) frame numbered name ('shotName_F%03d'%frame -> AttributeSet)

]]



-- global variable that collect all defined here AOV channels as a string
-- and will be used to adjust renderSettings.output attribute
channels = ''

function PrmanOutputChannelDefine (name, type)
	--[[ Works the same way as the PrmanOutputChannelDefine ]]

	-- add current AOV channel to global variable
    if channels == '' then
        channels = name
    else
        channels = channels .. ',' .. name
    end

    -- create outputChannel by name
    Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.type', name), StringAttribute(type))
    Interface.SetAttr(string.format('prmanGlobalStatements.outputChannels.%s.name', name), StringAttribute(name))

end



-- define all AOV channels that you need
PrmanOutputChannelDefine("Ci", "varying color")
PrmanOutputChannelDefine("a", "varying float")
PrmanOutputChannelDefine("time", "varying float")
PrmanOutputChannelDefine("Oi", "varying color")
PrmanOutputChannelDefine("id", "varying float")
PrmanOutputChannelDefine("rawId", "varying float")
PrmanOutputChannelDefine("cpuTime", "varying float")
PrmanOutputChannelDefine("sampleCount", "varying float")
PrmanOutputChannelDefine("curvature", "varying float")
PrmanOutputChannelDefine("mpSize", "varying float")
PrmanOutputChannelDefine("biasR", "varying float")
PrmanOutputChannelDefine("biasT", "varying float")
PrmanOutputChannelDefine("incidentRayRadius", "varying float")
PrmanOutputChannelDefine("incidentRaySpread", "varying float")
PrmanOutputChannelDefine("P", "varying vector")
PrmanOutputChannelDefine("Po", "varying vector")
PrmanOutputChannelDefine("dPdu", "varying vector")
PrmanOutputChannelDefine("dPdv", "varying vector")
PrmanOutputChannelDefine("dPdw", "varying vector")
PrmanOutputChannelDefine("PRadius", "varying float")
PrmanOutputChannelDefine("du", "varying float")
PrmanOutputChannelDefine("dv", "varying float")
PrmanOutputChannelDefine("dw", "varying float")
PrmanOutputChannelDefine("u", "varying float")
PrmanOutputChannelDefine("v", "varying float")
PrmanOutputChannelDefine("w", "varying float")
PrmanOutputChannelDefine("Ngn", "varying normal")
PrmanOutputChannelDefine("Nn", "varying normal")
PrmanOutputChannelDefine("dPdtime", "varying vector")
PrmanOutputChannelDefine("Non", "varying normal")
PrmanOutputChannelDefine("motionBack", "varying vector")
PrmanOutputChannelDefine("motionFore", "varying vector")
PrmanOutputChannelDefine("Tn", "varying vector")
PrmanOutputChannelDefine("Vn", "varying vector")
PrmanOutputChannelDefine("VLen", "varying float")
PrmanOutputChannelDefine("z", "varying float")
PrmanOutputChannelDefine("outsideIOR", "varying float")



-- get string value from added earlier user-defined attribute that contains path for render outputs
local path_attribute = Interface.GetAttr('user.shotPath')
local path_project = Attribute.GetStringValue(path_attribute, '')

-- get string value from added earlier user-defined attribute that contains name of the current shot
local name_attribute = Interface.GetAttr('user.shotName')
local name = Attribute.GetStringValue(name_attribute, '')

-- create full path string to save multi-channeled exr file
local path = pystring.os.path.join(path_project, string.format("%s_aovs.exr", name))



-- Create one render output for all AOV outputChannels

-- add 'name' and 'raw' type parameters
-- switch location type to 'file' mode and set 'renderLocation' parameter
Interface.SetAttr('renderSettings.outputs.aovs.type', StringAttribute("raw"))
Interface.SetAttr('renderSettings.outputs.aovs.rendererSettings.channel', StringAttribute(channels))
Interface.SetAttr('renderSettings.outputs.aovs.locationType', StringAttribute("file"))
Interface.SetAttr('renderSettings.outputs.aovs.locationSettings.renderLocation', StringAttribute(path))
