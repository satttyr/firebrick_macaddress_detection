#!/bin/sh
# Script by Kjow

echo "********************************************************"
echo "*                                                      *"
echo "*                Automated Installation                *"
echo "*    for install Lazarus/FPC with arm cross compile    *"
echo "*                                       Script by Kjow *"
echo "*                                                      *"
echo "* This script is designed for Ubuntu X86 (32 Bit)      *"
echo "*                                                      *"
echo "********************************************************"
echo ""
echo "Please, enter your account user:"
read NAME

#swap # of the two rows below to choose between FPC 2.4.0 and 2.5.1
#FPCVER="2.4.0"
FPCVER="2.5.1"

echo ""
echo "Install dependencies"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y subversion
sudo apt-get install -y cvs
sudo apt-get install -y alien
sudo apt-get install -y libncurses5-dev
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y libgdk-pixbuf-dev
sudo apt-get install -y libXp-dev
sudo apt-get install -y libgtk1.2-dev
sudo apt-get install -y libXxf86vm-dev
sudo apt-get install -y glutg3-dev
sudo apt-get install -y libgli-mesa-dev
sudo apt-get install -y mesa-utils

echo ""
echo "Create dirs"
cd /home/$NAME
mkdir /home/$NAME/fpc_tools
mkdir /home/$NAME/fpc_tools/fpc_setup
mkdir /home/$NAME/fpc_tools/binutils
mkdir /home/$NAME/lazarus
mkdir /home/$NAME/lazarus/fpc
mkdir /home/$NAME/lazarus/fpc/$FPCVER
mkdir /home/$NAME/lazarus/fpc/binutils

echo ""
echo "Download files"
cd /home/$NAME/fpc_tools/

#swap # of the two rows below to choose between FPC 2.4.0 and 2.5.1
#svn co http://svn.freepascal.org/svn/fpc/tags/release_2_4_0 fpc
svn co http://svn.freepascal.org/svn/fpc/trunk fpc

cd /home/$NAME/fpc_tools/fpc/
svn up
sudo rm -r -f /home/$NAME/lazarus/fpc/$FPCVER/*
svn export --force /home/$NAME/fpc_tools/fpc/ /home/$NAME/lazarus/fpc/$FPCVER/

cd /home/$NAME/fpc_tools/fpc_setup
wget -c http://mirror.mirimar.net/freepascal/dist/2.4.0/i386-linux/rpm/fpc-2.4.0-1.i386.rpm

cd /home/$NAME/fpc_tools/binutils
wget -c http://ftp.gnu.org/gnu/binutils/binutils-2.20.1.tar.gz
tar xvf binutils-2.20.1.tar.gz
sudo rm -r -f /home/$NAME/fpc_tools/binutils-2.20.1
mv /home/$NAME/fpc_tools/binutils/binutils-2.20.1/ /home/$NAME/fpc_tools/

cd /home/$NAME/
svn co http://svn.freepascal.org/svn/lazarus/trunk lazarus
cd /home/$NAME/lazarus/
svn up

cd /home/$NAME/lazarus/components/
svn co https://glscene.svn.sourceforge.net/svnroot/glscene/trunk glscene

echo ""
echo "Install & Configure Binutils"
cd /home/$NAME/fpc_tools/binutils-2.20.1
./configure --target=arm-linux --disable-werror
make
sudo make install
sudo rm -f /home/$NAME/lazarus/fpc/binutils/*
ln -s /usr/local/bin/arm-linux-ar /home/$NAME/lazarus/fpc/binutils/ar
ln -s /usr/local/bin/arm-linux-ld /home/$NAME/lazarus/fpc/binutils/ld
sudo mv /usr/local/bin/arm-linux-as /usr/local/bin/arm-linux-as_org
sudo echo "#!/bin/sh
/usr/local/bin/arm-linux-as_org -meabi=5 \$@" > /home/$NAME/fpc_tools/arm-linux-as
sudo mv /home/$NAME/fpc_tools/arm-linux-as /usr/local/bin/arm-linux-as
sudo chmod +x /usr/local/bin/arm-linux-as
ln -s /usr/local/bin/arm-linux-as /home/$NAME/lazarus/fpc/binutils/as

echo ""
echo "FPC Setup"
sudo alien -i -c /home/$NAME/fpc_tools/fpc_setup/fpc-2.4.0-1.i386.rpm
cd /home/$NAME/lazarus/fpc/$FPCVER/
make clean all OPT='-gl -O3p3' PP=/usr/lib/fpc/2.4.0/ppc386
sudo make install PREFIX=/usr PP=/usr/lib/fpc/2.4.0/ppc386
sudo rm -f /usr/bin/ppc386
sudo ln -s /usr/lib/fpc/$FPCVER/ppc386 /usr/bin/ppc386
sudo ln -sf /home/$NAME/lazarus/fpc/$FPCVER/ /usr/share/fpcsrc
sudo /usr/lib/fpc/$FPCVER/samplecfg /usr/lib/fpc/$FPCVER/ /etc

echo ""
echo "FPC for ARM"
cd /home/$NAME/lazarus/fpc/$FPCVER/
sudo make crossinstall CPU_TARGET=arm OS_TARGET=linux CROSSBINDIR=/home/$NAME/lazarus/fpc/binutils/ OPT=-dFPC_ARMEL INSTALL_PREFIX=/usr
echo "#INCLUDE /etc/fpc.cfg
#DEFINE DEMOTEST
#DEFINE DEMOTEST1
#DEFINE LAZARUS

-Fu/usr/lib/fpc/$FPCVER/units/\$fpctarget/*
-Fl/usr/lib/fpc/$FPCVER/units/\$fpctarget/rtl/

-a
-Sd
-Xd
-Xs

-O-

#IFDEF CPUARM
-XP/home/$NAME/lazarus/fpc/binutils/
-Xr/usr/lib/fpc/$FPCVER/units/arm-linux/rtl/
-Xr/home/$NAME/lazarus/fpc/libcross
-XR/home/$NAME/lazarus/fpc/
-darm
-Tlinux
#ENDIF" > /home/$NAME/.fpc.cfg
sudo ln -sf /usr/lib/fpc/$FPCVER/ppcrossarm /usr/local/bin/ppcarm

echo ""
echo "Lazarus Setup"
cd /home/$NAME/lazarus
make clean all
make bigideclean bigide 

ln -s /home/$NAME/lazarus/startlazarus /home/$NAME/Desktop/Lazarus.ln

echo ""
echo "***********************************************"
echo "*         The automated installation          *"
echo "*                     is                      *"
echo "*                  finished                   *"
echo "* please, now follow these WIKI instrucrions: *"
echo "***********************************************"
echo "http://wiki.lazarus.freepascal.org/Setup_Cross_Compile_For_ARM#Configure_Lazarus_for_cross_Compile"

