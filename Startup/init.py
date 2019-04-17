"""
Add prman render button at the top of the interface

"""

from Katana import Callbacks
import os
import sys


for i in os.getenv('KATANA_RESOURCES').split(';'):
	if os.path.exists(i):
		if i not in sys.path:
			sys.path.append(i)


def onStartupComplete(objectHash):
	from Startup import prmanRunButton


Callbacks.addCallback(Callbacks.Type.onStartupComplete, onStartupComplete)
