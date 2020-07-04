import requests
from Command import Command
import os
import re
import time


def checkInternetConnection():
    try:
        _ = requests.get('https://www.cloudflare.com/', timeout=5)
        return True

    except requests.ConnectionError:
        pass

    return False


def downloadURLtoFile(url, filePath):
    try:
        response = requests.get(url, allow_redirects=True)

    except requests.exceptions.RequestException:
        return False

    if response.content == b'404: Not Found':
        return False

    try:
        open(filePath, 'wb').write(response.content)

    except OSError:
        return False

    return True


def getPPAlist():
    repoList = []

    for root, dirs, files in os.walk('/etc/apt/'):
        for file in files:
            if file.endswith(".list"):
                with open(os.path.join(root, file)) as f:
                    lines = f.readlines()

                    for line in lines:
                        if re.match(r'^deb http:\/\/ppa\.launchpad\.net\/[a-z0-9\-]+\/[a-z0-9\-]+', line):

                            data = line.split('/')
                            repoList.append('ppa:' + data[3] + '/' + data[4])

    return repoList



def notify(message):
    Command(['notify-send', '-i', 'utilities-terminal', 'Alfred', message])



def waitForDpkgLock():
    tries = 0

    while True:

        dpkgLock = Command(['fuser', '/var/lib/dpkg/lock'])
        aptLock = Command(['fuser', '/var/lib/apt/lists/lock'])

        if dpkgLock.stdout != '' or aptLock.stdout != '':
            time.sleep(3)
            tries += 1

        else:
            return True

        if tries > 10:
            return False



def getDistroInfo():
    info = {}

    for i in Command(['cat', '/etc/os-release']).stdout.replace('"', '').split('\n'):
        key, value = i.split('=')
        info[key] = value

    return info



def getUnameInfo():
    return Command(['uname', '-a']).stdout



def isPackageInstalled(package):
    cmd = Command(['dpkg', '-s', package])

    if cmd.succeeded and 'Status: install ok installed' in cmd.stdout:
        return True
    else:
        return False



def installPackages(packages):
    cmd = Command(['apt', 'install'] + packages if type(packages) is list else [packages])
    return cmd.succeeded



def repairPackages():
    cmd = Command(['dpkg', '--configure', '-a'])
    return cmd.succeeded



if __name__ == '__main__':
    print(getDistroInfo())