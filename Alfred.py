from Command import Command
from Collections import *
from tools import *
from datetime import datetime


class Alfred:

    def __init__(self, recipes, selectedRecipes):
        self.recipes = recipes
        self.selectedRecipes = selectedRecipes
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
        repairPackages()

        # Create collections
        self.collections = {'generic': GenericCollection(),
                            'repo': RepoCollection(),
                            'ppa': PPACollection(),
                            'deb': DebCollection(),
                            'flatpak': FlatpakCollection(),
                            'appimage': AppImageCollection(),
                            'snap': SnapCollection()}

        # Add packages to collections
        for selectedRecipe in self.selectedRecipes:
            if type(selectedRecipe) is list:
                packageName = selectedRecipe[0]
                packageType = selectedRecipe[1]

                preInstalls = None
                if 'preInstall' in self.recipes[packageType]['recipes'][packageType]:
                    preInstalls = [self.recipes[packageType]['recipes'][packageType]['preInstall']]

                postInstalls = None
                if 'postInstall' in self.recipes[packageType]['recipes'][packageType]:
                    postInstalls = [self.recipes[packageType]['recipes'][packageType]['postInstall']]

                self.collections[packageType].add(packageName, preInstalls=preInstalls, postInstalls=postInstalls)

            else:
                self.collections['generic'].add(selectedRecipe, self.recipes[selectedRecipe]['recipes'][0]['recipe'])

        # Process collections
        for _, collection in self.collections.items():
            if collection.batched:
                collection.processBatch()
            else:
                collection.process()