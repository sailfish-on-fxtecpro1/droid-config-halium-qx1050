# README
# Use this script to flash SailfishOS to the F(x)tec Pro¹-X.
# The device must be in "fastboot" (or bootloader) mode.
# It may be necessary to run this script as root.
# Usage: sh flash.sh or ./flash.sh

if ! command -v fastboot &> /dev/null
then
    echo "
$(tput setaf 196)fastboot could not be found on your system. Install fastboot (android-tools or android-tools-fastboot) from your package manager.$(tput sgr0)"
    exit
else
    echo "
$(tput setaf 2)fastboot found, proceeding.$(tput sgr0)"
fi

echo "
$(tput setaf 220)Be aware, the flashing process might take up to 10 minutes.
The screen is expected to go black. This is fine, flashing continues.$(tput sgr0)

$(tput setaf 2)Initiating reboot to fastbootd.$(tput sgr0)
"
fastboot reboot fastboot

fastboot $* getvar product 2>&1 | grep "^product: *QX1050"
if [ $? -ne 0 ] ; then
	echo "$(tput setaf 1)Mismatched image and device$(tput sgr0)";
	exit 1;
fi

handle_error()
{
    echo $@
    exit 2;
}

#Flash kernel and init
fastboot flash boot_a boot.img || handle_error flash boot_a error

#Flash DTB
fastboot flash dtbo_a dtbo.img || handle_error flash dtbo_a error

#Flash root and home filesystems
fastboot flash userdata userdata.simg || handle_error flash userdata error

#Set slot a
fastboot set_active a || fastboot --set-active=a

echo "
$(tput setaf 2)Flashing process successful.$(tput sgr0)

$(tput setaf 220)Reboot now? [Y/n] $(tput sgr0)
"
read -rsn1 input
if [ "$input" != "n" ] ; then
    fastboot reboot
    break
else
    echo "$(tput setaf 220)Please reboot manually now. (e.g. using fastboot reboot or holding the power button)$(tput sgr0)"
    break
fi
