---
title: "debian custom iso"
date: 2024-08-20
draft: false
tags: [ "gnu/linux", "open-source" ]
slug: "debian-preseed"
---

<!-- prologue -->

{{< lead >}}
creating custom debian  
installation images
{{< /lead >}}

<!-- sources -->

<!--
https://www.linuxtricks.fr/news/11-le-sac-de-chips/374-operations-inutiles-donc-indispensables-saturer-son-systeme-cpu-ram-disque-reseau/
https://cleveruptime.com/docs/files/proc-loadavg
https://euro-linux.com/en/blog/load-average-process-states-on-linux/
https://www.malekal.com/quest-ce-que-le-load-average-sur-linux/#Comprendre_et_lire_le_load_average
-->

<!-- article -->

without noticing, i was used to do the same tasks to install debian machines when i couldn't duplicate an existing one - answering the same questions, typing the same commands after the first boot...

this led me wasting time, forgetting to install packages or misconfiguring something because of me not doing procedures, and because of my way of maintaining my procedures - being overtaken by my changing needs and my newest installations requierements

i dealt with this until a friend of mine asked me if i knew something to generate pre-built debian images for its distributed environment - thing i hadn't thought about in my workflow before

after research and testing, i have now dedicated debian isos[^1] for my needs, that i upgrade on schedule when i need to change things for my future installations, as well as logs on what is on them

## thought process

i was aware of cloud init[^2] but it has to be implemented in a cloud based environment. i tested it on proxmox (pve) and on my point of view it has more to deal with cloud based infrastructures

my needs were oriented to "unattended installation" as Microsoft call it for Windows, where you have an iso/cd *installation media* ready to go with your system configuration pre-loaded ready to be installed (users, locale, disks, network...) - mitigating manual interactions and potential flaws

as so, i discovered tools from distributors to automate their operating system installation process. on most of them, you can launch post-installation scripts to install and configure packages before your first login

windows has [unattended installation](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11) to do so, red hat has [kickstart](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-howto), ubuntu has [autoinstall](https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html), debian has [preseed](https://wiki.debian.org/DebianInstaller/Preseed), and a project aims to do so with other linux distros called [fai (Fully Automatic Installation)](https://wiki.fai-project.org/index.php/Main_Page)

## debian preseed

debian pressed make debian installation snappy by answering the questions initially for the user, by inputing a file before the installation

i modify the installation media to add my preseed file in it and a custom profile to do the installation using this preseed file, that i make the default choice in the menu

### preseed file creation

template of the pressed file is [given by debian](https://www.debian.org/releases/bookworm/example-preseed.txt)

it is documented, you have to modify the variables according to your needs/requirements (users, network settings, locale, disks...)

if you are not inspired, you can modify [my preseed file](preseed.cfg) and make it your own

### open iso & insert preseed file

i used a debian machine, it could be different depending the OS used

i download the initial iso (`wget` the link)

```bash
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso
```

create a folder to mount the iso in (could be anything)

```bash
mkdir /mnt/iso
```

mount the iso into this dolder

```bash
mount -o loop "/root/debian-12.6.0-amd64-netinst.iso" /mnt/iso
```

the iso is mounted, but you should see something like this

> mount: /mnt/iso: WARNING: source write-protected, mounted read-only.

the iso is mounted in read-only mode

copy the content of the iso mounted folder to an other folder

```bash
cp -r /mnt/iso "/root/extracted_iso/"
```

now you have successfully extracted `debian-12.6.0-amd64-netinst.iso` to the `/root/extracted_iso` folder

to unmount the iso

```bash
umount /mnt/iso
```

now we can only work in the `extracted_iso` folder

i create the `xeylou` folder to put my preseed file in it

```bash
mkdir -p /root/extracted_iso/xeylou
cp preseed.cfg /root/extracted_iso/xeylou/.
```

to modify the boot menu and the default choice, you have to modify files in the `isolinux` folder

`menu.cfg` says overall aspect of the menu, but the installation choices are referred w/ pointers to `cfg` files

like the `gtk.cfg` file which is the graphical installation one and the `txt.cfg` which is the terminal user interfaced one

i will create my own, `xeylou.cfg` and copy the content of the `txt.cfg` one, with a default value

```bash
vi /root/extracted_iso/isolinux/xeylou.cfg
```
```cfg
default xeylouinstall
label xeylouinstall
        menu label ^Xeylou Pressed Installation
        kernel /install.amd/vmlinuz
        append vga=788 initrd=/install.amd/initrd.gz auto=true priority=high file=/cdrom/xeylou/preseed.cfg --- quiet
```
i edit the `default install` in `gtk.cfg`, & i add `include xeylou.cfg` in `menu.cfg`

you will maybe encounter this warning message

> [ /root/extracted_iso/isolinux/menu.cfg is meant to be read-only ]

but we can override it

then i use genisoimage to generate a new imahe

```bash
apt-get install -y genisoimage
cd /root/extracted_iso
genisoimage -o /root/deb12_xeylou_preseed_V1.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -r .
```

salted password with pwgen

```bash
apt install -y whois pwgen
mkpasswd -m sha-512 -S $(pwgen -ns 16 1) root
```

## sources

https://askubuntu.com/questions/1396759/cloud-init-vs-kickstart-vs-preseed  
https://www.reddit.com/r/devops/comments/yki21b/what_exactly_is_cloudinit/  
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/  
https://github.com/Tontonjo/debian/tree/master/preseed  

[^1]: `*.iso` files are system installation images, which you boot on to instruct your system how to install your desired OS (Windows, Debian...) - they oftenly ask you some questions on the way you want to install your system

[^2]: cloudinit is more like an automated provisioning tool. distributors oftenly distribute cloudinit compatible images for you to use their os to public cloud providers (AWS, Google Cloud, Hetzner...). moreover, cloudinit only runs once the vm has been installed