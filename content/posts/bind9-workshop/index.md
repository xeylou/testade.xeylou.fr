---
title: "bind9 workshop"
date: 2023-09-27
# lastmod: 2023-10-15
draft: false
tags: [ "dns", "french", "gnu/linux", "workshop" ]
slug: "bind9-workshop"
---

<!-- prologue -->

{{< lead >}}
installation d'une 
infrastructure dns bind9
{{< /lead >}}

<!-- article -->

## introduction

les deux premiers tp portaient sur l'installation d'une infrastructure dns avec bind9

je n'ai pas fait les notions "transversales" : gestion des logs & les acl

pour nous le qcm sur bind9, dovecot, postfix sera le 18 ou le 19 octobre, sur des notions de cours, td, tp

pas de points négatifs, pas de choix multiples -> une seule réponse possible

## explications

j'utilise 3 vm debian 12 : `r303-deb12-host1`, `r303-deb12-bind1` & `r303-deb12-bind2`

le réseau local des vm est le `192.168.122.0/24` avec leur passerelle par défaut en `192.168.122.1`

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
subgraph 192.168.122.0/24
host1[r303-deb12-host1<br><font color="#a9a9a9">.2</font>]
bind1[r303-deb12-bind1<br><font color="#a9a9a9">.3</font>]
srv-bind(Service Bind9)
srv-bind2(Service Bind9)
bind2[r303-deb12-bind2<br><font color="#a9a9a9">.4</font>]
gw{NAT<br><font color="#a9a9a9">.1</font>}
end

wan{WAN}
wan --- gw
gw --- host1 & bind1
gw --- bind2
bind1 -.- srv-bind
bind2 -.- srv-bind2
{{< /mermaid >}}

j'utilise debian par habitude, *mr. le prof* veut nous faire accèder en ssh à ces vm pour ne pas utiliser l'environnement de bureau des ubuntu

## configuration initiale

pour éviter d'avoir `root@debian` sur toutes les vm en ssh, je change leur `hostname` pour avoir `root@serveur-bind-1` par exemple

lors des manipulations en terminal, ça évite de se tromper entre qui est qui & de rentrer une commande sur la mauvaise vm

{{< alert icon="circle-info">}}
**Note** commande effectuée en permission root sur les 3 vm en changeant *nouveau_hostname*
{{< /alert >}}

```bash
hostnamectl set-hostname nouveau_hostname && logout
```

<!-- ### configuration des IPs -->

je change aussi les ip des vm de manière statique dans `/etc/network/interfaces`

```bash
nano /etc/network/interfaces
```

je supprime la ligne indiquant de se référer au dhcp (si elle existe): `inet iface enp1s0 dhcp`

