#!/bin/bash

OPTS=""

## Unbinding and binding PCIE devices
function unbind {
    sudo sh -c "echo '$1' > /sys/bus/pci/drivers/vfio-pci/new_id"
    sudo sh -c "echo '0000:$2' > /sys/bus/pci/devices/0000:$2/driver/unbind"
    sudo sh -c "echo '0000:$2' > /sys/bus/pci/drivers/vfio-pci/bind"
    sudo sh -c "echo '$1' > /sys/bus/pci/drivers/vfio-pci/remove_id"
    if [[ -z $3 ]]; then
        OPTS="$OPTS -device vfio-pci,host=$2"
    else
        OPTS="$OPTS -device vfio-pci,host=$2,$3"
    fi
}

function rebind_to_driver {
    sudo sh -c "echo '0000:$1' > /sys/bus/pci/devices/0000:$1/driver/unbind"
    sudo sh -c "echo '0000:$1' > /sys/bus/pci/drivers/$2/bind"
}

function rebind {
    sudo sh -c "echo 1 > /sys/bus/pci/devices/0000:$1/remove"
}

function qemu_exit {
    sudo sh -c "echo 1 > /sys/bus/pci/rescan"
}

## Mounting disks
function mount_iso {
    OPTS="$OPTS -drive file=$1,media=cdrom"
}

function mount_ovmf_bios {
    cp /usr/share/ovmf/x64/OVMF_VARS.fd /tmp/my_vars.bin
    OPTS="$OPTS -drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd"
    OPTS="$OPTS -drive if=pflash,format=raw,file=/tmp/my_vars.bin"
}

function mount_disk_img {
    OPTS="$OPTS -device virtio-scsi-pci,id=scsi"
    OPTS="$OPTS -drive file=$1,if=none,format=raw,aio=native,cache=none,id=hd0,media=disk"
    OPTS="$OPTS -device scsi-disk,drive=hd0"
    OPTS="$OPTS -boot order=dc"
}

function mount_2TB_disk {
    if grep -qs '/mnt/windows-storage' /proc/mounts;
    then
        echo 2TB Drive is mounted, unmounting...
        sudo umount /dev/disk/by-uuid/0A82E3C182E3AEFF
        echo Drive unmounted sucessfully!
        sleep 2
    fi

    OPTS="$OPTS -drive file=/dev/disk/by-uuid/0A82E3C182E3AEFF,if=none,format=raw,aio=native,cache=none,id=hd1"
    OPTS="$OPTS -device scsi-block,drive=hd1"
}

## Hugepages
function allocate_hugepages {
    sudo sh -c "echo $1 > /proc/sys/vm/nr_hugepages"
}

function release_hugepages {
    sudo sh -c "echo 0 > /proc/sys/vm/nr_hugepages"
}

## General Options for all VMS
OPTS="$OPTS -enable-kvm"
OPTS="$OPTS -vga none"
OPTS="$OPTS -nographic"
OPTS="$OPTS -monitor none"
OPTS="$OPTS -display none"
