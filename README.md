# Alfred

A script to install all your favourite applications and perform the most
common tasks automatically in Debian, Ubuntu and their derivative distros.

<p align="center"> 
  <img src="https://i.imgur.com/p6zfou9.png"> 
</p> 

Alfred can install the most common applications and packages for you, while you
take a nap or walk the dog. Just tell Alfred what you want him to do for you and
he will take care of it in no time. This is perfect for Linux beginners and lazy
users like me, specially for those times when you have just installed the system.

![Imgur](http://i.imgur.com/YMDG3B2.png)

## Python script usage

1. Open a terminal, paste the line below and then press enter. You will have to type your password.
    ```bash
    wget https://raw.githubusercontent.com/derkomai/alfred/master/alfred.py && python3 alfred.py

    ```

## Bash script usage (now obsolete and discontinued)

### The graphical, beginner-friendly way

1. Download Alfred in [this link](https://raw.githubusercontent.com/derkomai/alfred/master/alfred.sh): right click on the link, select *save link as* and click OK, ensuring that the file name is just *alfred.sh* without any other extensions.
2. Open your downloads folder. You should see a file named *alfred.sh*.
3. Right click *alfred.sh* file, select *Properties* and open the tab named *Permissions* in the dialog.
4. Now, depending on your system, you should see something like *Allow executing file as a program* or a table where you can give *Execution* permissions for the file owner. Ensure this is activated and click OK.
5. If you are using Ubuntu or at least the Nautilus file browser, ensure that **Edit > Preferences > Behaviour > Executable text files > Run executable text files when they are opened** option is activated.
6. Open *alfred.sh* by clicking on it.
7. You will be asked for your password. Type it and click OK.
8. Select the tasks you want to perform and click OK. Wait for them to complete. That's it.

### The easy command line way

1. Open a terminal, paste the line below and then press enter. You will have to type your password.
    ```bash
    sudo apt -y install git && git clone https://github.com/derkomai/alfred && sudo ./alfred/alfred.sh

    ```

## Donation

If you find Alfred useful and it has saved you some time or trouble, you can support it by making a small donation through Paypal or cryptocurrencies.

- *Paypal:* [![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.me/dvilela)

- *Bitcoin address:* 3F888TKJvWvkRmGVDyeCFAoBbFnLoYsrYP

- *Bitcoin Cash address:* 1LfY7Mjh3z11ek1A2exKm3JdXw8VheNHdU

- *Ethereum/ERC20 address:* 0x0Ddc94917100387909cb6141c2e7e453bd31D3f7

- *Litecoin address:* MVXhiKnsMTiZYWfzdQ9BdJT8wDpSNrBme1

- *XRP address:* rFeeJw6rsoeSmu9BAL12gHSaMwtvFQgif

- *Stellar address:* GBON6KJYAQMRYTMEOSZQI22MOGZK7FWKDLAIWXRLZSG2XEZ6RG73PUGT

- *Neo address:* AGehUh61V2mjmhwsk3sGus5hEVYQZxexZa