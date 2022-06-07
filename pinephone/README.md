# Bootstrap NixOS to Pinephone

These instructions assume a Linux machine. You could jump through some hoops to create a workflow for Windows or MacOS, but that is beyond the scope of these instructions.

## Build NixOS image for Pinephone

The nixos disk image package in mobile-nixos can theoretically be cross-compiled, but when I tried cross-compiling from x86 the resulting rootfs partition only had the nix store and was missing the rest of the OS scaffolding.

Some various ways to acquire a NixOS image for Pinephone are:

### Build the disk-image on a Raspberry Pi or ARM based linux board

I haven't tried this but it should work.

### Flash Mobian to the Pinephone, then install nix and build the disk-image from the Pinephone

Flash this installer to an SD card, then boot from SD card on a Pinephone to install Mobian on the eMMC.
```
    make flash-mobian-installer
```
### Launch an ARM virtual machine with Qemu, then install nix, and build the disk-image on the VM
```
    cd qemu
    make shell
    make launch
    make login
```

## Install Jumpdrive onto SD card

1. Download Jumpdrive image
```
make image-jumpdrive
```

2. Insert an SD card to your computer. (all existing data on card will be lost)

3. Find the block device for the inserted SD card with `lsblk`. (here the SD card was assigned `sdb`)
```
    lsblk

    NAME          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
    sdb             8:16   1  14.6G  0 disk  
    └─sdb1          8:17   1    49M  0 part  
    nvme0n1       259:0    0   1.8T  0 disk  
    ├─nvme0n1p1   259:1    0    99M  0 part  
    ├─nvme0n1p2   259:2    0   499M  0 part  /boot
    ├─nvme0n1p3   259:3    0   976G  0 part  
    │ └─luksroot  254:0    0   976G  0 crypt 
    │   ├─vg-swap 254:1    0    10G  0 lvm   [SWAP]
    │   └─vg-root 254:2    0   966G  0 lvm   /nix/store
    │                                        /
    ├─nvme0n1p4   259:4    0 488.3G  0 part  
    └─nvme0n1p5   259:5    0 390.6G  0 part
```

4. Flash Jumpdrive to the SD card.
(use `BD=x` where `x` is the block device you found with `lsblk`)
```
make flash-jumpdrive BD=sdb
```

5. Safely remove the SD card. (after running this you should no longer see the SD card with `lsblk`)
```
make safely-remove BD=sdb
```

## Use Jumpdrive to flash NixOS image to Pinephone's eMMC

1. Acquire a NixOS disk image for ARM. (see previous section for options)

2. Insert Jumpdrive SD card into Pinephone and power on and plug Pinephone into computer via USB. With the SD card inserted, the Pinephone should automatically boot from the SD card. You should see a graphic indicating Jumpdrive is running.

3. With Jumpdrive running and the Pinephone connected to your computer, you should be able to find the block device for the Pinephone's eMMC using `lsblk`. (here, the Pinephone's eMMC was assigned `sda` and the SD card in the Pinephone was assigned `sdb`)
```
    sda             8:0    1  29.1G  0 disk  
    ├─sda1          8:1    1     1M  0 part  
    ├─sda2          8:2    1    16M  0 part  
    ├─sda3          8:3    1   128M  0 part  
    └─sda4          8:4    1    29G  0 part  
    sdb             8:16   1  14.6G  0 disk  
    └─sdb1          8:17   1    49M  0 part  
    nvme0n1       259:0    0   1.8T  0 disk  
    ├─nvme0n1p1   259:1    0    99M  0 part  
    ├─nvme0n1p2   259:2    0   499M  0 part  /boot
    ├─nvme0n1p3   259:3    0   976G  0 part  
    │ └─luksroot  254:0    0   976G  0 crypt 
    │   ├─vg-swap 254:1    0    10G  0 lvm   [SWAP]
    │   └─vg-root 254:2    0   966G  0 lvm   /nix/store
    │                                        /
    ├─nvme0n1p4   259:4    0 488.3G  0 part  
    └─nvme0n1p5   259:5    0 390.6G  0 part  
```

4. Flash the NixOS image to the Pinephone's eMMC.
(use `BD=x` where `x` is the block device you found with `lsblk`)
```
make flash-nixos BD=sda
```

5. Once this is done you should see 4 partitions on the eMMC device. The 4th partition is the root file system.

6. Use `gparted` or equivalent tool to resize the 4th partition on the eMMC to fill all of the remaining space on the device.

7. This image is almost ready for use, we just need to set the root user password. Since this image is built for ARM, you can't just mount the image and use `passwd`/`chroot` to set user passwords from an x86 system. You need to manually set the root user to have no password.
```
mkdir /mnt/nixos-arm
mount /dev/sda4 /mnt/nixos-arm
sed -i 's/root:x/root:/g' /mnt/nixos-arm/etc/passwd
umount /dev/sda4
rmdir /mnt/nixos-arm
```

8. Power-cycle the Pinephone and plug a USB keyboard into the Pinephone via the dock included with the phone.

9. You should now be able to login with user=`'root'` and password=`''`.

10. After logging in you can now make NixOS configuration changes and rebuild from the phone.

## Add custom configuration

I'm using my personal Pinephone configuration here to show a working example.

1. Establish internet access. Easiest way to is to plug ethernet into the Pinephone dock.

2. Install `git` and `just`.
```
nix-channel --update
nix-env -i git just
```

3. Pull NixOS configuration onto Pinephone.
```
cd /etc/nixos
git clone https://gitlab.com/cameronfyfe/nixos-configs.git .
```

4. Bootstrap the "cameron-phone" configuration onto the device.
```
just bootstrap-hostname cameron-phone
just deploy
git restore flake.nix
just deploy
```

5. Any further configuration changes can be built and deployed with `just deploy`.
