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

debug=true

# TASK LIST ###################################################################
#------------------------------------------------------------------------------
taskNames=("Update system")
taskMessages=("Updating system")
taskDescriptions=("Update system packages to its latest version")
taskRecipes=("updateSystem")
taskDefaults=("FALSE")

updateSystem()
{
  apt-get update
  apt-get -y dist-upgrade
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
  installPackage ubuntu-restricted-extras
}
#------------------------------------------------------------------------------
taskNames+=("Install Chrome")
taskMessages+=("Installing Chrome")
taskDescriptions+=("The web browser from Google")
taskRecipes+=("installChrome")
taskDefaults+=("FALSE")

installChrome()
{
  if [[ $OSarch == "x86_64" ]]; then
      installPackage "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  else
      >&2 echo "Your system is not supported by Google Chrome"
  fi
}
#------------------------------------------------------------------------------
taskNames+=("Install Chromium")
taskMessages+=("Installing Chromium")
taskDescriptions+=("The open-source web browser providing the code for Google Chrome.")
taskRecipes+=("installChromium")
taskDefaults+=("FALSE")

installChromium()
{
  installPackage chromium-browser
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
  installPackage firefox firefox-locale-$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
}
#------------------------------------------------------------------------------
taskNames+=("Install Opera")
taskMessages+=("Installing Opera")
taskDescriptions+=("Just another web browser")
taskRecipes+=("installOpera")
taskDefaults+=("FALSE")

installOpera()
{
  if [[ $OSarch == "x86_64" ]]; then
    installPackage "http://download1.operacdn.com/pub/opera/desktop/42.0.2393.137/linux/opera-stable_42.0.2393.137_amd64.deb"
  else
    installPackage "http://download1.operacdn.com/pub/opera/desktop/42.0.2393.137/linux/opera-stable_42.0.2393.137_i386.deb"
  fi
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
  installPackage transmission-gtk
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
    installPackage git
    apt-get --purge remove -y dropbox*
    installPackage python-gpgme
    git clone https://github.com/zant95/elementary-dropbox /tmp/elementary-dropbox
    bash /tmp/elementary-dropbox/install.sh
  else
    if [[ $OSarch == "x86_64" ]]; then
        wget -q -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    else
        wget -q -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
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

  if [ ! -f /etc/apt/sources.list.d/virtualbox.list ]; then
    sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $OSbaseCodeName contrib" >> /etc/apt/sources.list.d/virtualbox.list'
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
    apt-get update
  fi

  installPackage virtualbox-5.1
  wget -q -O /tmp/extensionPack.vbox-extpack http://download.virtualbox.org/virtualbox/5.1.10/Oracle_VM_VirtualBox_Extension_Pack-5.1.10-112026.vbox-extpack
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
  addRepository "deb http://archive.canonical.com/ $OSbaseCodeName partner"
  installPackage skype pulseaudio:i386
}
#------------------------------------------------------------------------------
taskNames+=("Install Thunderbird")
taskMessages+=("Installing Thunderbird")
taskDescriptions+=("A mail client from Mozilla")
taskRecipes+=("installThunderbird")
taskDefaults+=("FALSE")

installThunderbird()
{
  installPackage thunderbird
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

  wget -q -o /opt/Telegram/icon.png https://desktop.telegram.org/img/td_logo.png

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
  installPackage vlc
}
#------------------------------------------------------------------------------
taskNames+=("Install Kazam")
taskMessages+=("Installing Kazam")
taskDescriptions+=("A tool to record your screen and take screenshots")
taskRecipes+=("installKazam")
taskDefaults+=("FALSE")

installKazam()
{
  installPackage kazam
}
#------------------------------------------------------------------------------
taskNames+=("Install Handbrake")
taskMessages+=("Installing Handbrake")
taskDescriptions+=("A video transcoder")
taskRecipes+=("installHandbrake")
taskDefaults+=("FALSE")

installHandbrake()
{
  addRepository "ppa:stebbins/handbrake-releases"
  installPackage handbrake-gtk handbrake-cli
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

  if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
    echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
    apt-get update
  fi

  installPackage spotify-client
}
#------------------------------------------------------------------------------
taskNames+=("Install Audacity")
taskMessages+=("Installing Audacity")
taskDescriptions+=("Record and edit audio files")
taskRecipes+=("installAudacity")
taskDefaults+=("FALSE")

installAudacity()
{
  installPackage audacity
}
#------------------------------------------------------------------------------
taskNames+=("Install Soundconverter")
taskMessages+=("Installing Soundconverter")
taskDescriptions+=("Audio file converter")
taskRecipes+=("installSoundconverter")
taskDefaults+=("FALSE")

