#!/bin/sh
cd /
touch /dev/.coldboot_done

export LD_LIBRARY_PATH=

# Save systemd notify socket name to let droid-init-done.sh pick it up later
echo $NOTIFY_SOCKET > /run/droid-hal/notify-socket-name

# Use exec nohup since systemd may send SIGHUP, but droid-hal-init doesn't
# handle it. This avoids having to modify android_system_core, which would
# require different handling for every different android version.
# exec nohup /sbin/droid-hal-init

# breaks LXC if mounted
if [ -d /sys/fs/cgroup/schedtune ]; then
    umount -l /sys/fs/cgroup/schedtune || true
fi
# mount binderfs if needed
if [ ! -e /dev/binder ]; then
    mkdir -p /dev/binderfs
    mount -t binder binder /dev/binderfs -o stats=global
    ln -s /dev/binderfs/*binder /dev
fi

mkdir -p /dev/__properties__
mkdir -p /dev/socket

# Halim 11 hack: overlay /vendor/bin/vndservicemanager
if [ -f /usr/share/halium-overlay/vendor/bin/vndservicemanager ]; then
    mount -o bind /usr/share/halium-overlay/vendor/bin/vndservicemanager /android/vendor/bin/vndservicemanager
fi

lxc-start -n android -- /init

lxc-wait -n android -s RUNNING -t 30
containerpid="$(lxc-info -n android -p -H)"
if [ -n "$containerpid" ]; then
    while true; do
        [ -f /proc/$containerpid/root/dev/.coldboot_done ] && break
        sleep 0.1
    done

    # If the socket isn't available, 'getprop' falls back to reading files
    # manually, causing a false positive of propertyservice being up
    while [ ! -e /dev/socket/property_service ]; do sleep 0.1; done

    systemd-notify --ready

    # Systemd has a bug and can't handle the situation that notifying daemon (this one)
    # does exit before systemd has fully handled the notify message.
    # Thus we need to stay here and make sure systemd has handled our notify message
    n=0
    while [ $n -lt 3 ]; do
        sleep 1
        droid_status=`systemctl is-active droid-hal-init.service`
        if [ "$droid_status" == "active" ]; then
            break
        fi
        echo "info systemd again..."
        systemd-notify --ready
        let n=$n+1
    done
else
    echo "droid container failed to start"
    exit 1
fi
