import subprocess
import sys


class Command:

    def __init__(self, args, stdin=None, piped=False):

        self.command = ' '.join(args)
        self.args = args
        self.stdin = stdin

        self.stdout = None
        self.stderr = None
        self.returnCode = None
        self.succeeded = None

        if stdin and type(stdin) is str:

            if stdin[-1] == '\n':
                self.stdin = str.encode(stdin[:-1])
            else:
                self.stdin = str.encode(stdin)


def runCommand(args, stdin=None, piped=False):

    if len(args) == 1 and '|' in args[0]:

        args = [ i.strip().split(' ') for i in args[0].split('|') ]
        return runCommand(args, piped=True)

    if piped:

        if len(args) > 2:
            return runCommand(args[-1], stdin=runCommand(args[:-1], piped=True).stdout)

        elif len(args) == 2:
            return runCommand(args[1], stdin=runCommand(args[0], piped=False).stdout)


    Command = Command(args, stdin)

    try:

        if Command.stdin:

            if sys.version_info[1] < 7: # Add capture_output for Python version 3.7 or greater

                result = subprocess.run(Command.args,
                                        input=Command.stdin,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        #timeout=600,
                                        check=True)

            else:

                result = subprocess.run(Command.args,
                                        input=Command.stdin,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        capture_output=True, # python >= 3.7
                                        #timeout=600,
                                        check=True)

        else:

            if sys.version_info[1] < 7:

                result = subprocess.run(Command.args,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        #timeout=600,
                                        check=True)

            else:

                result = subprocess.run(Command.args,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        capture_output=True, # python >= 3.7
                                        #timeout=600,
                                        check=True)

        Command.stdout = result.stdout.decode("utf-8")
        Command.stderr = result.stderr.decode("utf-8")

    except subprocess.CalledProcessError as e:

        Command.succeeded = False
        Command.returnCode = e.returnCode
        Command.stdout = e.stdout.decode("utf-8")
        Command.stderr = e.stderr.decode("utf-8")

    except subprocess.TimeoutExpired as e:

        Command.succeeded = False
        Command.stdout = 'COMMAND TIMEOUT ({}s)'.format(e.timeout)

    except Exception as e:

        Command.succeeded = False
        Command.stdout = ''
        if hasattr(e, 'message'):
            Command.stderr = e.message
        else:
            Command.stderr = str(e)

    else:

        Command.returnCode = 0
        Command.succeeded = True

    finally:

        return Command