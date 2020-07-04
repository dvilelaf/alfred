from Command import Command
from tools import getPPAlist, isPackageInstalled, installPackages
import os
import getpass


class PackageCollection:

    def __init__(self):
        self.packages = []
        self.preInstalls = {}
        self.postInstalls = {}

        self.failed = {}


    def add(self, package, preInstalls=None, postInstalls=None):
        self.packages.append(package)

        if not preInstalls:
            self.preInstalls[package] = preInstalls

        if postInstalls:
            self.postInstalls[package] = postInstalls


    def installPackage(self, package):
        pass


    def preProcessPackage(self, package):
        if package not in self.failed:
            for preInstall in self.preInstalls[package]:
                cmd = Command(preInstall)
                if not cmd.succeeded:
                    if package in self.failed:
                        self.failed[package].append(('preInstall', preInstall))
                    else:
                        self.failed[package] = [('preInstall', preInstall)]


    def postProcessPackage(self, package):
        if package not in self.failed:
            for postInstall in self.postInstalls[package]:
                cmd = Command(postInstall)
                if not cmd.succeeded:
                    if package in self.failed:
                        self.failed[package].append(('postInstall', postInstall))
                    else:
                        self.failed[package] = [('postInstall', postInstall)]


    def process(self):
        for package in self.packages:
            self.preProcessPackage(package)

            if package not in self.failed:
                self.installPackage(package)

            if package not in self.failed:
                self.postProcessPackage(package)

        return len(self.failed) == 0



class BatchedPackageCollection(PackageCollection):

    def __init__(self):
        super().__init__()


    def installBatch(self):
        pass


    def processBatch(self):

        for package in self.packages:
            self.preProcessPackage(package)

        self.installBatch()

        for package in self.packages:
            self.postProcessPackage(package)

        return len(self.failed) == 0



class RepoPackages(BatchedPackageCollection):

    def __init__(self):
        super().__init__()


    def installPackage(self, package):
        cmd = Command(['apt', 'install', package])
        if not cmd.succeeded:
            if package in self.failed:
                self.failed[package].append('install')
            else:
                self.failed[package] = ['install']


    def installBatch(self):
        cmd = Command(['apt', 'install'] + [i for i in self.packages if i not in self.failed])
        if not cmd.succeeded:
            self.failed['batch'] = ['install']



class PPAPackages(RepoPackages):

    def __init__(self):
        super().__init__()
        self.addedPPAs = getPPAlist()


    def add(self, ppa, package, preInstalls=None, postInstalls=None):
        if ppa not in self.addedPPAs:
            cmd = Command(['add-apt-repository', ppa])
            if cmd.succeeded:
                self.addedPPAs.append(ppa)
                super().add(package, preInstalls, postInstalls)
            else:
                self.failed[package] = ['add-apt-repository']
        else:
            super().add(package, preInstalls, postInstalls)



class DebPackages(RepoPackages):

    def __init__(self):
        super().__init__()
        tmpDir = '/tmp/Alfred/debs'
        if not os.path.isdir(tmpDir):
            os.makedirs(tmpDir)
        self.nDebs = 0


    def add(self, url, preInstalls=None, postInstalls=None):
        package = f'/tmp/Alfred/debs/package{self.nDebs}.deb'
        download = Command(['wget', '-O', package, url])
        if download.succeeded:
            self.nDebs += 1
            super().add(package, preInstalls, postInstalls)
        else:
            self.failed[package] = ['debDownload']



class FlatpakPackages(PackageCollection):

    def __init__(self):
        super().__init__()
        self.remotes = {}
        if not isPackageInstalled('flatpak'):
            installPackages('flatpak')
            Command(['flatpak', 'remote-add', '--if-not-exists', 'flathub', 'https://flathub.org/repo/flathub.flatpakrepo'])


    def add(self, package, preInstalls=None, postInstalls=None, remoteName='flathub', remoteUrl=''):

        if remoteName != 'flathub':
            Command(['flatpak', 'remote-add', '--if-not-exists', remoteName, remoteUrl])

        self.remotes[package] = remoteName
        return super().add(package, preInstalls, postInstalls)


    def installPackage(self, package):
        cmd = Command(['flatpak', 'install', self.remotes[package], package])
        if not cmd.succeeded:
            if package in self.failed:
                self.failed[package].append('flatpak-install')
            else:
                self.failed[package] = ['flatpak-install']



class AppImagePackages(PackageCollection):

    def __init__(self):
        super().__init__()
        self.defaultDir = f'home/{getpass.getuser()}/Applications'

        if not os.path.isdir(self.defaultDir):
            os.makedirs(self.defaultDir)


    def add(self, package, url, preInstalls=None, postInstalls=None):
        fullPath = self.defaultDir + '/' + package + '.AppImage'
        download = Command(['wget', '-O', fullPath, url])
        if download.succeeded:
            self.failed[package] = ['appimage-download']
            return super().add(package, preInstalls, postInstalls)



class SnapPackages(PackageCollection):

    def __init__(self):
        super().__init__()
        if not isPackageInstalled('snapd'):
            installPackages('snapd')
        self.options = {}


    def add(self, package, options=None, preInstalls=None, postInstalls=None):
        if options:
            self.options[package] = options
        return super().add(package, preInstalls, postInstalls)


    def installPackage(self, package):
        if package in self.options:
            cmd = Command(['snap', 'install', package, self.options[package]])
        else:
            cmd = Command(['snap', 'install', package])
        if not cmd.succeeded:
            if package in self.failed:
                self.failed[package].append('snap-install')
            else:
                self.failed[package] = ['snap-install']