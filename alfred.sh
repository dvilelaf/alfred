#!/bin/bash

# DISCLAIMER
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# TASK LIST ###################################################################
#------------------------------------------------------------------------------
taskNames=("Update system")
taskMessages=("Updating system")
taskDescriptions=("Update system packages to its latest version")
taskRecipes=("updateSystem")
taskDefaults=("TRUE")

updateSystem()
{
  apt-get update
  apt-get -y upgrade
}
#------------------------------------------------------------------------------
taskNames+=("Install drivers")                 
taskMessages+=("Installing drivers")           
taskDescriptions+=("Install drivers that are appropriate for automatic installation")   
taskRecipes+=("autoInstallDrivers")   
taskDefaults+=("FALSE") 

autoInstallDrivers()
{
  ubuntu-drivers autoinstall 
}
#------------------------------------------------------------------------------
taskNames+=("Install Java, Flash and codecs")                 
taskMessages+=("Installing Java, Flash and codecs")           
taskDescriptions+=("Install non-open-source packages like Java, Flash plugin, Unrar, and some audio and video codecs like MP3/AVI/MPEG")   
taskRecipes+=("installRestrictedExtras")   
taskDefaults+=("FALSE") 

installRestrictedExtras()
{
  apt-get install ubuntu-restricted-extras
}
#------------------------------------------------------------------------------
taskNames+=("Install Chrome")                 
taskMessages+=("Installing Chrome")           
taskDescriptions+=("The web browser from Google")   
taskRecipes+=("installChrome")   
taskDefaults+=("FALSE") 

installChrome()
{
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
  sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
  apt-get update 
  apt-get install google-chrome-stable
}
#------------------------------------------------------------------------------
taskNames+=("Install Firefox")                 
taskMessages+=("Installing Firefox")           
taskDescriptions+=("The web browser from Mozilla")   
taskRecipes+=("installFirefox")   
taskDefaults+=("FALSE") 

installFirefox()
{
  addRepository "ppa:ubuntu-mozilla-security/ppa"
  apt-get install firefox firefox-locale-$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
}
#------------------------------------------------------------------------------
taskNames+=("Install Opera")                 
taskMessages+=("Installing Opera")           
taskDescriptions+=("Just another web browser")   
taskRecipes+=("installOpera")   
taskDefaults+=("FALSE") 

installOpera()
{
  wget -O - http://deb.opera.com/archive.key | apt-key add -
  sh -c 'echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list'
  apt-get update 
  apt-get install opera
}
#------------------------------------------------------------------------------
taskNames+=("Install Transmission")                 
taskMessages+=("Installing Transmission")           
taskDescriptions+=("A light bittorrent download client")   
taskRecipes+=("installTransmission")   
taskDefaults+=("FALSE") 

installTransmission()
{
  addRepository "ppa:transmissionbt/ppa"
  apt-get install transmission-gtk
}
#------------------------------------------------------------------------------
taskNames+=("Install Dropbox")                 
taskMessages+=("Installing Dropbox")           
taskDescriptions+=("A cloud hosting service to store your files online")   
taskRecipes+=("installDropbox")   
taskDefaults+=("FALSE") 

installDropbox()
{
  # Handle elementary OS with wingpanel support
  if [[ $OSname == "elementary" ]]; then
    apt-get -y install git
    apt-get --purge remove -y dropbox*
    apt-get -y install python-gpgme	
    git clone https://github.com/zant95/elementary-dropbox /tmp/elementary-dropbox
    bash /tmp/elementary-dropbox/install.sh
  else
    if [[ $OSarch == "x86_64" ]]; then
        wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    else
        wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
    fi

    /.dropbox-dist/dropboxd
  fi
}
#------------------------------------------------------------------------------
taskNames+=("Install VirtualBox")                 
taskMessages+=("Installing VirtualBox")           
taskDescriptions+=("A virtualization software to run other OSes on top of your current OS")   
taskRecipes+=("installVirtualBox")   
taskDefaults+=("FALSE") 

installVirtualBox()
{
  apt-get remove virtualbox virtualbox-5.0 virtualbox-4.*
  
  sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $OSbaseCodeName contrib" >> /etc/apt/sources.list.d/virtualbox.list'
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
  apt-get update
  apt-get install -y virtualbox-5.1

  wget -O /tmp/extensionPack.vbox-extpack http://download.virtualbox.org/virtualbox/5.1.10/Oracle_VM_VirtualBox_Extension_Pack-5.1.10-112026.vbox-extpack
  VBoxManage extpack install /tmp/extensionPack.vbox-extpack
}
#------------------------------------------------------------------------------
taskNames+=("Install Skype")                 
taskMessages+=("Installing Skype")           
taskDescriptions+=("A videocall software from Microsoft")   
taskRecipes+=("installSkype")   
taskDefaults+=("FALSE") 

installSkype()
{
  dpkg --add-architecture i386
  add-apt-repository "deb http://archive.canonical.com/ $OSbaseCodeName partner"
  apt-get update
  apt-get install -y skype pulseaudio:i386
}
#------------------------------------------------------------------------------
taskNames+=("Install Thunderbird")                 
taskMessages+=("Installing Thunderbird")           
taskDescriptions+=("A mail client from Mozilla")   
taskRecipes+=("installThunderbird")   
taskDefaults+=("FALSE") 