&& je rajoute cette configuration selon l'interface, ici `enp1s0` où `X` est le dernier octet de l'adresse des vm configurées [sur le schéma](#explications)

```bash {linenos=table, hl_lines=["13-17"], linenostart=1}
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface

# interface que vous avez
auto enp1s0
iface enp1s0 inet static
address 192.168.122.X
netmask 255.255.255.0
gateway 192.168.122.1
```

<!-- ### connexion root ssh -->

pour me simplifier la connexion en ssh, j'autorise l'accès au compte `root` sur les vm *- désactivé par défaut par sécurité*

en éditant le fichier `/etc/ssh/sshd_config`

{{< alert icon="circle-info">}}
**Note** manipulation effectuée sur les 3 vm
{{< /alert >}}

```bash
nano /etc/ssh/sshd_config
```

en décommentant & changeant la valeur de cette variable

```bash {linenos=table, hl_lines=4, linenostart=30}
# Authentication

#LoginGraceTime 2m
PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10
```

je redémarre le daemon ssh pour prendre la modification en compte

```bash
systemctl restart sshd
```

je change aussi le mot de passe du compte root des vm

```bash
passwd root
```

pour ne pas trop réflechir avec des ip *- je le fais mais une erreur d'inattention dans une ip & j'y suis pour 4h de deboggage...*

sur la machine qui va accèder en ssh aux vm, je crée des alias pour juste rentrer `ssh bind` & arriver sur la vm bind par exemple *- j'essaye d'être "fénéant intelligemment"* :smile:

{{< alert icon="circle-info">}}
**Note** sur la machine physique
{{< /alert >}}

```bash
nano ~/.ssh/config
```
avec la configuration suivante

```bash {linenos=table}
host host1
  Hostname 192.168.122.2
  User root

host bind1
  Hostname 192.168.122.3
  User root

host bind2
  Hostname 192.168.122.4
  User root
```

après ça je peux juste faire `ssh host1` qui sera l'équivalent de `ssh root@192.168.122.2`

## conf. serveur bind1

j'utiliserai le nom de domaine `adehu.com`

j'accède au shell du serveur bind

```bash
ssh bind1
```

j'installe les paquets nécessaires

```bash
apt install -y dbus bind9* dnsutils
```

avant de débuter:

une `zone inverse` : on demande au serveur dns -> pour cette adresse ip, tu as quel domaine? 

ce qui est l'inverse de -> j'ai ce nom de domaine, donne-moi son ip associée

dans la zone inverse, il faut mettre les mêmes enregistrements que ceux dans adehu.com, mais à l'envers (vous allez comprendre)

je définis aussi que ce serveur dns (bind1) est le serveur principal pour ces zones dns

dans le fichier de gestion des zones `/etc/bind/named.conf`, sera définit la zone dns & sa zone inverse

*même si la bonne pratique voudrait qu'il inclut un fichier de configuration pour chaque zone...*

```bash
nano /etc/bind/named.conf
```

contenant la configuration suivante

```bash {linenos=table, hl_lines=["13-21"], linenostart=1}
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";

zone "adehu.com" IN {
  type master;
  file "/etc/bind/adehu.com";
};

zone "122.168.192.in-addr.arpa" {
  type master;
  file "/etc/bind/adehu.com.inverse";
};
```

on fait référence à des fichiers qui seront la configuration de ces zones

`type master`: ce dns est le serveur dns principal de cette zone

pour vérifier la syntaxe du fichier après l'enregistrement

```bash
named-checkconf /etc/bind/named.conf
```

le serveur bind1 sait maintenant qu'il doit se référer au fichier de configuration `/etc/bind/adehu.com` pour la gestion de la zone `adehu.com` qu'il gère

configuration de la zone dns `adehu.com`

```bash
nano /etc/bind/adehu.com
```

```txt {linenos=table, hl_lines=["1-100"]}
$TTL 86400
$ORIGIN adehu.com.

@ IN SOA bind1.adehu.com. admin.adehu.com. (
2023092702 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS bind1.adehu.com.
@ IN NS bind2.adehu.com.
guest.adehu.com. IN NS bind2
bind1 IN A 192.168.122.3
bind2 IN A 192.168.122.4
srv-bind1 IN CNAME bind1
srv-bind2 IN CNAME bind2
```

la directive `$ORIGIN` est là pour indiquer le domaine si un hôte est pas totalement défini

`@ IN SOA` pour accorder qui a l'autorité sur cette zone (ici bind1) avec sa config.

`IN NS` pour faire le record d'un serveur dns (pour cette zone il y a deux serveurs dns)

je rajoute un . à la fin des fqdn pour indiquer leur fin (sinon ils répètent leur domain.tld)

`guest.adehu.com. IN NS r303-deb12-bind2` définit un sous domaine & le délègue à bind2 -> si tu veux aller sur le sous-domaine `guest.adehu.com`, va contacter ce serveur dns

par contre, sur le deuxième serveur dns (bind2), il faudra lui indiquer qu'il gère cette zone (`guest.adehu.com`)

`IN A` record pour définir les adresses ip des machines qu'on renseigne (A pour ipv4, AAAA pour ipv6)

`IN CNAME` les serveurs bind seront accessibles via `bindX.adehu.com` où `X` leur nombre

les valeurs chiffrées je ne les ai pas sorti de mon chapeau mais de ce tableau d'équivalence (secondes -> instances de temps)

<table><thead><tr><th>secondes</th><th>instances de temps</th></tr></thead><tbody><tr><td>60</td><td>1 min</td></tr><tr><td>1800</td><td>30 min</td></tr><tr><td>3600</td><td>1 heure</td></tr><tr><td>10800</td><td>3 heures</td></tr><tr><td>21600</td><td>6 heures</td></tr><tr><td>43200</td><td>12 heures</td></tr><tr><td>86400</td><td>1 jour</td></tr><tr><td>259200<br></td><td>3 jours</td></tr><tr><td>604800</td><td>1 semaine</td></tr></tbody></table>

pour la zone inverse

```bash
nano /etc/bind/adehu.com.inverse
```

```txt {linenos=table, hl_lines=["1-100"]}
$TTL 86400

@ IN SOA bind1.adehu.com. admin.adehu.com. (
2023092701 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS bind1.
@ IN NS bind2.
11 IN PTR bind1
12 IN PTR bind2
```
> `IN PTR` le nombre au début = dernier octet de l'ip voulue, on enregistre un pointeur (ptr) vers tel machine

vérification de la syntaxe

```bash
named-checkzone adehu.com /etc/bind/adehu.com
named-checkzone adehu.com.inverse /etc/bind/adehu.com.inverse
```

redémarrage du service bind9 pour prendre en compte les modifications

```bash
systemctl restart bind9
```

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Mettez dans le `/etc/resolv.conf` de la machine `host1` l'ip du serveur bind1 pour l'avoir en tant que serveur dns
{{< /alert >}}

```bash
nano /etc/resolv.conf
```

```bash {linenos=table, hl_lines=1}
nameserver 192.168.122.3
```

vérification de l'installation

*tous les tests en dessous fonctionnent*
```bash
# pour tester un domaine: dig domain.tld
dig adehu.com

# connaitre les serveurs dns gérant un domaine: dig NS domain.tld
dig NS adehu.com

# résoudre un nom: dig sub-domain.domain.tld
dig bind1.adehu.com
dig bind2.adehu.com

# tester la zone inverse: nslookup ip-machine-a-joindre
# ou dig -x
nslookup 192.168.122.3
nslookup 192.168.122.4
```

cependant, je n'ai pas testé le sous-domaine `guest.adehu.com` car pas encore configuré sur le serveur bind2

## deuxième serveur bind

je vais partager la gestion de la zone `adehu.com` au deuxième serveur dns `r303-deb12-bind2`, le serveur bind1 sera le serveur dns primaire (master) & bind2 le secondaire (secondary)

j'autorise alors le transfert de la zone `adehu.com` vers le serveur bind2 `r303-deb12-bind2` par en renseignant son ip

{{< alert icon="circle-info">}}
**Note** sur r303-deb12-bind1
{{< /alert >}}

```bash
nano /etc/bind/named.conf
```

```txt {linenos=inline, hl_lines=[16, 22]}
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";

zone "adehu.com" IN {
  type master;
  file "/etc/bind/adehu.com";
  allow-transfer { 192.168.122.4; };
};

zone "122.168.192.in-addr.arpa" {
  type master;
  file "/etc/bind/adehu.com.inverse";
  allow-transfer { 192.168.122.4; };
};
```

redémarrage du service bind9

```bash
systemctl restart bind9
```

de l'autre côté, je dois informer au serveur bind2 qu'il a cette zone, avec `r303-deb12-bind1` en serveur dns maitre

*side note: si une modification est faite sur la zone sur le serveur bind1, elle sera répliquée sur le serveur bind2*

j'ajoute aussi le sous domaine qu'il lui a été attribué (`guest.adehu.com`) -> délégation de zone, où il sera le dns primaire

{{< alert icon="circle-info">}}
**Note** sur r303-deb12-bind2
{{< /alert >}}

```bash
nano /etc/bind/named.conf
```

```txt {linenos=inline, hl_lines=[14, 16, 20, 22, "24-30"]}
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";

zone "adehu.com" IN {
  type slave;
  file "/etc/bind/adehu.com";
  masters { 192.168.122.3; };
};

zone "122.168.192.in-addr.arpa" {
  type slave;
  file "/etc/bind/adehu.com.inverse";
  masters { 192.168.122.3; };

zone "guest.adehu.com" IN {
  type master;
  file "/etc/bind/guest.adehu.com";
};
```

on lui renseigne les zones

à commencer par `adehu.com`

```bash
nano /etc/bind/adehu.com
```

*même configuration qud bind1*

```txt {linenos=table, hl_lines=["1-100"]}
$TTL 86400
$ORIGIN adehu.com.

@ IN SOA bind1.adehu.com. admin.adehu.com. (
2023092702 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS bind1.adehu.com.
@ IN NS bind2.adehu.com.
guest.adehu.com. IN NS bind2
bind1 IN A 192.168.122.3
bind2 IN A 192.168.122.4
srv-bind1 IN CNAME bind1
srv-bind2 IN CNAME bind2
```

y compris la zone inverse

```bash
nano /etc/bind/adehu.com.inverse
```

*même configuration que bind1*

```txt {linenos=table, hl_lines=["1-100"]}
$TTL 86400

@ IN SOA bind1.adehu.com. admin.adehu.com. (
2023092702& ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS bind1.
@ IN NS bind2.
11 IN PTR bind1
12 IN PTR bind2
```

vu qu'un sous-domaine a été délégué, il faut définir sa zone

```bash
nano /etc/bind/guest.adehu.com
```

```txt {linenos=table, hl_lines=["1-100"]}
$TTL 86400
$ORIGIN guest.adehu.com.

@ IN SOA guest.adehu.com. guest.adehu.com. (
2023092702 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS bind2.guest.adehu.com.
adehu.com. IN NS bind1.adehu.com.
adehu.com. IN NS bind2.adehu.com.
bind1.adehu.com. IN A 192.168.122.3
bind2.adehu.com. IN A 192.168.122.4
srv-bind2 IN CNAME bind2
```

application des modifications

```bash
named-checkzone adehu.com /etc/bind/adehu.com
named-checkzone adehu.com.inverse /etc/bind/adehu.com.inverse
systemctl restart bind9
```

pour tester le serveur bind2 depuis la machine host1

```bash
nslookup adehu.com 192.168.122.4
nslookup guest.adehu.com 192.168.122.4
```

<!-- ## mr. billon s'il vous plait

- délégation de zone/sous-domaine?

***faire touch bind.log si je fais fichier log***

par defaut aussi bind ecrit ses logs dans /var/log/named

dans apparmor faut rajouter `/var/log/bind** rw,`pour bind

chown bind:bind /var/log/bind -->