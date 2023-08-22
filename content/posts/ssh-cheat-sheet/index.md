---
title: "ssh explored"
date: 2023-08-19
draft: false
tags: ["cheat-sheet"]
slug: "ssh"
---

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

here i expose my uses of ssh & some advanced notions about it

<!-- https://www.ssh.com/academy/ssh/openssh#what-is-openssh? -->
i'll speak about the ssh protocol as the openssh implementation

i'm tempted to write my articles in lower case only as i usually write so outside

read this article like a cheat sheet

## fundamentals

secure shell - ssh, is a very versatile protocol but generally used to access a remote server command line securely

- encapsulate in tcp/ip
- use port tcp/22 by default
- use asymetric cryptography

the first time connecting to a remote ssh server, w/ or w/out a private key, you have the server public key fingerprint prompted asking you if you trust it or not

if yes, it is paste in `$HOME/.ssh/known_hosts` w/ the associate ip address & encryption protocol; its trusted by the local machine

### modifications

on the ssh server side, connexions behaviour can be modified in `/etc/ssh/sshd_config`

*sshd stands for the ssh daemon*

basic ssh setup let you connect to an ssh host entering an username & a password beside root

to make the modifications take changes, restart the sshd service

```bash
systemctl restart sshd
```

### good practices

- change the ssh access port from the port 22

- check if the root login is disabled (yes by default)

