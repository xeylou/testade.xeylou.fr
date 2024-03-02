---
title: "ssh explored"
date: 2023-08-19
draft: false
tags: ["cheat-sheet"]
slug: "ssh-cheat-sheet"
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

here i expose my ssh usages & some advanced notions about it

<!-- https://www.ssh.com/academy/ssh/openssh#what-is-openssh? -->
i'll speak about the ssh protocol as the openssh implementation

i'm tempted to write my articles in lower case only as i usually write so outside

read this article like a cheat sheet

## fundamentals

secure shell - ssh, is a very versatile protocol but generally used to access a remote server command line securely

- encapsulate in tcp/ip
- use port tcp/22 by default
- use asymetric cryptography

the first time accessing a remote ssh host, its public key fingerprint is prompted to know if you are accessing the wanted host - security reasons, prevent MitM attacks - asking you if you trust it or not 

if yes, the fingerprint is paste in your `~/.ssh/known_hosts` w/ the associate ip address & encryption protocol; its now trusted by your local machine

### modifications

on the ssh server side, connexions behaviour can be modified in `/etc/ssh/sshd_config`

*(sshd stands for ssh daemon)*

basic ssh setup let you connect to a host entering an username & a password beside root

if modifications is made, for the changes to take effect: the sshd service needs to be restarted

```bash
systemctl restart sshd
```

*for hosts using systemd, like debian distros*

### good practices

- change the ssh access port from the port 22

- check if the root login is disabled (yes by default)

