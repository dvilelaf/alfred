#!/usr/bin/python3

import sys
import os
import subprocess
import urllib.request
import json
import re
from datetime import datetime


class runCmd:

    def __init__(self, cmd, stdin=None):

        self.stdin = None
        self.stdout = None
        self.stderr = None
        self.cmd = ' '.join(cmd)

        if stdin and type(stdin) is str:
            stdin = str.encode(stdin)

        try:

            if stdin:

                self.stdin = stdin

                result = subprocess.run(cmd,
                                        input=stdin,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        #capture_output=True,
                                        check=True)

            else:

                self.stdin = None

                result = subprocess.run(cmd,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        #capture_output=True,
                                        check=True)

            self.stdout = result.stdout.decode("utf-8") #.replace('\n', '')
            self.stderr = result.stderr.decode("utf-8") #.replace('\n', '')

        except subprocess.CalledProcessError as e:

            self.returncode = e.returncode
            self.succeeded = False
            self.stdout = e.stdout.decode("utf-8")
            self.stderr = e.stderr.decode("utf-8")

        else:

            self.returncode = 0
            self.succeeded = True


def checkPackage(name):

    if runCmd(['dpkg', '-s', name]).succeeded:
        return True
    else:
        return False

    
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

    runCmd(['notify-send', '-i', 'utilities-terminal', 'Alfred', message])


class Zenity:

    def __init__(self):
        pass

    @staticmethod
    def password():

        runCmd(['sudo', '-k'])

        while True:

            getPasswordCmd = runCmd(['zenity', '--password', '--title=Alfred'])

            if getPasswordCmd.succeeded:

                checkPasswordCmd = runCmd(['sudo', '-S', 'id', '-u'],
                                          stdin=getPasswordCmd.stdout)

                if checkPasswordCmd.succeeded and checkPasswordCmd.stdout.replace('\n', '') == '0':

                    return getPasswordCmd.stdout.replace('\n', '')

                else:

                    runCmd(['zenity', 
                            '--info', 
                            '--width=200', 
                            '--title=Alfred', 
                            '--text=Wrong password, try again'])

            else:

                sys.exit()


    @staticmethod
    def progressBar(pulsating=False, noCancel=False, title='', text='', percentage=0, height=100, width=500):

        args = ['zenity', '--progress']

        if pulsating:
            args.append('--pulsate')

        if noCancel:
            args.append('--no-cancel')

        args.append('--title={}'.format(title))
        args.append('--text="{}"'.format(text))
        args.append('--percentage={}'.format(percentage))
        args.append('--height={}'.format(height))
        args.append('--width={}'.format(width))

        process = subprocess.Popen(args, 
                                   stdin=subprocess.PIPE, 
                                   stdout=subprocess.PIPE, 
                                   stderr=subprocess.PIPE)

        def update(percent=0, message=''):

            process.stdin.write((str(percent) + '\n').encode())
            process.stdin.flush()

            if message:
                process.stdin.write(('# %s\n' % str(message)).encode())
                process.stdin.flush()

            return process.returncode

        return update


    @staticmethod
    def error(message):

        runCmd(['zenity', 
                '--error', 
                '--title=Alfred', 
                '--height=100',
                '--width=500',
                '--text={}'.format(message)])


    @staticmethod
    def table(data):

        args = ['zenity',
                '--list',
                '--checklist',
                '--height=720',
                '--width=1280',
                '--title=Alfred',
                '--text=Select tasks to perform:',
                '--column=Selection',
                '--column=Task',
                '--column=Description']

        args.extend(data)

        return runCmd(args)


    @staticmethod
    def info(message):

        runCmd(['zenity', 
                '--info', 
                '--title=Alfred', 
                '--height=100',
                '--width=200',
                '--text={}'.format(message)])


    @staticmethod
    def question(message, height=100, width=200):

        question = runCmd(['zenity', 
                           '--question', 
                           '--title=Alfred', 
                           '--height={}'.format(height),
                           '--width={}'.format(width),
                           '--text={}'.format(message)])

        return question.succeeded

    
    @staticmethod
    def textInfo(message):

        data = runCmd(['echo', message]).stdout
        runCmd(['zenity',
                '--text-info',
                '--height=700',
                '--width=800',
                '--title=Alfred'],
                stdin=data)

    
    @staticmethod
    def list(message, elements):

        runCmd(['zenity',
                '--list',
                '--height=500',
                '--width=500',
                '--title=Alfred',
                '--text={}'.format(message),
                '--hide-header', 
                '--column', 'Tasks with errors',
                elements])

