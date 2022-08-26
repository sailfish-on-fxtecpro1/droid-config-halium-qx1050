#README
#Use this script to flash the device.  The device must
#be in "fastboot" (or bootloader) mode.
#It may be nescessary to run this script as root.
#Usage: sh flash.sh

fastboot $* getvar product 2>&1 | grep "^product: *QX1050"
if [ $? -ne 0 ] ; then
	echo "Checking for bengal device";
	fastboot $* getvar product 2>&1 | grep "^product: *bengal"
	if [ $? -ne 0 ] ; then
		echo "Mismatched image and device";
		exit 1;
	fi
fi

handle_error()
{
    echo $@
    exit 2;
}

#Kernel and init
fastboot flash boot_a boot.img || handle_error flash boot_a error

#DTB
fastboot flash dtbo_a dtbo.img || handle_error flash dtbo_a error

#Root and home filesystems
fastboot flash userdata userdata.simg || handle_error flash userdata error

echo "You should now set the active slot to 'a' using either"
echo "fastboot set_active a"
echo "or"
echo "fastboot --set-active=a"
echo "depending on your fastboot version"