- using [ssh keys](#keys) or [certificates](#certificates) (authentication) + username & password (authorisation)

- use differents keys to access different servers

- use `~/.ssh/config` to easily manage keys & remote hosts

- use a [passphrase](#passphrases) for your private keys

- use an [ssh bastion](#ssh-bastions) to centralise your connections from the outside

### keys

the server has a public key that everyone can see, only you have the private key to connect to the server; public key -> the lock, private key -> *the key...*

private & public keys are generated simultaneously, various encryption algorithms could be choosen

private keys default location is `~/.ssh` in your local machine - *perfectly fine with it*

w/ openssl, this command brings forms to fill to create a public & a private key pair

```bash
ssh-keygen # to generate keys
```
> to automate or create many at once w/out filling the forms:  
>
> `-C` can be used to add a comment to a key  
`-t` to choose the encryption algorithm - rsa by default  
`-b` number of bytes, the more the better encryption  
`-f` the location, usefull when creating many keys at once  
`-N ""` specify a passphrase, replace what's inside `""`
<!-- ed25519 -->

pushing a public key to a remote host, after running the `ssh-keygen` command - *make sure an ssh server is running on the remote host & that you have login for it*

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

it simplifies your connexions, since you only use to do `ssh debian-vm` for example

```bash
Host abitraryname
    Hostname remotehost
    User username
    Port sshport
    IdentityFile /path/to/privatekey
```

after changes, no need to restart a service

```bash
ssh abitraryname
```

### certificates
<!-- https://smallstep.com/blog/use-ssh-certificates/
https://goteleport.com/blog/how-to-configure-ssh-certificate-based-authentication/ -->
works in the same way tls/ssl does for https

used to scale ssh, usefull to create a limited time access

after creating a public & a private key (saw in [keys](#keys)), those can be signed w/ a Certificate Authority (CA) certificate

```bash
ssh-keygen -s hostca -I hostname.domain.tld -h -n hostname.domain.tld -V +52w key.pub
```
> `-s hostca` specify the file name of the CA private key  
`-I hostname.domain.tld` the certificate's identity  
`-h` specify its an host certificate, not an user one  
`-n hostname.domain.tld` url to access the future host  
`-V +52w` certificates's validity period (52 weeks)  

*(a passphrase can be asked)*

`key-cert.pub` should be generated

to use it, paste the the ca to the `/etc/ssh` folder on the local host for example

and edit in the `/etc/ssh/sshd_config` file:

```bash
HostCertificate /etc/ssh/key-cert.pub
```

the remote host now present a certificate to anyone who connects

to the client side, trust the ca in `$HOME/.ssh/know_hosts

```bash
@cert-authority *.domain.tld ssh-rsa <hostca.pub content>
```


## file transfering
<!-- https://linuxhandbook.com/transfer-files-ssh/ -->
ways to transfer ressources to & from a remote host
### from a remote host
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
rsync username@remotehost:/remote/path/to/file .
rsync -r username@remotehost:/remote/path .
```
### to a remote host
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
### mount a remote folder
mount a remote directory on local system w/ sshfs (ssh file system) 
```bash
apt install -y sshfs # depends on your package manager
mkdir mount-dir
```
mount the remote directory in the created folder
```bash
sshfs username@remote-host:/remote/path mount-dir
```
changes in the `mount-dir` will also be made in `remote-host:/remote/path`

to unmount it
```bash
umount mount-dir
```
### sftp
<!-- https://phoenixnap.com/kb/sftp-commands -->
ssh file transfer protocol, or secure file transfer protocol

can be used with the `sftp` command to open a remote shell

```bash
sftp username@remotehost
```
can navigate with `pwd`, `ls`, `cd` & use `get` or `put` to gather or send ressources

```bash
get filename
put filename
```
or

```bash
get /path/to/remote/file /path/to/local/directory
put /path/to/local/file /path/to/remote/directory
```
a gui like filezilla for an easier transfer experience (gui) can be done
## x11 forwarding
use remote app gui on local host
### config remote server
run with root or sudoer
```bash
apt install -y xauth # to forward x11 packets, depends pkgs manager
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

ssh tunneling encapsulate a layer 3-7 traffic between 2 hosts over ssh

ssh encryption is added to the communication - *so that if an unsecured communication is used, it is encrypted*

it can also be used to bypass firewall restrictions by fowarding ports

uncontrolled or unmonitored tunnels can be used as backdoors, for data exfiltration, bouncing attacks & more
### local fowarding
<!-- https://www.youtube.com/watch?v=x1yQF1789cE -->
forward a port from a ssh client to a ssh server (launched from the ssh client)

extremely usefull to access a remote service denyied by a firewall, it needs the remote host to be accessible with ssh 

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph LR
a(local machine)
b(firewall)
c(remote host)

a---b
b-->c
{{< /mermaid >}}

let's say you have a raspberry pi at `192.168.1.12` (remote host) w/ ssh access via the `pi` user 

it shosting a web server locally on its `5000` port & you want to access it locally through your machine 
```bash
ssh -N -L 127.0.0.1:8080:127.0.0.1:5000 pi@192.168.1.12
ssh -N -L 8080:127.0.0.1:5000 pi@192.168.1.12

```
> `-N` prevents from running an active ssh session

all traffic (http requests) sent to localhost:8080 on local machine will be forwarded to raspberry pi's 5000 port - responses sended back to you

<!-- using 0.0.0.0 pour la première adresse, tu autorises tout le monde à venir dessus -->
`LocalForward` variable can be edited in the [config file](#config-file) to avoid putting it every connexion

<!--
NOTE PERSO

N'IMPORT QUEL IP, PAR EXEMPLE CELLE DU ROUTEUR
QUE LE REMOTE HOST A ACCES, IL PEUT FORWARD VERS
ELLES
-->

### reverse ssh tunnels
<!-- https://www.youtube.com/watch?v=TZ6W9Hi9YJw 
https://www.youtube.com/watch?v=aOmIqUs0fbY -->
also called remote ssh tunnels or ssh remote forwarding

forward a port on a remote host (ssh server) to a port on a local machine (ssh client)

initialised by the remote server

used to access a service hosted on a remote local network, from another network (or internet)

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

usefull to centralise & secure ssh connexions in a corporate network to reduce the "attack surface" to just one machine

[teleport](https://goteleport.com/) is an opensource solution if not using openssh

#### advices

- only the ssh port should be accessible for incomming connexions
- the ssh port is changed from 22
- root user is disabled
- be very aware of the security implementations
- prevent users to use an ssh active session into the bastion itself

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

`-J` parameter can be avoided by configuring the `ProxyJump` permanently in [config file](#config-file)

*parameters saw in [config file](#config-file) can be added too*

```bash
Host arbitraryname
   ProxyJump bastionaddress
```
creation of an ssh user that cannot ssh into the bastion itself, called `bastionuser` in `/etc/ssh/sshd_config`

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

change root (chroot) method changes appareant root directory for the running user to a root directory called a chrooting jail

usefull when giving access to untrusted or unmonitored users

ssh support chrooting by restricting an ssh session to a directory

you can [create a fancy one manually](https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/) but it is very long, for each user

[rssh](https://linux.die.net/man/1/rssh) is a simpler way to do so

create a new user with the `/usr/bin/rssh` shell
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

so if someone tried to impersonate the remote host identity or the host change, its fingerprint will be different & a warning will pop up saying that's not the wanted server

if targetted by a man-in-the-middle attack the first connexion, you could be at risk using ssh connexion

dnssec has many features to improve the standard & old dns protocol, one of which is: dns answers are not tampered

*it is possible that an attacker can hijack ssh connexions & create valid dnssec responses, but less likely*

use `ssh-keygen` as usual w/ an url using dnssec & a `.` at its end to stop the domain for beeing repeated twice
```bash
ssh-keygen subdomain.domainwithdnssec.tld.
```
then
```bash
ssh -o VerifyHostKeyDNS=yes subdomain.domainwithdnssec.tld.
```