- using [ssh keys](#keys) (authentication) + username & password (authorization) or [certificates](#certificates)

- use differents keys to access different servers

- using `~/.ssh/config` to manage easily keys & remote servers

### keys

the server has a public key that everyone can see, only you have the private key to connect to the server; public key -> the lock, private key -> the *key...*

private & ssh keys are generate simultaneously, various algorithms could be choosen

their default location are `~/.ssh` - *perfectly fine with it*

```bash
ssh-keygen
```
*-C can be used to add a comment to a key, -t choose the algorithm*
<!-- ed25519 -->

add a public key to a remote host, after running the `ssh-keygen` command

```bash
ssh-copy-id -i path/to/key.pub username@remotehost
```
or
```bash
cat path/to/key.pub | ssh username@remotehost "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```
### passphrases

passphrases can be added to private ssh keys, preventing the usage of the key if stolen

### config file

`~/.ssh/config` serve the ssh client to manage its remote hosts

```bash
host remotename
    Hostname remotehost
    User username
    Port sshport
    IdentityKey pathtoprivatekey
```

after that config, no need to restart a service

```bash
ssh remotename
```

### certificates
<!-- https://smallstep.com/blog/use-ssh-certificates/
https://goteleport.com/blog/how-to-configure-ssh-certificate-based-authentication/ -->
works the same way tls/ssl does for https

use to scale ssh access because having data like an expiration date and permissions

***A CONTINUER***
## file transfering
<!-- https://linuxhandbook.com/transfer-files-ssh/ -->
ways to transfer ressources to & from a remote host
### from remote host
gather a file from a remote host
```bash
scp username@remotehost:/remote/path/to/file .
```
gather a folder from a remote host
```bash
scp -r username@remotehost:/remote/path .
```
synchronising files from a remote host using `rsync`
```bash
rsync username@remotehost:/remote/path .
rsync -r username@remotehost:/remote/path .
```
### to remote host
send a file to a remote host 
```bash
scp filename username@remotehost:/remote/path
```
send a folder to a remote host
```bash
scp -r directoryname username@remotehost:/remote/path
```
`rsync`ing
```bash
rsync filename username@remote-host:/remote/path
rsync -r directoryname username@remote-host:/remote/path
```
### mount remote folder
mount a remote directory on local system w/ sshfs (ssh file system) 
```bash
apt install -y sshfs
mkdir mount-dir
```
mount the remote directory in the created folder
```bash
sshfs username@remote-host:/remote/path mount-dir
```
modifications in the folder will also be done in `remote-host:/remote/path`
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
ssh into it & try launching xapplications

> depending on the remote server configuration, some extra work could be intended

## ssh tunneling
<!-- https://www.ssh.com/academy/ssh/tunneling 
https://www.ssh.com/academy/ssh/tunneling-example
-->
to access specific ressources, vpns expose an entire network which cannot be relevant for security reasons

ssh tunneling encapsulate layer 3-7 network traffic between 2 hosts over ssh

ssh encryption is added to the communication - *so that if a unsecured is used by the application, it is encrypted*

it can also be use to bypass firewall restrictions by fowarding ports

uncontrolled or unmonitored tunnels can be used as backdoors, for data exfiltration, bouncing attacks & more
### local fowarding
<!-- https://www.youtube.com/watch?v=x1yQF1789cE -->
forward a port from the ssh client to the ssh server (launched from the ssh client)

extremely usefull to access a remote service denyied by a firewall, it needs the remote host to be accessible with ssh 

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

the local machine public ip address is `8.8.8.8` - *google one* & accessible w/ ssh

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
the service running the remote server port `80` will be accessible by the local machine loopback address on port `8080`

<!-- 
exemple ouvrir l'accès à la config de son routeur à l'extérieur
ssh -N -R 8976:192.168.1.1:80 username@vm_dans_cloud
 -->

### prevent tunnels

`PermitTunnel no` can be changed in `/etc/ssh/sshd_config` to prevent tunnels creation

### ssh bastions
<!-- https://www.youtube.com/watch?v=F-ubwghsWPM -->
can be called ssh jump servers, ssh proxies or ssh agent forwarding

a single server accessible via ssh from the internet to redirect ssh sessions to others hosts

usefull to centralise & secure ssh connexion in a corporate network to reduce the "attack surface" to just one machine

[teleport](https://goteleport.com/) is an opensource solution if not using openssh

#### advices

- only the ssh port is accessible for incomming connexions
- the ssh port is changed from 22
- root user disabled
- be very aware of the security implementations
- prevent users to ssh into the bastion itself

#### other purposes

can be used to encapsulate data, doing other services than transporting ssh packets

can be used as a "vpn", doing dynamic ssh port forwarding & encapsulate your data w/out exposing an entire network (ssh + socks5 proxy)

<!-- 
https://serverfault.com/questions/312416/can-i-use-ssh-tunnels-as-a-vpn-substitute
https://superuser.com/questions/1005015/ssh-sock-proxy-vs-vpn
-->

#### command

```bash
ssh -J bastionaddress username@remotehost
```

`-J` parameter can be avoid by configuring the `ProxyJump` permanently in `~/.ssh/config`

*parameters saw in [config file](#config-file) can be added to it*

```bash
Host remotehost
   ProxyJump bastionaddress
```
creation of an ssh user that cannot connect into ssh to the ssh bastion itself called `bastionuser`

give this user to anyone using the bastion
 ```bash
Match User bastionuser
   PermitTTY no
   X11Forwarding no
   PermitTunnel no
   GatewayPorts no
   ForceCommand /usr/sbin/nologin
```
then modify the parameters
```bash
ssh -J bastionuser@bastionaddress username@remotehost
```
for the `~/.ssh/config`

```bash
Host remotehost
   ProxyJump bastionuser@bastionaddress
```

<!-- 

NOTE PERSO

PEUT ETRRE PORT SSH POUR SSH PROXY
MAIS AUSSI DAUTRES SERVICES TEMPS QUE LE PROXY Y A ACCES

-->

## chrooting
<!-- 
https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/
-->

change root (chroot) changes appareant root directory for the running user to a root directory called chrooting jail

ssh support chrooting: restricting an ssh session to a directory

you can [create a fancy one manually](https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/) but it is very long, for each user

[rssh](https://linux.die.net/man/1/rssh) is a simpler way to do so

create a new user with `/usr/bin/rssh` shell
```bash
useradd -m -d /home/chrooteduser -s /usr/bin/rssh chrooteduser
passwd chrooteduser
```
or change existing user shell to `/usr/bin/rssh`
```bash
usermod -s /usr/bin/rssh chrooteruser
```
works for sftp & scp
<!-- https://www.cyberciti.biz/tips/linux-unix-restrict-shell-access-with-rssh.html -->
## dnssec
<!-- https://dataswamp.org/~solene/2023-08-05-sshfp-dns-entries.html -->
ssh use tofu *trust on first use*, it trusts the ssh server the first time connecting to it

if targetted by a man-in-the-middle attack, you could be at risk using ssh connexion

dnssec has many features to improve standard & old dns protocol, one of which is: dns answers are not tampered

*it is possible that an attacker can hijack ssh connexion & create valid dnssec responses, but less likely*

use `ssh-keygen` as usual w/ an url & a `.` at its end to stop the domain (not be repeated twice)
```bash
ssh-keygen subdomain.domainwithdnssec.tld.
```
then
```bash
ssh -o VerifyHostKeyDNS=yes subdomain.domainwithdnssec.tld.
```