installSoundconverter()
{
  installPackage soundconverter
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
  installPackage mixxx
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
  installPackage gimp
}
#------------------------------------------------------------------------------
taskNames+=("Install Inkscape")
taskMessages+=("Installing Inkscape")
taskDescriptions+=("Create and edit scalable vectorial images")
taskRecipes+=("installInkscape")
taskDefaults+=("FALSE")

installInkscape()
{
  installPackage inkscape
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
  installPackage blender
}
#------------------------------------------------------------------------------
taskNames+=("Install LeoCad")
taskMessages+=("Installing LeoCad")
taskDescriptions+=("Virtual LEGO CAD software")
taskRecipes+=("installLeoCad")
taskDefaults+=("FALSE")

installLeoCad()
{
  installPackage unzip

  wget -q -O /tmp/ldraw.zip http://www.ldraw.org/library/updates/complete.zip
  unzip /tmp/ldraw.zip -d /home/$SUDO_USER

  installPackage leocad
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

  wget -q -O /tmp/paraview.tar.gz "http://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.2&type=binary&os=linux64&downloadFile=ParaView-5.2.0-Qt4-OpenGL2-MPI-Linux-64bit.tar.gz"
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
  installPackage libreoffice
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Writer")
taskMessages+=("Installing LibreOffice Writer")
taskDescriptions+=("Install just the LibreOffice word processor")
taskRecipes+=("installLibreOfficeWriter")
taskDefaults+=("FALSE")

installLibreOfficeWriter()
{
  installPackage libreoffice-writer
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Impress")
taskMessages+=("Installing LibreOffice Impress")
taskDescriptions+=("Install just the LibreOffice slide show editor")
taskRecipes+=("installLibreOfficeImpress")
taskDefaults+=("FALSE")

installLibreOfficeImpress()
{
  installPackage libreoffice-impress
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Spreadsheet")
taskMessages+=("Installing LibreOffice Spreadsheet")
taskDescriptions+=("Install just the LibreOffice spreadsheet editor")
taskRecipes+=("installLibreOfficeSpreadsheet")
taskDefaults+=("FALSE")

installLibreOfficeSpreadsheet()
{
  installPackage libreoffice-calc
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Draw")
taskMessages+=("Installing LibreOffice Draw")
taskDescriptions+=("Install just the LibreOffice drawing editor")
taskRecipes+=("installLibreOfficeDraw")
taskDefaults+=("FALSE")

installLibreOfficeDraw()
{
  installPackage libreoffice-draw
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Base")
taskMessages+=("Installing LibreOffice Base")
taskDescriptions+=("Install just the LibreOffice database manager")
taskRecipes+=("installLibreOfficeBase")
taskDefaults+=("FALSE")

installLibreOfficeBase()
{
  installPackage libreoffice-base
}
#------------------------------------------------------------------------------
taskNames+=("Install LibreOffice Math")
taskMessages+=("Installing LibreOffice Math")
taskDescriptions+=("Install just the LibreOffice equation editor")
taskRecipes+=("installLibreOfficeMath")
taskDefaults+=("FALSE")

installLibreOfficeMath()
{
  installPackage libreoffice-math
}
#------------------------------------------------------------------------------
taskNames+=("Install Evince")
taskMessages+=("Installing Evince")
taskDescriptions+=("A document viewer with support for PDF, Postscript, djvu, tiff, dvi, XPS and SyncTex")
taskRecipes+=("installEvince")
taskDefaults+=("FALSE")

installEvince()
{
  installPackage evince
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
  installPackage jabref
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

  wget -q -O /tmp/zotero.tar.bz2 "https://download.zotero.org/standalone/4.0.29.10/Zotero-4.0.29.10_linux-$arch.tar.bz2"

  tar xjf /tmp/zotero.tar.bz2 -C /tmp
  mv "/tmp/Zotero_linux-$arch" /opt/zotero

  wget -q -o /opt/zotero/icon.png http://icons.iconarchive.com/icons/blackvariant/button-ui-requests-5/1024/Zotero-icon.png

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
  installPackage texmaker
}
#------------------------------------------------------------------------------
taskNames+=("Install Calibre")
taskMessages+=("Installing Calibre")
taskDescriptions+=("eBook management application")
taskRecipes+=("installCalibre")
taskDefaults+=("FALSE")

installCalibre()
{
  wget -q -nv -O- https://download.calibre-ebook.com/linux-installer.py |
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
  installPackage diffpdf
}
#------------------------------------------------------------------------------
taskNames+=("Install Steam")
taskMessages+=("Installing Steam")
taskDescriptions+=("A game digital distribution platform developed by Valve")
taskRecipes+=("installSteam")
taskDefaults+=("FALSE")

installSteam()
{
  addRepository "multiverse"
  installPackage steam
  cd $HOME/.steam/ubuntu12_32/steam-runtime/i386/usr/lib/i386-linux-gnu
  mv libstdc++.so.6 libstdc++.so.6.bak
  cd $HOME/.steam/ubuntu12_32/steam-runtime/amd64/usr/lib/x86_64-linux-gnu
  mv libstdc++.so.6 libstdc++.so.6.bak
}
#------------------------------------------------------------------------------
taskNames+=("Install 0 A.D.")
taskMessages+=("Installing 0 A.D.")
taskDescriptions+=("0 A.D. is a game of ancient warfare, similar to Age of Empires")
taskRecipes+=("install0AD")
taskDefaults+=("FALSE")

install0AD()
{
  installPackage 0ad
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
taskNames+=("Install Wine")
taskMessages+=("Installing Wine")
taskDescriptions+=("A tool to install Windows software on Linux")
taskRecipes+=("installWine")
taskDefaults+=("FALSE")

installWine()
{
  if [[ $OSarch == "x86_64" ]]; then
    dpkg --add-architecture i386
  fi
  addRepository "ppa:wine/wine-builds"
  installPackage "--install-recommends winehq-staging"
}
#------------------------------------------------------------------------------
taskNames+=("Install PlayOnLinux")
taskMessages+=("Installing PlayOnLinux")
taskDescriptions+=("A tool to install Windows games on Linux")
taskRecipes+=("installPlayOnLinux")
taskDefaults+=("FALSE")

installPlayOnLinux()
{
  installPackage playonlinux
}
#------------------------------------------------------------------------------
taskNames+=("Install Disk utility")
taskMessages+=("Installing Disk utility")
taskDescriptions+=("A tool to manage your drives")
taskRecipes+=("installDiskUtility")
taskDefaults+=("FALSE")

installDiskUtility()
{
  installPackage gnome-disk-utility
}
#------------------------------------------------------------------------------
taskNames+=("Install GParted")
taskMessages+=("Installing GParted")
taskDescriptions+=("A tool to make partitions in your hard drives")
taskRecipes+=("installGParted")
taskDefaults+=("FALSE")

installGParted()
{
  installPackage gparted
}
#------------------------------------------------------------------------------
taskNames+=("Install MenuLibre")
taskMessages+=("Installing MenuLibre")
taskDescriptions+=("Add or remove applications from your menu")
taskRecipes+=("installMenuLibre")
taskDefaults+=("FALSE")

installMenuLibre()
{
  installPackage menulibre
}
#------------------------------------------------------------------------------
taskNames+=("Install Seahorse")
taskMessages+=("Installing Seahorse")
taskDescriptions+=("Manage your passwords")
taskRecipes+=("installSeahorse")
taskDefaults+=("FALSE")

installSeahorse()
{
  installPackage seahorse
}
#------------------------------------------------------------------------------
taskNames+=("Install Duplicity")
taskMessages+=("Installing Duplicity")
taskDescriptions+=("Keep your files safe by making automatic backups")
taskRecipes+=("installDuplicity")
taskDefaults+=("FALSE")

installDuplicity()
{
  installPackage duplicity
}
#------------------------------------------------------------------------------
taskNames+=("Install UNetbootin")
taskMessages+=("Installing UNetbootin")
taskDescriptions+=("Tool for creating Live USB drives")
taskRecipes+=("installUNetbootin")
taskDefaults+=("FALSE")

installUNetbootin()
{
  installPackage unetbootin
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
  installPackage gnome-encfs-manager
}
#------------------------------------------------------------------------------
taskNames+=("Install FileZilla")
taskMessages+=("Installing FileZilla")
taskDescriptions+=("Download and upload files via FTP, FTPS and SFTP")
taskRecipes+=("installFileZilla")
taskDefaults+=("FALSE")

installFileZilla()
{
  installPackage filezilla
}
#------------------------------------------------------------------------------
taskNames+=("Install utilities bundle")
taskMessages+=("Installing utilities bundle")
taskDescriptions+=("Java, zip, rar and exfat tools")
taskRecipes+=("installUtilities")
taskDefaults+=("FALSE")

installUtilities()
{
  installPackage icedtea-7-plugin openjdk-8-jre p7zip rar exfat-fuse exfat-utils
}
#------------------------------------------------------------------------------
taskNames+=("Install Glipper")
taskMessages+=("Installing Glipper")
taskDescriptions+=("Gnome clipboard manager")
taskRecipes+=("installGlipper")
taskDefaults+=("FALSE")

installGlipper()
{
  installPackage glipper
}
#------------------------------------------------------------------------------
taskNames+=("Install developer bundle")
taskMessages+=("Installing developer bundle")
taskDescriptions+=("Tools for developers: build-essential, cmake, git, svn, java, python, octave, autotools...")
taskRecipes+=("installDevBundle")
taskDefaults+=("FALSE")

installDevBundle()
{
  installPackage build-essential cmake cmake-gui cmake-curses-gui python python3 \
             octave gfortran git git-svn subversion kdiff3 colordiff openjdk-8-jdk autoconf autotools-dev
}
#------------------------------------------------------------------------------
taskNames+=("Install Swift")
taskMessages+=("Installing Swift")
taskDescriptions+=("A compiler and interpreter for Apple's programming language")
taskRecipes+=("installSwift")
taskDefaults+=("FALSE")

installSwift()
{
  installPackage clang libicu-dev

  if [[ %OSbaseCodeName == "xenial" ]]; then
    wget -q -O /tmp/swift.tar.gz https://swift.org/builds/swift-3.0.2-release/ubuntu1604/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu16.04.tar.gz
    wget -q -O /tmp/swift.tar.gz.sig https://swift.org/builds/swift-3.0.2-release/ubuntu1604/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu16.04.tar.gz.sig
  elif [[ %OSbaseCodeName == "trusty" ]]; then
    wget -q -O /tmp/swift.tar.gz https://swift.org/builds/swift-3.0.2-release/ubuntu1404/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu14.04.tar.gz
    wget -q -O /tmp/swift.tar.gz.sig https://swift.org/builds/swift-3.0.2-release/ubuntu1404/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu14.04.tar.gz.sig
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
  wget -q -O /tmp/eclipse.tar.gz http://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/oomph/epp/neon/R1/eclipse-inst-linux64.tar.gz
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
  addRepository "deb http://repos.codelite.org/ubuntu/ $OSbaseCodeName universe"
  installPackage codelite wxcrafter
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
  installPackage atom
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
    wget -q -O /tmp/arduino.tar.xz https://downloads.arduino.cc/arduino-1.6.13-linux64.tar.xz
  else
    wget -q -O /tmp/arduino.tar.xz https://downloads.arduino.cc/arduino-1.6.13-linux32.tar.xz
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
  wget -q -O /opt/mu/mu.bin https://github.com/mu-editor/mu/releases/download/v0.9.13/mu-0.9.13.linux.bin
  chmod +x /opt/mu/mu.bin
  adduser $SUDO_USER dialout

  wget -q -O /opt/mu/icon.png http://www.unixstickers.com/image/data/stickers/python/python.sh.png

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
  installPackage icedtea-7-plugin openjdk-8-jre

  wget -q -O /tmp/smartgit.tar.gz http://www.syntevo.com/static/smart/download/smartgit/smartgit-linux-8_0_3.tar.gz
  tar xzf /tmp/smartgit.tar.gz -C /tmp
  mv /tmp/smartgit/ /opt/smartgit

  /opt/smartgit/bin/add-menuitem.sh
}
#------------------------------------------------------------------------------
taskNames+=("Install SysAdmin bundle")
taskMessages+=("Installing SysAdmin bundle")
taskDescriptions+=("Tools for sysadmins: tmux, cron, screen, ncdu, htop, aptitude, apache, etckeeper, xpra and dconf-editor")
taskRecipes+=("installSysAdminBundle")
taskDefaults+=("FALSE")

installSysAdminBundle()
{
  installPackage tmux cron screen ncdu htop aptitude apache2 etckeeper xpra dconf-editor exfat-fuse exfat-utils
}
#------------------------------------------------------------------------------
taskNames+=("Install Jaxx")
taskMessages+=("Installing Jaxx")
taskDescriptions+=("A blockchain wallet")
taskRecipes+=("installJaxx")
taskDefaults+=("FALSE")

installJaxx()
{
  wget -q -O /tmp/jaxx.tar.gz https://jaxx.io/files/1.1.7/Jaxx-v1.1.7-linux-x64.tar.gz
  tar -zxf /tmp/jaxx.tar.gz -C /tmp
  mv /tmp/Jaxx-v1.1.7_linux-x64 /opt/jaxx

  wget -q -O /opt/jaxx/icon.png https://jaxx.io/images/mark.png

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
#  installPackage refind
#  refind-install --shim /boot/efi/EFI/ubuntu/shimx64.efi --localkeys
#  refind-mkdefault
#}
#------------------------------------------------------------------------------
# INSTRUCTIONS
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
taskDefaults+=("FALSE")

autoRemove()
{
  apt-get -y autoremove
}
#------------------------------------------------------------------------------
# END OF TASK LIST ############################################################


# Main function
main()
{
  # Test /var/lib/dpkg/lock to ensure we can install packages
  lock=$(fuser /var/lib/dpkg/lock)

  if [ ! -z "$lock" ]; then
    zenity --error --title="Alfred" --text="Another program is installing or updating packages. Please wait until this process finishes and then launch Alfred again."
    exit 0
  fi

  # Repair installation interruptions
  dpkg --configure -a

  # Test connectivity
  if ! nc -zw1 google.com 80; then
    zenity --error --title="Alfred" --text="There is no connection to the Internet. Please connect and then launch Alfred again."
    exit 0
  fi

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
    elif [ $OScodeName == "quiana" ] || [ $OScodeName == "rebecca" ] || \
         [ $OScodeName == "rafaela" ] || [ $OScodeName == "rosa" ]; then
      OSbaseCodeName="trusty"
    elif [ $OScodeName == "sarah" ] || [ $OScodeName == "serena" ]; then
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
      --height 720 \
      --width 1280 \
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
  log="/tmp/Alfred.log"
  errorLog="/tmp/AlfredError.log"

  logHeader="--------------------------------------------------------------------------------------------------\n"
  logHeader="${logHeader}NEW SESSION $(date)\n"
  logHeader="$logHeader$(lsb_release -d | cut -d: -f2 | sed "s/^[ \t]*//")\n"
  logHeader="$logHeader$(uname -a)\n"

  echo -e "$logHeader" >> $errorLog

  if $debug; then
    echo -e "$logHeader" >> $log
  fi

  # Perform all tasks and show progress in a progress bar
  ntasks=$(( $(echo "$tasks" | grep -o "\," | wc -l) + 1 ))
  taskpercentage=$((100 / $ntasks))

  (
    progress=0
    errors=false

    for i in ${!taskMessages[@]}; do
      if [[ $tasks == *"${taskNames[$i]}"* ]]; then
        echo "# ${taskMessages[$i]}..."

        outputMsg=$(
                      set -e

                      if $debug; then
                        ${taskRecipes[$i]} > $log
                      else
                        ${taskRecipes[$i]} 2>&1
                      fi
                   )

        if [[ ! $? == 0 ]]; then
          echo "RECIPE "${taskNames[$i]} >> $errorLog
          echo "$outputMsg" >> $errorLog
          errors=true
        fi

        progress=$(( $progress + $taskpercentage ))
        echo $progress
      fi
    done

  if $errors ; then
    echo "# Some tasks ended with errors"
    notify-send -i utilities-terminal Alfred "Some tasks ended with errors"
  else
    echo "# All tasks completed succesfully"
    notify-send -i utilities-terminal Alfred "All tasks completed succesfully"
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
    zenity --error --title="Alfred"\
           --text="An unexpected error occurred. Some tasks may not have been performed."
    exit 1
  fi

  # Show error list from the error log
  test -e $errorLog

  if [[ $? == 0 ]]; then
    errors=()

    # Last occurrence of NEW SESSION
    startLine=$(tac $errorLog | grep -n -m1 "NEW SESSION" | cut -d: -f1)

    while read line; do
      firstword=$(echo $line | cut -d' ' -f1)

      if [ "$firstword" == "RECIPE" ]; then # If line starts with RECIPE
          errors+=("${line/RECIPE /}")
      fi
    done <<< "$(tail -n $startLine $errorLog)" # Use the error log only from startLine to the end

    if [[ ${#errors[@]} > 0 ]]; then

      message="The following tasks ended with errors and could not be completed:"

      selected=$(zenity --list --height 500 --width 500 --title="Alfred" \
                        --text="$message" \
                        --hide-header --column "Tasks with errors" "${errors[@]}")

      message="Please notify the following error log at https://github.com/derkomai/alfred/issues\n"
      message+="-------------------------------------------------------------"
      message+="---------------------------------------------------------\n\n"

      echo -e $message"$(tail -n $startLine $errorLog)" |
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
  for arg in $@; do
    if [[ "$arg" == "http"*".deb" ]]; then
      wget -q -O /tmp/package.deb $1
      apt-get -y install /tmp/package.deb
      rm /tmp/package.deb
    else
      apt-get -y install $arg
    fi
  done
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