installThunderbird()
{
  apt-get install -y thunderbird
}
#------------------------------------------------------------------------------
taskNames+=("Install Telegram")                 
taskMessages+=("Installing Telegram")           
taskDescriptions+=("A chat client, similar to Whatsapp, Viber, Facebook Messenger or Google Hangouts")   
taskRecipes+=("installTelegram")   
taskDefaults+=("FALSE") 

installTelegram()
{
  if [[ $OSarch == "x86_64" ]]; then
    wget -O - https://tdesktop.com/linux > /tmp/telegram.tar.gz
  else
    wget -O - https://tdesktop.com/linux32 > /tmp/telegram.tar.gz
  fi

  tar -xzvf /tmp/telegram.tar.gz -C /opt

  chmod +x /opt/Telegram/telegram
  sudo chown -R $SUDO_USER:$SUDO_USER /opt/Telegram/

  wget -o /opt/Telegram/icon.png https://desktop.telegram.org/img/td_logo.png

  desktopFile="/home/$SUDO_USER/.local/share/applications/telegram.desktop"

  echo "[Desktop Entry]" > $desktopFile
  echo "Name=Telegram" >> $desktopFile
  echo "GenericName=Chat" >> $desktopFile
  echo "Comment=Chat with yours friends" >> $desktopFile
  echo "Exec=/opt/Telegram/telegram" >> $desktopFile
  echo "Terminal=false" >> $desktopFile
  echo "Type=Application" >> $desktopFile
  echo "Icon=/opt/Telegram/icon.png" >> $desktopFile
  echo "Categories=Network;Chat;" >> $desktopFile
  echo "StartupNotify=false" >> $desktopFile
}
#------------------------------------------------------------------------------
taskNames+=("Install Slack")                 
taskMessages+=("Installing Slack")           
taskDescriptions+=("A team communication application")   
taskRecipes+=("installSlack")   
taskDefaults+=("FALSE") 

installSlack()
{
  installPackage "https://downloads.slack-edge.com/linux_releases/slack-desktop-2.3.3-amd64.deb"
}
#------------------------------------------------------------------------------
taskNames+=("Install VLC")                 
taskMessages+=("Installing VLC")           
taskDescriptions+=("The most famous multimedia player")   
taskRecipes+=("installVLC")   
taskDefaults+=("FALSE") 

installVLC()
{
  addRepository "ppa:videolan/stable-daily"
  apt-get -y install vlc
}
#------------------------------------------------------------------------------
taskNames+=("Install Kazam")                 
taskMessages+=("Installing Kazam")           
taskDescriptions+=("A tool to record your screen and take screenshots")   
taskRecipes+=("installKazam")   
taskDefaults+=("FALSE") 

installKazam()
{
  apt-get -y install kazam
}
#------------------------------------------------------------------------------
taskNames+=("Install Spotify")
taskMessages+=("Installing Spotify...")
taskDescriptions+=("One of the best music streaming apps")
taskRecipes+=("installSpotify")
taskDefaults+=("FALSE")

installSpotify()
{
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
	echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
  apt-get update
  apt-get install -y spotify-client
}
#------------------------------------------------------------------------------
taskNames+=("Install Audacity")                 
taskMessages+=("Installing Audacity")           
taskDescriptions+=("Record and edit audio files")   
taskRecipes+=("installAudacity")   
taskDefaults+=("FALSE") 

installAudacity()
{
  apt-get -y install audacity
}
#------------------------------------------------------------------------------
taskNames+=("Install Soundconverter")                 
taskMessages+=("Installing Soundconverter")           
taskDescriptions+=("Audio file converter")   
taskRecipes+=("installSoundconverter")   
taskDefaults+=("FALSE") 

installSoundconverter()
{
  apt-get -y install soundconverter
}
#------------------------------------------------------------------------------
taskNames+=("Install Mixxx")                 
taskMessages+=("Installing Mixxx")           
taskDescriptions+=("A MP3 DJ mixing software")   
taskRecipes+=("installMixxx")   
taskDefaults+=("FALSE") 

installMixxx()
{
  addRepository "ppa:mixxx/mixxx"
  apt-get -y install mixxx
}
#------------------------------------------------------------------------------
taskNames+=("Install LMMS")                 
taskMessages+=("Installing LMMS")           
taskDescriptions+=("Music production for everyone: loops, synthesizers, mixer...")   
taskRecipes+=("installLMMS")   
taskDefaults+=("FALSE") 

installLMMS()
{
  apt-get -y lmms 
}
#------------------------------------------------------------------------------
taskNames+=("Install Gimp")                 
taskMessages+=("Installing Gimp")           
taskDescriptions+=("Gimp is an image editor")   
taskRecipes+=("installGimp")   
taskDefaults+=("FALSE") 

installGimp()
{
  apt-get -y install gimp
}
#------------------------------------------------------------------------------
taskNames+=("Install Inkscape")                 
taskMessages+=("Installing Inkscape")           
taskDescriptions+=("Create and edit scalable vectorial images")   
taskRecipes+=("installInkscape")   
taskDefaults+=("FALSE") 

