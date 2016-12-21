# Alfred
A bash script to install all your favourite applications and perform the most 
common tasks automatically in Ubuntu and derivatives.


<p align="center">
  <img src="http://i.imgur.com/vg3T4ul.png">
</p>


Alfred can install the most common applications and packages for you, while you 
take a nap or walk the dog. Just tell Alfred what you want him to do for you and
he will take care of it in no time. This is perfect for Linux beginners and lazy
users like me, specially for those times when you have just installed the system. 


![Imgur](http://i.imgur.com/YMDG3B2.png)



## Usage

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

1. Open a terminal and paste the line below, enter your password when asked for it and then press enter:
    ```
    sudo apt install git && git clone https://github.com/derkomai/alfred && sudo ./alfred/alfred.sh

    ```


## Donation
If you find Alfred useful and it has saved you some time or trouble, you can buy me a cup of coffee by making a small donation.


[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.me/dvilela)
