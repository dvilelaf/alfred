import subprocess
import sys


class Command:

    def __init__(self, args, stdin=None):

        # Init
        self.args = args
        self.stdin = stdin
        self.stdout = None
        self.stderr = None
        self.returnCode = None
        self.succeeded = False

        # Check args
        if type(self.args) != list:
            self.succeeded = False
            self.stderr = 'Args must be of type list'
            return

        if self.stdin and type(self.stdin) != str:
            self.stderr = 'Stdin must be of type string'
            return

        if self.args[0] == 'sudo':
            self.args.insert(1, '-S') # sudo needs -S option to receive password from stdin

            if not stdin:
                self.stderr = 'Sudo password not provided'
                return

        if self.stdin:
            self.stdin = self.stdin.replace('\n', '')

        # Run
        self.run()


    def __str__(self):

        return f'stdout: {self.stdout}\nstderr: {self.stderr}\nreturn code: {self.returnCode}'


    def run(self):

        try:

            if self.stdin:

                if self.args[0] == 'sudo':

                    p = subprocess.Popen(self.args,
                                         stdin=subprocess.PIPE,
                                         stdout=subprocess.PIPE)

                    stdout, stderr = p.communicate(f'{self.stdin}\n'.encode()) # Send password
                    self.stdout = stdout.decode('utf-8') if stdout else stdout
                    self.stderr = stderr.decode('utf-8') if stderr else stderr
                    self.succeeded = True
                    self.returnCode = 0
                    return

                else:

                    # Add capture_output for Python version 3.7 or greater
                    if sys.version_info[1] < 7:

                        result = subprocess.run(self.args,
                                                input=self.stdin.encode(),
                                                stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE,
                                                #timeout=600,
                                                check=True)

                    else:

                        result = subprocess.run(self.args,
                                                input=self.stdin.encode(),
                                                capture_output=True, # python >= 3.7
                                                #timeout=600,
                                                check=True)

            else:

                # Add capture_output for Python version 3.7 or greater
                if sys.version_info[1] < 7:

                    result = subprocess.run(self.args,
                                            stdout=subprocess.PIPE,
                                            stderr=subprocess.PIPE,
                                            #timeout=600,
                                            check=True)

                else:

                    result = subprocess.run(self.args,
                                            capture_output=True, # python >= 3.7
                                            #timeout=600,
                                            check=True)

            self.stdout = result.stdout.decode("utf-8")
            self.stderr = result.stderr.decode("utf-8")
            self.succeeded = True
            self.returnCode = 0

        except subprocess.CalledProcessError as e:

            self.returnCode = e.returnCode if hasattr(e, 'returnCode') else None
            self.stdout = e.stdout.decode("utf-8")
            self.stderr = e.stderr.decode("utf-8")

        except subprocess.TimeoutExpired as e:

            self.stderr = f'Command timeout ({e.timeout}s)'

        except Exception as e:

            self.stderr = e.message if hasattr(e, 'message') else str(e)

        finally:

            # Strip whitespaces
            self.stdout = self.stdout.strip() if self.stdout else self.stdout
            self.stderr = self.stderr.strip() if self.stderr else self.stderr