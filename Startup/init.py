"""
Add arnold render button at the top of the interface

"""

from Katana import Callbacks
import os
import sys


# add paths from katana resources to access importing modules from there
for i in os.getenv('KATANA_RESOURCES').split(';'):
	if os.path.exists(i):
		if i not in sys.path:
			sys.path.append(i)


# create callback
def onStartupComplete(objectHash):

	# try if Katana launched in interactive (GUI) mode
	try:
		from Startup import arnoldRunButton
	except:
		pass


# register callback
Callbacks.addCallback(Callbacks.Type.onStartupComplete, onStartupComplete)

