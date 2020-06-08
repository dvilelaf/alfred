import requests
from Command import Command

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


def getRepoList():

    repoList = []

    for root, dirs, files in os.walk('/etc/apt/'):
        for file in files:
            if file.endswith(".list"):
                with open(os.path.join(root, file)) as f:
                    lines = f.readlines()

                    for line in lines:
                        if re.match('^deb http:\/\/ppa\.launchpad\.net\/[a-z0-9\-]+\/[a-z0-9\-]+', line):

                            data = line.split('/')
                            repoList.append('ppa:' + data[3] + '/' + data[4])

    return repoList



def notify(message):

    userID = runCmd(['id', '-u', os.environ['SUDO_USER']]).stdout.replace('\n', '')

    runCmd(['sudo', '-u', os.environ['SUDO_USER'], 'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/{}/bus'.format(userID),
            'notify-send', '-i', 'utilities-terminal', 'Alfred', message])


def waitForDpkgLock():

    tries = 0

    while True:

        dpkgLock = runCmd(['fuser', '/var/lib/dpkg/lock'])
        aptLock = runCmd(['fuser', '/var/lib/apt/lists/lock'])

        if dpkgLock.stdout != '' or aptLock.stdout !='':
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



if __name__ == '__main__':
    print(getDistroInfo())