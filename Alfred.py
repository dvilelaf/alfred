from Command import Command
from PackageCollections import *
from tools import getDistroInfo, getUnameInfo
from datetime import datetime


class Alfred:

    def __init__(self, recipes):
        self.recipes = recipes
        logFileName = '/var/log/Alfred.log'
        mode = 'a' if os.path.exists(log) else 'w'
        self.logFile = open(logFileName, mode)

        # Set default language
        Command(['export','LC_ALL=C'])

        self.log('=============================================================================')
        self.log(f"New Alfred session started on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.log(f"{getUnameInfo()}")
        distroInfo = getDistroInfo()
        self.log(f"{distroInfo['NAME']} {distroInfo['VERSION']} ({distroInfo['ID_LIKE']})")


    def __del__(self):
        self.logFile.close()


    def log(self, message):
        self.logFile.write(message + '\n')


    def run(self):
        # Repair installation interruptions
        Command(['dpkg', '--configure', '-a'])