installInkscape()
{
  apt-get -y install inkscape
}
#------------------------------------------------------------------------------
taskNames+=("Install Blender")                 
taskMessages+=("Installing Blender")           
taskDescriptions+=("3D modelling, animation, rendering and production")   
taskRecipes+=("installBlender")   
taskDefaults+=("FALSE") 

installBlender()
{
  addRepository "ppa:thomas-schiex/blender"
  apt-get -y install blender
}
#------------------------------------------------------------------------------
taskNames+=("Install LeoCad")                 
taskMessages+=("Installing LeoCad")           
taskDescriptions+=("Virtual LEGO CAD software")   
taskRecipes+=("installLeoCad")   
taskDefaults+=("FALSE") 

installLeoCad()
{
  apt-get -y install unzip

  wget -O /tmp/ldraw.zip http://www.ldraw.org/library/updates/complete.zip
  unzip /tmp/ldraw.zip -d /home/$SUDO_USER

  apt-get -y install leocad
}
#------------------------------------------------------------------------------
taskNames+=("Install Paraview")                 
taskMessages+=("Installing Paraview")           
taskDescriptions+=("An application for interactive, scientific visualization")   
taskRecipes+=("installParaview")   
taskDefaults+=("FALSE") 

installParaview()
{
  if [[ $OSarch != "x86_64" ]]; then
    (>&2 echo "Your system is not supported by Paraview")
    return
  fi

  wget -O /tmp/paraview.tar.gz "http://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.2&type=binary&os=linux64&downloadFile=ParaView-5.2.0-Qt4-OpenGL2-MPI-Linux-64bit.tar.gz"
  tar xzf /tmp/paraview.tar.gz -C /tmp

  mv ParaView-5.2.0-Qt4-OpenGL2-MPI-Linux-64bit /opt/paraview

  desktopFile="/usr/share/applications/paraview.desktop"

  echo "[Desktop Entry]" > $desktopFile
  echo "Name=Paraview" >> $desktopFile
  echo "GenericName=Data visualizer" >> $desktopFile
  echo "Exec=/opt/paraview/bin/paraview" >> $desktopFile
  echo "Terminal=false" >> $desktopFile
  echo "Type=Application" >> $desktopFile
  echo "Icon=/opt/paraview/share/icons/hicolor/96x96/apps/paraview.png" >> $desktopFile
  echo "Categories=Graphics;" >> $desktopFile
  echo "StartupNotify=false" >> $desktopFile
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice suite")                 
taskMessages+=("Installing LibreOffice")           
taskDescriptions+=("A complete office suite: word processor, spreadsheets, slideshows, diagrams, drawings, databases and equations")   
taskRecipes+=("installLibreOffice")   
taskDefaults+=("FALSE") 

installLibreOffice()
{
  apt-get -y install libreoffice
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Writer")                 
taskMessages+=("Installing LibreOffice Writer")           
taskDescriptions+=("Install just the LibreOffice word processor")   
taskRecipes+=("installLibreOfficeWriter")   
taskDefaults+=("FALSE") 

installLibreOfficeWriter()
{
  apt-get -y install libreoffice-writer
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Spreadsheet")                 
taskMessages+=("Installing LibreOffice Spreadsheet")           
taskDescriptions+=("Install just the LibreOffice spreadsheet editor")   
taskRecipes+=("installLibreOfficeSpreadsheet")   
taskDefaults+=("FALSE") 

installLibreOfficeSpreadsheet()
{
  apt-get -y install libreoffice-calc
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Draw")                 
taskMessages+=("Installing LibreOffice Draw")           
taskDescriptions+=("Install just the LibreOffice drawing editor")   
taskRecipes+=("installLibreOfficeDraw")   
taskDefaults+=("FALSE") 

installLibreOfficeDraw()
{
  apt-get -y install libreoffice-draw
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Base")                 
taskMessages+=("Installing LibreOffice Base")           
taskDescriptions+=("Install just the LibreOffice database manager")   
taskRecipes+=("installLibreOfficeBase")   
taskDefaults+=("FALSE") 

installLibreOfficeBase()
{
  apt-get -y install libreoffice-base
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Math")                 
taskMessages+=("Installing LibreOffice Math")           
taskDescriptions+=("Install just the LibreOffice equation editor")   
taskRecipes+=("installLibreOfficeMath")   
taskDefaults+=("FALSE") 

installLibreOfficeMath()
{
  apt-get -y install libreoffice-math
}
#------------------------------------------------------------------------------
taskNames+=("Install Evince")                 
taskMessages+=("Installing Evince")           
taskDescriptions+=("A document viewer with support for PDF, Postscript, djvu, tiff, dvi, XPS and SyncTex")   
taskRecipes+=("installEvince")   
taskDefaults+=("FALSE") 

installEvince()
{
  apt-get -y install evince
}
#------------------------------------------------------------------------------
taskNames+=("Install Master PDF Editor")                 
taskMessages+=("Installing Master PDF Editor")           
taskDescriptions+=("A convenient and smart PDF editor for Linux")   
taskRecipes+=("installMasterPDF")   
taskDefaults+=("FALSE") 

installMasterPDF()
{
  if [[ $OSarch == "x86_64" ]]; then
    installPackage "http://get.code-industry.net/public/master-pdf-editor-3.7.10_amd64.deb"
  else
    installPackage "http://get.code-industry.net/public/master-pdf-editor-3.7.10_i386.deb"
  fi
}
#------------------------------------------------------------------------------
taskNames+=("Install Jabref")                 
taskMessages+=("Installing Jabref")           
taskDescriptions+=("A graphical editor for bibtex libraries")   
taskRecipes+=("installJabref")   
taskDefaults+=("FALSE") 

installJabref()
{
  apt-get -y install jabref
}
#------------------------------------------------------------------------------
taskNames+=("Install Zotero")                 
taskMessages+=("Installing Zotero")           
taskDescriptions+=("A reference management software to manage bibliographic data and related research materials")   
taskRecipes+=("installZotero")   
taskDefaults+=("FALSE") 

installZotero()
{
  if [[ $OSarch == "x86_64" ]]; then
    arch="x86_64"
  else
    arch="i686"
  fi

  wget -O /tmp/zotero.tar.bz2 "https://download.zotero.org/standalone/4.0.29.10/Zotero-4.0.29.10_linux-$arch.tar.bz2"

  tar xjf /tmp/zotero.tar.bz2 -C /tmp
  mv "/tmp/Zotero_linux-$arch" /opt/zotero

  wget -o /opt/zotero/icon.png http://icons.iconarchive.com/icons/blackvariant/button-ui-requests-5/1024/Zotero-icon.png

  desktopFile="/usr/share/applications/zotero.desktop"

  echo "[Desktop Entry]" > $desktopFile
  echo "Name=Zotero" >> $desktopFile
  echo "GenericName=Reference manager" >> $desktopFile
  echo "Exec=/opt/zotero/run-zotero.sh" >> $desktopFile
  echo "Terminal=false" >> $desktopFile
  echo "Type=Application" >> $desktopFile
  echo "Icon=/opt/zotero/zotero.png" >> $desktopFile
  echo "Categories=Office;" >> $desktopFile
  echo "StartupNotify=false" >> $desktopFile
}
#------------------------------------------------------------------------------
taskNames+=("Install TexMaker")                 
taskMessages+=("Installing TexMaker")           
taskDescriptions+=("A LateX development environment")   
taskRecipes+=("installTexMaker")   
taskDefaults+=("FALSE") 

installTexMaker()
{
  apt-get -y install texmaker
}
#------------------------------------------------------------------------------
taskNames+=("Install Calibre")                 
taskMessages+=("Installing Calibre")           
taskDescriptions+=("eBook management application")   
taskRecipes+=("installCalibre")   
taskDefaults+=("FALSE") 

installCalibre()
{
  wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | 
  python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
}
#------------------------------------------------------------------------------
taskNames+=("Install DiffPdf")                 
taskMessages+=("Installing DiffPdf")           
taskDescriptions+=("Tool to compare PDF files")   
taskRecipes+=("installDiffPdf")   
taskDefaults+=("FALSE") 

installDiffPdf()
{
  apt-get install diffpdf
}
#------------------------------------------------------------------------------
taskNames+=("Install Steam")                 
taskMessages+=("Installing Steam")           
taskDescriptions+=("A game digital distribution platform developed by Valve")   
taskRecipes+=("installSteam")   
taskDefaults+=("FALSE") 

installSteam()
{
  wget -O /tmp/steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
  dpkg -i /tmp/steam.deb
}
#------------------------------------------------------------------------------
taskNames+=("Install 0 A.D.")                 
taskMessages+=("Installing 0 A.D.")           
taskDescriptions+=("0 A.D. is a game of ancient warfare, similar to Age of Empires")   
taskRecipes+=("install0AD")   
taskDefaults+=("FALSE") 

install0AD()
{
  apt-get -y install 0ad
}
#------------------------------------------------------------------------------
taskNames+=("Install ScummVM")                 
taskMessages+=("Installing ScummVM")           
taskDescriptions+=("Loader for Scumm games")   
taskRecipes+=("installScummVM")   
taskDefaults+=("FALSE") 

installScummVM()
{
  if [[ $OScodeName != "xenial" ]] && [[ $OScodeName != "yakkety" ]]; then
    (>&2 echo "Your system is not supported by ScummVM")
    return
  fi

  if [[ $OSarch == "x86_64" ]]; then
    arch="amd64"
  else
    arch="i386"
  fi

  installPackage "https://www.scummvm.org/frs/scummvm/1.9.0/scummvm_1.9.0-$OScodeName.1_$arch.deb"
}
#------------------------------------------------------------------------------
taskNames+=("Install Disk utility")                 
taskMessages+=("Installing Disk utility")           
taskDescriptions+=("A tool to manage your drives")   
taskRecipes+=("installDiskUtility")   
taskDefaults+=("FALSE") 

installDiskUtility()
{
  apt-get -y install gnome-disk-utility
}
#------------------------------------------------------------------------------
taskNames+=("Install GParted")                 
taskMessages+=("Installing GParted")           
taskDescriptions+=("A tool to make partitions in your hard drives")   
taskRecipes+=("installGParted")   
taskDefaults+=("FALSE") 

installGParted()
{
  apt-get -y install gparted
}
#------------------------------------------------------------------------------
taskNames+=("Install MenuLibre")                 
taskMessages+=("Installing MenuLibre")           
taskDescriptions+=("Add or remove applications from your menu")   
taskRecipes+=("installMenuLibre")   
taskDefaults+=("FALSE") 

installMenuLibre()
{
  apt-get -y install menulibre
}
#------------------------------------------------------------------------------
taskNames+=("Install Seahorse")                 
taskMessages+=("Installing Seahorse")           
taskDescriptions+=("Manage your passwords")   
taskRecipes+=("installSeahorse")   
taskDefaults+=("FALSE") 

installSeahorse()
{
  apt-get -y install seahorse
}
#------------------------------------------------------------------------------
taskNames+=("Install Duplicity")                 
taskMessages+=("Installing Duplicity")           
taskDescriptions+=("Keep your files safe by making automatic backups")   
taskRecipes+=("installDuplicity")   
taskDefaults+=("FALSE") 

installDuplicity()
{
  apt-get -y install duplicity
}
#------------------------------------------------------------------------------
taskNames+=("Install UNetbootin")                 
taskMessages+=("Installing UNetbootin")           
taskDescriptions+=("Tool for creating Live USB drives")   
taskRecipes+=("installUNetbootin")   
taskDefaults+=("FALSE") 

installUNetbootin()
{
  apt-get -y install unetbootin
}
#------------------------------------------------------------------------------
taskNames+=("Install EncFS")                 
taskMessages+=("Installing EncFS")           
taskDescriptions+=("Create and manage encrypted folders to keep your files safe")   
taskRecipes+=("installEncFS")   
taskDefaults+=("FALSE") 

installEncFS()
{
  addRepository "ppa:gencfsm" 
  apt-get -y install gnome-encfs-manager
}
#------------------------------------------------------------------------------
taskNames+=("Install FileZilla")                 
taskMessages+=("Installing FileZilla")           
taskDescriptions+=("Download and upload files via FTP, FTPS and SFTP")   
taskRecipes+=("installFileZilla")   
taskDefaults+=("FALSE") 

installFileZilla()
{
  apt-get -y install filezilla
}
#------------------------------------------------------------------------------
taskNames+=("Install utilities bundle")                 
taskMessages+=("Installing utilities bundle")           
taskDescriptions+=("Java, zip and rar tools")   
taskRecipes+=("installUtilities")   
taskDefaults+=("FALSE") 

installUtilities()
{
  apt-get -y install icedtea-7-plugin openjdk-8-jre p7zip rar
}
#------------------------------------------------------------------------------
taskNames+=("Install developer bundle")                 
taskMessages+=("Installing developer bundle")           
taskDescriptions+=("Tools for developers: build-essential, cmake, git, java, python, octave and other tools")   
taskRecipes+=("installDevBundle")   
taskDefaults+=("FALSE") 

installDevBundle()
{
  apt-get -y install build-essential cmake cmake-gui cmake-curses-gui python python3 \
             octave gfortran git kdiff3 kdesvn colordiff openjdk-8-jdk
}
#------------------------------------------------------------------------------
taskNames+=("Install Swift")                 
taskMessages+=("Installing Swift")           
taskDescriptions+=("A compiler and interpreter for Apple's programming language")   
taskRecipes+=("installSwift")   
taskDefaults+=("FALSE") 

installSwift()
{
  apt-get -y install clang libicu-dev

  if [[ %OSbaseCodeName == "xenial" ]]; then
    wget -O /tmp/swift.tar.gz https://swift.org/builds/swift-3.0.2-release/ubuntu1604/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu16.04.tar.gz
    wget -O /tmp/swift.tar.gz.sig https://swift.org/builds/swift-3.0.2-release/ubuntu1604/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu16.04.tar.gz.sig
  elif [[ %OSbaseCodeName == "trusty" ]]; then
    wget -O /tmp/swift.tar.gz https://swift.org/builds/swift-3.0.2-release/ubuntu1404/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu14.04.tar.gz
    wget -O /tmp/swift.tar.gz.sig https://swift.org/builds/swift-3.0.2-release/ubuntu1404/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu14.04.tar.gz.sig
  else
    (>&2 echo "Your system is not supported by swift")
    return
  fi

  wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -
  gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift
  gpg --verify /tmp/swift.tar.gz.sig

  tar xzf /tmp/swift.tar.gz -C /tmp/swift
  mv /tmp/swift-3.0.2-RELEASE-ubuntu16.04 /opt/swift
  export PATH=/opt/swift/usr/bin:"${PATH}"
}
#------------------------------------------------------------------------------
taskNames+=("Install Eclipse")                 
taskMessages+=("Installing Eclipse")           
taskDescriptions+=("A multilanguage IDE for developers")   
taskRecipes+=("installEclipse")   
taskDefaults+=("FALSE") 

installEclipse()
{
  wget -O /tmp/eclipse.tar.gz http://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/oomph/epp/neon/R1/eclipse-inst-linux64.tar.gz
  tar xzf /tmp/eclipse.tar.gz -C /tmp
  /tmp/eclipse-installer/eclipse-inst
}
#------------------------------------------------------------------------------
taskNames+=("Install CodeLite")                 
taskMessages+=("Installing CodeLite")           
taskDescriptions+=("A C/C++, PHP and JavaScript IDE for developers")   
taskRecipes+=("installCodeLite")   
taskDefaults+=("FALSE") 

installCodeLite()
{
  apt-key adv --fetch-keys https://repos.codelite.org/CodeLite.asc
  addRepository "deb https://repos.codelite.org/ubuntu/ $OSbaseCodeName universe"
  apt-get install codelite wxcrafter
}
#------------------------------------------------------------------------------
taskNames+=("Install Visual Studio Code")                 
taskMessages+=("Installing Visual Studio Code")           
taskDescriptions+=("A source code editor developed by Microsoft")   
taskRecipes+=("installVSCode")   
taskDefaults+=("FALSE") 

installVSCode()
{
  installPackage "https://az764295.vo.msecnd.net/stable/38746938a4ab94f2f57d9e1309c51fd6fb37553d/code_1.8.0-1481651903_amd64.deb"
}
#------------------------------------------------------------------------------
taskNames+=("Install Atom")                 
taskMessages+=("Installing Atom")           
taskDescriptions+=("A hackable text editor")   
taskRecipes+=("installAtom")   
taskDefaults+=("FALSE") 

installAtom()
{
  addRepository "ppa:webupd8team/atom"
  apt-get -y install atom
}
#------------------------------------------------------------------------------
taskNames+=("Install Arduino")                 
taskMessages+=("Installing Arduino")           
taskDescriptions+=("The official IDE for the Arduino board")   
taskRecipes+=("installArduino")   
taskDefaults+=("FALSE") 

installArduino()
{
  if [[ $OSarch == "x86_64" ]]; then
    wget -O /tmp/arduino.tar.xz https://downloads.arduino.cc/arduino-1.6.13-linux64.tar.xz
  else
    wget -O /tmp/arduino.tar.xz https://downloads.arduino.cc/arduino-1.6.13-linux32.tar.xz
  fi

  tar xf /tmp/arduino.tar.xz -C /tmp
  mv /tmp/arduino-1.6.13/ /opt/arduino
  /opt/arduino/install.sh
}
#------------------------------------------------------------------------------
taskNames+=("Install Mu")                 
taskMessages+=("Installing Mu")           
taskDescriptions+=("A code editor for beginner programmers")   
taskRecipes+=("installMu")   
taskDefaults+=("FALSE") 

installMu()
{
  mkdir /opt/mu
  wget -O /opt/mu/mu.bin https://github.com/mu-editor/mu/releases/download/v0.9.13/mu-0.9.13.linux.bin
  chmod +x /opt/mu/mu.bin
  adduser $SUDO_USER dialout

  wget -O /opt/mu/icon.png http://www.unixstickers.com/image/data/stickers/python/python.sh.png

  desktopFile="/home/$SUDO_USER/.local/share/applications/mu.desktop"

  echo "[Desktop Entry]" > $desktopFile
  echo "Name=Mu editor" >> $desktopFile
  echo "GenericName=IDE" >> $desktopFile
  echo "Comment=IDE for beginners" >> $desktopFile
  echo "Exec=/opt/mu/mu.bin" >> $desktopFile
  echo "Terminal=false" >> $desktopFile
  echo "Type=Application" >> $desktopFile
  echo "Icon=/opt/mu/mu.png" >> $desktopFile
  echo "Categories=Development;IDE;" >> $desktopFile
  echo "StartupNotify=false" >> $desktopFile
}
#------------------------------------------------------------------------------
taskNames+=("Install GitKraken")                 
taskMessages+=("Installing GitKraken")           
taskDescriptions+=("A graphical git client from Axosoft")   
taskRecipes+=("installGitKraken")   
taskDefaults+=("FALSE") 

installGitKraken()
{
  installPackage "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
}
#------------------------------------------------------------------------------
taskNames+=("Install SmartGit")                 
taskMessages+=("Installing SmartGit")           
taskDescriptions+=("A graphical git client from Syntevo")   
taskRecipes+=("installSmartGit")   
taskDefaults+=("FALSE") 

installSmartGit()
{
  apt-get -y install icedtea-7-plugin openjdk-8-jre

  wget -O /tmp/smartgit.tar.gz http://www.syntevo.com/static/smart/download/smartgit/smartgit-linux-8_0_3.tar.gz
  tar xzf /tmp/smartgit.tar.gz -C /tmp
  mv /tmp/smartgit/ /opt/smartgit

  /opt/smartgit/bin/add-menuitem.sh
}
#------------------------------------------------------------------------------
taskNames+=("Install SysAdmin bundle")                 
taskMessages+=("Installing SysAdmin bundle")           
taskDescriptions+=("Tools for sysadmins: tmux, cron, screen, ncdu, htop, aptitude, apache, etckeeper and xpra")   
taskRecipes+=("installSysAdminBundle")   
taskDefaults+=("FALSE") 

installSysAdminBundle()
{
  apt-get -y install tmux cron screen ncdu htop aptitude apache2 etckeeper xpra
}
#------------------------------------------------------------------------------
taskNames+=("Install Jaxx")                 
taskMessages+=("Installing Jaxx")           
taskDescriptions+=("A blockchain wallet")   
taskRecipes+=("installJaxx")   
taskDefaults+=("FALSE") 

installJaxx()
{
  wget -O /tmp/jaxx.tar.gz https://jaxx.io/files/1.1.7/Jaxx-v1.1.7-linux-x64.tar.gz
  tar -zxf /tmp/jaxx.tar.gz -C /tmp
  mv /tmp/Jaxx-v1.1.7_linux-x64 /opt/jaxx

  wget -O /opt/jaxx/icon.png https://jaxx.io/images/mark.png

  desktopFile="/usr/local/share/applications/jaxx.desktop"

  echo "[Desktop Entry]" > $desktopFile
  echo "Name=Jaxx" >> $desktopFile
  echo "GenericName=Blockchain wallet" >> $desktopFile
  echo "Comment=Manager your blockchain currencies" >> $desktopFile
  echo "Exec=/opt/jaxx/jaxx-assets/Jaxx" >> $desktopFile
  echo "Terminal=false" >> $desktopFile
  echo "Type=Application" >> $desktopFile
  echo "Icon=/opt/jaxx/icon.png" >> $desktopFile
  echo "Categories=Network;" >> $desktopFile
  echo "StartupNotify=false" >> $desktopFile
}
#------------------------------------------------------------------------------
#taskNames+=("Install rEFInd")                  
#taskMessages+=("Installing rEFInd")            
#taskDescriptions+=("An EFI boot manager")    
#taskRecipes+=("installrEFInd")    
#taskDefaults+=("FALSE")  
 
#installrEFInd() 
# { 
#  addRepository "ppa:rodsmith/refind" 
#  apt-get -y install refind 
#  refind-install --shim /boot/efi/EFI/ubuntu/shimx64.efi --localkeys 
#  refind-mkdefault 
#} 
#------------------------------------------------------------------------------ 
# To add a new task, add a new section above this block copying and pasting the following 5 lines:

# taskNames+=("<Task Name>")                 
# taskMessages+=("<Task message>")           
# taskDescriptions+=("<Task description>")   
# taskRecipes+=("<Task recipe function>")   
# taskDefaults+=("Task boolean value") 

# Then, uncomment them and:         

# Replace <Task Name> with the new task's name.
# Replace <Task message> with the message that will be displayed while.
# performing the task, i.e. "Upgrading the system" .
# Replace <Task description> with the new task's description.
# Replace <Task recipe function> with the function name which will contain .
# the necessary commands to perform the task and write that function. Do NOT use sudo in it.
# Replace <Task boolean value> with TRUE of FALSE to make this task to be marked by default.
#------------------------------------------------------------------------------
# Let this task be the last
taskNames+=("Remove no longer needed packages")
taskMessages+=("Removing no longer needed packages")
taskDescriptions+=("Clean the system by removing packages that were installed by other packages and are no longer needed")
taskRecipes+=("autoRemove")
taskDefaults+=("TRUE")

autoRemove()
{
  apt-get -y autoremove
}
#------------------------------------------------------------------------------
# END OF TASK LIST ############################################################


# Main function
main()
{
  # Get system info
  OSarch=$(uname -m)
  OSname=$(lsb_release -si)
  OSversion=$(lsb_release -sr)
  OScodeName=$(lsb_release -sc)
  OSbaseCodeName=$OScodeName

  # Ubuntu derivatives equivalence for repositories
  if [ $OSname == "elementary" ]; then
    if [ $OScodeName == "luna" ]; then
      OSbaseCodeName="precise"
    elif [ $OScodeName == "freya" ]; then
      OSbaseCodeName="trusty"
    elif [ $OScodeName == "loki" ]; then
      OSbaseCodeName="xenial"
    fi
  fi

  if [ $OSname == "LinuxMint" ]; then
    if [ $OScodeName == "maya" ]; then
      OSbaseCodeName="precise"
    elif [ $OScodeName == "petra" ]; then
      OSbaseCodeName="saucy"
    elif [ $OScodeName == "quiana" ]  || [ $OScodeName == "rebecca" ] || \
         [ $OScodeName == "rafaela" ] || [ $OScodeName == "rosa" ]; then
      OSbaseCodeName="trusty"
    elif [ $OScodeName == "sarah" ]; then
      OSbaseCodeName="xenial"
    fi
  fi

  # Check if Zenity package is installed
  if [[ ! $(which zenity) ]]; then
    installPackage "zenity"
  fi

  # Build task table for Zenity
  taskTable=()  

  for (( i=0; i<${#taskNames[@]}; i++ )); do
      taskTable+=("${taskDefaults[$i]}" "${taskNames[$i]}" "${taskDescriptions[$i]}")
  done

  # Create selection GUI with Zenity
  while true; do

    tasks=$(zenity --list --checklist \
      --height 500 \
      --width 1000 \
      --title="Alfred" \
      --text "Select tasks to perform:" \
      --column=Selection \
      --column=Task \
      --column=Description \
      "${taskTable[@]}" \
      --separator=', '
    )

    # Check for closed window / cancel button
    if [[ $? == 1 ]]; then
      if zenity --question --title="Alfred" --text "Are you sure you want to exit?"; then
        exit 0
      else
        continue
      fi
    fi

    # Check zero tasks selected
    if [ -z "$tasks" ]; then
      zenity --info --title="Alfred" --text "No tasks were selected"
      continue
    fi

    # Warning message and confirmation
    message="The selected tasks will be performed now. "
    message+="You won't be able to cancel this operation once started.\n"
    message+="Are you sure you want to continue?"

    if zenity --question --title="Alfred" --text "$message"; then
      break
    fi

  done

  # Write error log file header
  ErrorLog="/tmp/alfredErrorLog"
  timestamp="$(date)"

  headerSeparator="-------------------------------------------------"
  headerSeparator+=$headerSeparator

  echo $headerSeparator >> $ErrorLog
  echo "NEW SESSION "$timestamp >> $ErrorLog
  echo $(lsb_release -d | cut -d: -f2 | sed "s/^[ \t]*//")  >> $ErrorLog
  echo $(uname -a)  >> $ErrorLog

  # Perform all tasks and show progress in a progress bar
  ntasks=$(( $(echo "$tasks" | grep -o "\," | wc -l) + 1 ))
  taskpercentage=$((100 / $ntasks))

  (
    progress=0
    errors=false

    for i in ${!taskMessages[@]}; do
      if [[ $tasks == *"${taskNames[$i]}"* ]]; then
        echo "# ${taskMessages[$i]}..."

        error="$(${taskRecipes[$i]} 2>&1 > /dev/null)"

        if [[ ! -z $error ]]; then
          echo "RECIPE "${taskNames[$i]} >> $ErrorLog
          echo "$error" >> $ErrorLog
          errors=true
        fi

        progress=$(( $progress + $taskpercentage ))
        echo $progress
      fi
    done

  if $errors ; then
    echo "# Some tasks ended with errors"
  else
    echo "# All tasks completed succesfully"
  fi
  ) |
  zenity --progress \
         --no-cancel \
         --title="Alfred" \
         --text="Performing all tasks" \
         --percentage=0 \
         --height 100 \
         --width 500

  # Notify errors
  if [[ $? != 0 ]]; then
    zenity --error \
           --text="An unexpected error occurred. Some tasks may not have been performed."
    exit 1
  fi

  # Show error list from the error log
  test -e $ErrorLog

  if [[ $? == 0 ]]; then
    errors=()

    # Last occurrence of NEW SESSION
    startLine=$(tac $ErrorLog | grep -n -m1 "NEW SESSION" | cut -d: -f1) 

    while read line; do
      firstword=$(echo $line | cut -d' ' -f1)

      if [ "$firstword" == "RECIPE" ]; then # If line starts with RECIPE
          errors+=("${line/RECIPE /}")
      fi
    done <<< "$(tail -n $startLine $ErrorLog)" # Use the log only from startLine to the end
    
    if [[ ${#errors[@]} > 0 ]]; then

      message="The following tasks ended with errors and could not be completed:"

      selected=$(zenity --list --height 500 --width 500 --title="Alfred" \
                        --text="$message" \
                        --hide-header --column "Tasks with errors" "${errors[@]}")  

      message="Please notify the following error log at https://github.com/derkomai/alfred/issues\n"
      message+="-------------------------------------------------------------"
      message+="---------------------------------------------------------\n\n"

      echo -e $message"$(tail -n $startLine $ErrorLog)" | 
      zenity --text-info --height 700 --width 800 --title="Alfred"
    fi
  fi
}
# End of main function


testPackage()
{
  dpkg-query -l $1 &> /dev/null

  if [ $? == 0 ]; then
    echo true
  else
    echo false
  fi
}


installPackage()
{
  if [[ "$1" == "http"*".deb" ]]; then
    wget -O /tmp/package.deb $1
    apt-get -y install /tmp/package.deb
    rm /tmp/package.deb
  else
    apt-get -y install $1
  fi
}


addRepository()
{
  if ! $(testPackage software-properties-common); then
    installPackage software-properties-common
  fi

  add-apt-repository -y $1
  apt-get update
}


getPassword()
{
  sudo -k

  while true; do
    password=$(zenity --password --title="Alfred")

    # Check for closed window / cancel button
    if [[ $? == 1 ]]; then
        if zenity --question --title="Alfred" --text="Are you sure you want to exit?"; then
          return 1
        else
          continue
        fi
    fi

    # Check for correct password
    myid=$(echo $password | sudo -S id -u)

    if [[ $? == 0 ]] && [[ $myid == 0 ]]; then
      echo $password
      return 0
    else
        zenity --info --title="Alfred" --text="Wrong password, try again"
    fi
  done
}


# RUN

# Check for root permissions and ask for password in other case
if [[ $(id -u) == 0 ]]; then
    main
else
    password=$(getPassword)

    if [[ $? == 0 ]]; then
      echo $password | sudo -S "$0"
    else
      exit 0
    fi
fi

exit 0

# Donation Buttons
#[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/dvilela)
#[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/dvilela)

# donate, check error while installing and notify, mint, debian