class Alfred:

    def __init__(self, localRecipes=False):

        self.logFile = '/tmp/Alfred.log'
        self.log = 100 * '=' + '\n'
        self.log += 'NEW SESSION ' + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '\n'
        self.log += runCmd(['lsb_release', '-d']).stdout + '\n'
        self.log += runCmd(['uname', '-a']).stdout + '\n'
        self.errors = []

        # Check Zenity package
        zenity = checkPackage('zenity')

        # Check distro
        supportedDistro = False

        with open('/etc/os-release','r') as f:
            lines = f.readlines()

            for line in lines:
                if line == 'ID_LIKE=ubuntu\n' or line == 'ID_LIKE=debian\n':
                    supportedDistro = True
                    break

        if not supportedDistro:
            message = "This is not an Ubuntu or Ubuntu derivative distro. You can't run Alfred on this system."

            if zenity:
                Zenity.error(message)
            else:
                print(message)

            sys.exit()

        # Check architecture
        arch = runCmd(['uname', '-m'])

        if arch.stdout != 'x86_64\n':
            message = "This is not a 64-bit system. You can't run Alfred on this system."

            if zenity:
                Zenity.error(message)
            else:
                print(message)

            sys.exit()

        # Check /var/lib/dpkg/lock to ensure we can install packages
        lock = runCmd(['fuser', '/var/lib/dpkg/lock'])

        if lock.stdout != '':
            message = 'Another program is installing or updating packages. Please wait until this process finishes and then launch Alfred again.'

            if zenity:
                Zenity.error(message)
            else:
                print(message)

            sys.exit()

        # Check connectivity
        ping = runCmd(['ping', '-c', '1', 'google.com'])

        if not ping.succeeded:
            message = 'There is no connection to the Internet. Please connect and then launch Alfred again.'

            if zenity:
                Zenity.error(message)
            else:
                print(message)

        # Repair installation interruptions
        runCmd(['dpkg', '--configure', '-a'])

        # Get repositories
        self.repoList = getRepoList()

        # Install Zenity if needed
        if not zenity:
            runCmd(['apt', 'install', 'zenity'])

        # Load recipes
        if localRecipes:
            with open('recipes.json','r') as f:
                self.recipes = json.load(f)
        else:
            url = 'https://raw.githubusercontent.com/derkomai/alfred/master/recipes.json'
            jsonData = urllib.request.urlopen(url).read().decode('utf-8')
            self.recipes = json.loads(jsonData)

    
    def show(self):

        while True:

            # Build table
            tableData = []
        
            for recipe in self.recipes:

                if recipe['selected']:
                    select = 'TRUE'
                else:
                    select = 'FALSE'

                tableData.append(select)
                tableData.append(recipe['name'])
                tableData.append(recipe['description'])
            

            table = Zenity.table(tableData)

            # Check for closed window / cancel button
            if not table.succeeded:
                sys.exit()

            # Check zero tasks selected
            if table.stdout == '':
                Zenity.info('No tasks were selected')

                for i in range(len(self.recipes)):
                    self.recipes[i]['selected'] = False

                continue

            else:

                taskList = table.stdout[:-1].split('|') # Last char is \n

                self.taskList = []

                for i in range(len(self.recipes)):
                    if self.recipes[i]['name'] in taskList:
                        self.taskList.append(i)
                        self.recipes[i]['selected'] = True
                    else:
                        self.recipes[i]['selected'] = False

                break



    def process(self):

        # Get confirmation
        message = 'The selected tasks will be performed now. '
        message += "You won't be able to cancel this operation once started.\n\n"       
        message += 'Are you sure you want to continue?'

        while True:

            if not Zenity.question(message, height=100, width=350):
                self.show()
            else:
                break

        # Collect commands info
        ppas = []
        packages = []
        snaps = []
        snapsWithOptions = []
        debs = []
        generics = []

        for i in self.taskList:

            if self.recipes[i]['type'] == 'package':
                packages.extend(self.recipes[i]['recipe'])

            elif self.recipes[i]['type'] == 'snap':

                if len(self.recipes[i]['recipe']) == 1:
                    snaps.extend(self.recipes[i]['recipe'])
                else:
                    snapsWithOptions.append(self.recipes[i]['recipe'])

            elif self.recipes[i]['type'] == 'ppa':

                ppas.append(self.recipes[i]['recipe'][0])
                packages.extend(self.recipes[i]['recipe'][1:])

            elif self.recipes[i]['type'] == 'deb':

                debs.append(self.recipes[i]['recipe'])

            elif self.recipes[i]['type'] == 'generic':

                generics.append(self.recipes[i]['recipe'])


        # Skip already installed ppas
        for i in range(len(ppas)):
            if ppas[i] in self.repoList:
                ppas.pop(i)

        # Skip already installed packages
        for i in range(len(packages)):
            if checkPackage(packages[i]):
                packages.pop(i)

        # Create progress bar
        updateBar = Zenity.progressBar(pulsating=True, 
                                       noCancel=True, 
                                       title='Alfred', 
                                       text='Processing tasks')

        # Ensure software-properties-common is installed
        if len(ppas) > 0 and not checkPackage('software-properties-common'):
            self.checkAndLogCmd(runCmd(['apt', 'install', 'software-properties-common']))

        # Ensure snapd is installed
        if (len(snaps) > 0 or len(snapsWithOptions) > 0) and not checkPackage('snapd'):
            self.checkAndLogCmd(runCmd(['apt', 'install', 'snapd']))

        # Ensure libnotify-bin is installed
        if not checkPackage('libnotify-bin'):
            self.checkAndLogCmd(runCmd(['apt', 'install', 'libnotify-bin']))

        # Process ppas
        updateBar(0, 'Processing PPAs')
        for ppa in ppas:
            self.checkAndLogCmd(runCmd(['add-apt-repository', '-y', ppa]))

        # Update
        updateBar(0, 'Updating package list')
        self.checkAndLogCmd(runCmd(['apt', 'update']))

        # Process packages
        if len(packages) > 0:
            updateBar(0, 'Installing packages')
            self.checkAndLogCmd(runCmd(['apt', 'install', '-y'].extend(packages)))

        # Process snaps
        updateBar(0, 'Installing snaps')
        if len(snaps) > 0:
            self.checkAndLogCmd(runCmd(['snap', 'install'].extend(snaps)))

        # Process snaps with options
        for snap in snapsWithOptions:
            self.checkAndLogCmd(runCmd(['snap', 'install'].extend(snap)))

        # Process debs
        updateBar(0, 'Processing debs')
        for deb in debs:
            self.checkAndLogCmd(runCmd(['wget', '-q', '-O', '/tmp/package.deb', deb]))
            self.checkAndLogCmd(runCmd(['apt', 'install', '-y', '/tmp/package.deb']))

        # Process generics
        updateBar(0, 'Processing generics')
        for cmds in generics:
            self.checkAndLogCmd(runCmd(cmds))

        # Run post-installation tasks
        updateBar(0, 'Processing PPAs')
        for i in self.taskList:
            if 'post' in self.recipes[i]:
                self.checkAndLogCmd(runCmd(self.recipes[i]['post']))

        # Autoremove
        self.checkAndLogCmd(runCmd(['apt', 'autoremove', '-y']))

        # Check errors and notify
        if len(self.errors) == 0:
            message = 'All tasks completed succesfully'
        else:
            message = 'Some tasks ended with errors'

        notify(message)
        updateBar(message)

        if len(self.errors) > 0:
            Zenity.list('The following tasks ended with errors and could not be completed:', self.errors)
            Zenity.textInfo('Please notify the following error log at https://github.com/derkomai/alfred/issues\n\n' + self.log)

        # Write log and change permissions
        with open(self.logFile, 'a') as f:
            f.write(self.log)

            sudoUser = runCmd(['echo', '$SUDO_USER']).stdout
            runCmd(['chown', '{}:{}'.format(sudoUser, sudoUser), self.logFile])


    def checkAndLogCmd(self, cmd):
        
        if not cmd.succeeded:
            log = 100 * '-' + '\n' 
            log += '<ERRORED COMMAND>: ' + cmd.cmd + '\n'
            log += '<STDOUT>:\n' + cmd.stdout + '\n\n'
            log += '<STDERR>:\n' + cmd.stderr
            self.log += log
            self.errors.append(cmd.cmd)



if __name__ == '__main__':
    
    if os.geteuid() == 0:

        alfred = Alfred()
        alfred.show()
        alfred.process()

    else:

        runCmd(['sudo', 'python3', sys.argv[0]], stdin=Zenity.password())