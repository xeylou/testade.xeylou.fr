---
title: "ssh explored"
date: 2023-08-19
draft: false
tags: ["open-source"]
slug: "ssh-explored"
---

<!-- prologue -->

{{< lead >}}
digging through ssh & its   
little-known capabilities
{{< /lead >}}

<!-- sources
https://goteleport.com/blog/ssh-bastion-host/
https://smallstep.com/blog/diy-ssh-bastion-host/
https://www.scaleway.com/en/blog/understanding-ssh-bastion-use-cases-and-tips/
https://www.bastillion.io/

file:///home/xeylou/Downloads/cheat_sheet_ssh_v4.pdf
https://www.linode.com/docs/guides/advanced-ssh-server-security/

https://www.exoscale.com/syslog/advanced-ssh-6-things/
https://help.ubuntu.com/community/SSH/OpenSSH/Advanced
-->

<!-- article -->

## file transfering
<!-- https://linuxhandbook.com/transfer-files-ssh/ -->
Ways to transfer ressources to & from a remote host
### from remote host
Gather a file from a remote host
```bash
scp username@remote-host:/remote/path/to/a/file .
```
Gather a folder from a remote host
```bash
scp -r username@remote-host:/remote/path/to/a/directory .
```
With rsync to synchronise a file
```bash
rsync username@remote-host:/remote/path/file .
rsync -r username@remote-host:/remote/path/to/a/directory .
```
### to remote host
Send a file to a remote host 
```bash
scp your_file username@remote-host:/remote/path/
```
Send a folder to a remote host
```bash
scp -r your_directory username@remote-host:/remote/path/
```
With rysnc to synchronise
```bash
rsync filename username@remote-host:/remote/path
rsync -r your_directory username@remote-host:/remote/path
```
### mount remote folder
Mount a remote directory on local system w/ sshfs (ssh file system) 
```bash
apt install -y sshfs
mkdir mount-dir
```
Mount the remote directory in the folder created
```bash
sshfs username@remote-host:/path/to/dir mount-dir
```
Modifications in the folder will be also done on the `remote-host:/path/to/dir`

To unmount it
```bash
umount mount-dir
```
### sftp
SSH file transfer protocol or secure file transfer protocol using a gui like filezilla
## x11 forwarding
Use remote app gui on local host
### config remote server
Run with root or sudoer
```bash
apt install -y xauth # to forward x11 packets
```
Allowing x11 fowarding in `/etc/ssh/sshd_config` by removing `#`
```bash {linenos=inline, hl_lines=["4"], linenostart=87}
#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
```
```bash
systemctl restart sshd ssh
```






## ssh bastion



## fundamentals
### purpose
### keys
### ways of work



<!-- https://www.exoscale.com/syslog/advanced-ssh-6-things/ -->
### tunnels
### bastions
### jump server
### ssh proxy
### chrooting
obliger à accéder à un seul dossier
## securing ssh
### insecurity
### adding dnssec