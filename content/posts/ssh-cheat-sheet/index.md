---
title: "ssh explored"
date: 2023-08-19
draft: false
tags: ["open-source"]
slug: "ssh"
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
https://www.baeldung.com/linux/ssh-tunneling-and-proxying
-->

<!-- article -->

## introduction

secure shell - ssh, is a very versatile protocol

here i expose my uses of it & some advanced notions about it

read it more like a cheat sheet than as an article

### fundamentals

encapsulate in tcp/ip, use port 22, use asymetric cryptography

the first time connecting to a remote ssh server, w/ or w/out a private key, you have the server public key fingerprint prompted asking you if you trust it or not

if yes, it is paste in `$HOME/.ssh/known_hosts` w/ the associate ip address & its trusted by the local machine

### securing

basic ssh setup let you connect to an ssh host entering an username & a password beside root

modification can be made in `/etc/ssh/sshd_config` to secure the ssh connexion, for example allowing connexion only with a private key

*sshd stands for the ssh daemon*

to make the modifications take changes, restart the sshd service

```bash
systemctl restart sshd
```

### good practices

change the ssh access port from the port 22

check if the root login is disabled (yes by default)

using ssh keys (authentication) + username & password (authorization)

### keys

the server has a public key that everyone can see, only you have the private key to connect to the server; public key -> the lock, private key -> the key

private & ssh keys are generate simultaneously

```bash
ssh-keygen
```

add a public key to a remote host, after running the `ssh-keygen` command

```bash
ssh-copy-id -i path/to/key.pub username@remotehost
```
or
```bash
cat path/to/key.pub | ssh username@remotehost "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

```


## file transfering
<!-- https://linuxhandbook.com/transfer-files-ssh/ -->
ways to transfer ressources to & from a remote host
### from remote host
gather a file from a remote host
```bash
scp username@remote-host:/remote/path/to/a/file .
```
gather a folder from a remote host
```bash
scp -r username@remote-host:/remote/path/to/a/directory .
```
synchronising files from a remote host using `rsync`
```bash
rsync username@remote-host:/remote/path/file .
rsync -r username@remote-host:/remote/path/to/a/directory .
```
### to remote host
send a file to a remote host 
```bash
scp your_file username@remote-host:/remote/path/
```
send a folder to a remote host
```bash
scp -r your_directory username@remote-host:/remote/path/
```
`rsync`ing
```bash
rsync filename username@remote-host:/remote/path
rsync -r your_directory username@remote-host:/remote/path
```
### mount remote folder
mount a remote directory on local system w/ sshfs (ssh file system) 
```bash
apt install -y sshfs
mkdir mount-dir
```
mount the remote directory in the created folder
```bash
sshfs username@remote-host:/path/to/dir mount-dir
```
modifications in the folder will also be done in `remote-host:/path/to/dir`
to unmount it
```bash
umount mount-dir
```
### sftp
ssh file transfer protocol, or secure file transfer protocol, using a gui like filezilla may be better for more advanced file transfer applications
## x11 forwarding
use remote app gui on local host
### config remote server
run with root or sudoer
```bash
apt install -y xauth # to forward x11 packets
```
allowing x11 fowarding in `/etc/ssh/sshd_config` by removing `#`
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
systemctl restart sshd
```
ssh into it & try launching x applications

> depending on the remote server configuration, some extra work could be intended

## ssh tunneling
<!-- https://www.ssh.com/academy/ssh/tunneling 
https://www.ssh.com/academy/ssh/tunneling-example
-->
to access specific ressources, vpns expose a entire network which cannot be relevant for some use cases

ssh tunneling is encapsulating layer 3-7 network traffic between 2 hosts over ssh

ssh encryption is added to the communication to unsecure the application traffic

it can also be use to bypass firewall restrictions by fowarding ports

uncontrolled or unmonitored tunnels can be used as backdoors, for data exfiltration, bouncing attacks & more
### local fowarding
<!-- https://www.youtube.com/watch?v=x1yQF1789cE -->
forward a port from the ssh client to the ssh server (launched from the ssh client)

extremely usefull to access a remote server when firewall is denying it, it needs at least to the remote host to be accessible with ssh 

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph LR
a(local machine)
b(firewall)
c(remote server)

a---b
b-->c
{{< /mermaid >}}

let's say you have a raspberry pi at `192.168.1.12` w/ ssh access via `pi` user hosting a web server locally on its `5000` port & you want to access locally through your machine 
```bash
ssh -N -L 127.0.0.1:8080:127.0.0.1:5000 pi@192.168.1.12
ssh -N -L 8080:127.0.0.1:5000 pi@192.168.1.12

```
*-N prevents from running an active ssh session*

all traffic (http requests) sent to localhost:8080 on your machine will be forwarded to the raspberry pi's 5000 port - responses sended back to you

<!-- using 0.0.0.0 pour la première adresse, tu autorises tout le monde à venir dessus -->
the `LocalForward` variable can be edited in `/etc/ssh/sshd_config` to add a local forwarding permanently

<!-- 


NOTE PERSO

N'IMPORT QUEL IP, PAR EXEMPLE CELLE DU ROUTEUR
QUE LE REMOTE HOST A ACCES, IL PEUT FORWARD VERS
ELLES



 -->

### reverse ssh tunnels
<!-- https://www.youtube.com/watch?v=TZ6W9Hi9YJw 
https://www.youtube.com/watch?v=aOmIqUs0fbY -->
remote ssh tunnels or ssh remote forwarding

forward a port on a remote host (ssh server) to a port on a local machine (ssh client)

initialised by the remote server

used to access a service, hosted on a local network, from another network (or internet)

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph LR
a(remote sever)
b(firewall)
c(local machine)

a---b
b-->c
{{< /mermaid >}}

widely use to exploit systems on private networks

let's say: the remote server is locally running a web server on its port `80`, its local network address is `192.168.1.23`

the local machine public ip address is `8.8.8.8` - *google one* & in accessible from ssh

<!-- 


NOTE PERSO

N'IMPORT QUEL IP, PAR EXEMPLE CELLE DU ROUTEUR
QUE LE REMOTE HOST A ACCES, IL PEUT FORWARD VERS
ELLES

exemple ouvrir l'accès à la config de son routeur à l'extérieur
ssh -N -R 8976:192.168.1.1:80 username@vm_dans_cloud

 -->

```bash
ssh -N -R localhost:8080:192.168.1.23:80 root@8.8.8.8
ssh -N -R 8080:192.168.1.23:80 root@8.8.8.8
```
*-N prevents from running an active ssh session*

it says : the service running on my (remote server) port `80` will be accessible by the local machine loopback address on port `8080`

<!-- 
exemple ouvrir l'accès à la config de son routeur à l'extérieur
ssh -N -R 8976:192.168.1.1:80 username@vm_dans_cloud
 -->
## ssh proxies
<!-- https://www.youtube.com/watch?v=F-ubwghsWPM -->
can be called ssh jump servers or ssh bastions
```bash
ssh -L ton-port:machine-que-tu-veux-atteindre:port-machine-en-face username@ssh-proxy-ip
```
<!-- 

NOTE PERSO

PEUT ETRRE PORT SSH POUR SSH PROXY
MAIS AUSSI DAUTRES SERVICES TEMPS QUE LE PROXY Y A ACCES

-->
## chrooting
obliger à accéder à un seul dossier
## dnssec
<!-- https://dataswamp.org/~solene/2023-08-05-sshfp-dns-entries.html -->