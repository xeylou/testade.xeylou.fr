---
title: "bind9 workshop"
date: 2023-09-27
draft: false
tags: [ "french", "gnu/linux", "dns" ]
slug: "bind9-workshop"
---

<!-- prologue -->

{{< lead >}}
installation d'une infrastructure  
dns bind9 pour le module r303
{{< /lead >}}

<!-- article -->

## introduction

les deux premiers tp portent sur l'installation d'une infrastructure dns avec des serveurs bind9

je n'ai pas fait les notions "transversales" : gestion des logs & les acl

essayez de comprendre ce qu'il se fait, lire vraiment attentivement plutôt que de le refaire en copiant & en collant

pour nous le qcm sur bind9 & postfix sera le 18 ou le 19 octobre, sur des notions de cours, td, tp

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

j'utilise debian d'habitude & mr. le prof veut nous faire accèder en ssh à ces vm, & ne pas utiliser l'environnement de bureau des ubuntu

## configuration initiale

pour éviter d'avoir `root@debian` sur toutes les vm en ssh, je change leur `hostname` pour avoir `root@serveur-bind-1` par exemple

lors des manipulations en terminal, ça évite de se tromper entre qui est qui & de rentrer une commande dans la mauvaise vm

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

& je rajoute cette configuration selon l'interface, ici `enp1s0` où `X` est le dernier octet de l'adresse des vm configurés [sur le schéma](#explications)

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

pour me simplifier la connexion, j'autorise l'accès au compte `root` sur les vm en ssh *- désactivé par défaut pour des raisons de sécurité*

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

puis je redémarre le daemon ssh pour prendre la modification en compte

```bash
systemctl restart sshd
```

je change aussi le mot de passe du compte root des vm pour `root`

```bash
passwd root
```

pour ne pas trop réflechir avec des ip *- je le fais mais une erreur d'inattention dans une ip & tu y es pour 4h de deboggage...*

sur la machine qui va accèder en ssh à tout le monde (machine physique), je crée des alias pour juste rentrer `ssh bind` & arriver sur le serveur bind par exemple *- j'essaye d'être "fénéant intelligemment"* :smile:

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

on accède au shell du serveur bind

```bash
ssh bind1
```

puis on installe les paquets nécessaires

```bash
apt install -y dbus bind9* dnsutils
```

avant de débuter la config.:

une `zone inverse` : on demande au serveur dns -> pour cette adresse ip, tu as quel domaine? 

ce qui est l'inverse de -> j'ai ce nom de domaine, donne-moi son ip associée

dans la zone inverse, on va mettre les mêmes enregistrements que ceux dans adehu.com, mais à l'envers du coup

on va aussi définir que ce serveur dns (bind1) est le serveur principal pour ces zones dns

dans le fichier de gestion des zones `/etc/bind/named.conf`, on définit notre zone dns & sa zone inverse

*même si la bonne pratique voudrait qu'il include notre fichier de conf.*

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

`type master`: ce dns est le principal de cette zone dns


on peut aussi vérifier la syntaxe du fichier après l'enregistrement

```bash
named-checkconf /etc/bind/named.conf
```

configuration de la zone dns `adehu.com`

```bash
nano /etc/bind/adehu.com
```

```txt {linenos=table}
$TTL 86400
$ORIGIN adehu.com.

@ IN SOA adehu.com. admin.adehu.com. (
2023092702 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS r303-deb12-bind1.adehu.com.
@ IN NS r303-deb12-bind2.adehu.com.
guest.adehu.com. IN NS r303-deb12-bind2
r303-deb12-bind1 IN A 192.168.122.3
r303-deb12-bind2 IN A 192.168.122.4
bind1 IN CNAME r303-deb12-bind1
bind2 IN CNAME r303-deb12-bind2
```

la directive `$ORIGIN` est là pour indiquer le domaine si un hôte est pas totalement défini

`@ IN SOA` pour accorder qui a l'autorité sur cette zone (ici bind1) avec sa config.

`IN NS` on fait le record d'un serveur dns (pour cette zone il y a deux serveurs dns)

je rajoute un . à la fin des fqdn pour indiquer leur fin (sinon ils répètent leur domain.tld)

`guest.adehu.com. IN NS r303-deb12-bind2` on définit un sous domaine & on le délègue à bind2 -> si tu veux aller sur ce sous-domaine, va contacter lui. par contre faudra lui renseigner

`IN A` pour les dns définis, faut bien leur ip (A pour ipv4)

`IN CNAME` les serveurs bind seront accessibles via `bindX.adehu.com`


les valeurs chiffrées je ne les ai pas sorti de mon chapeau mais de ce tableau d'équivalence (secondes -> instances de temps)

<table><thead><tr><th>nombres attroces</th><th>instances de temps</th></tr></thead><tbody><tr><td>60</td><td>1 min</td></tr><tr><td>1800</td><td>30 min</td></tr><tr><td>3600</td><td>1 heure</td></tr><tr><td>10800</td><td>3 heures</td></tr><tr><td>21600</td><td>6 heures</td></tr><tr><td>43200</td><td>12 heures</td></tr><tr><td>86400</td><td>1 jour</td></tr><tr><td>259200<br></td><td>3 jours</td></tr><tr><td>604800</td><td>1 semaine</td></tr></tbody></table>

pour la zone inverse

```bash
nano /etc/bind/adehu.com.inverse
```

```txt {linenos=table}
$TTL 86400

@ IN SOA adehu.com. admin.adehu.com. (
2023092701 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS r303-deb12-bind1.
@ IN NS r303-deb12-bind2.
11 IN PTR r303-deb12-bind1
12 IN PTR r303-deb12-bind2
```
> `IN PTR` le nombre au début = dernier octet de l'ip voulue, on enregistre un pointeur (ptr) vers tel machine

on vérifie la syntaxe

```bash
named-checkzone adehu.com /etc/bind/adehu.com
named-checkzone adehu.com.inverse /etc/bind/adehu.com.inverse
```

redémarrer le service bind9 pour prendre en compte les modifications

```bash
systemctl restart bind9
```

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
Mettez dans le `/etc/resolv.conf` de votre machine `host1` l'ip de votre serveur bind1 pour l'avoir en tant que dns
{{< /alert >}}

```bash
nano /etc/resolv.conf
```

```bash {linenos=table}
nameserver 192.168.122.3
```

vérifier l'installation

*tous les tests en dessous fonctionnaient*
```bash
# pour tester un domaine: dig domain.tld
dig adehu.com

# connaitre les serveurs dns gérant un domaine: dig NS domain.tld
dig NS adehu.com

# résoudre un nom: dig sub-domain.domain.tld
dig bind1.adehu.com
dig bind2.adehu.com

# tester la zone inverse: nslookup ip-machine-a-joindre
nslookup 192.168.122.3
nslookup 192.168.122.4
```

## deuxième serveur bind

je vais partager la gestion de la zone `adehu.com` au deuxième serveur dns `r303-deb12-bind2`, le serveur bind1 sera le serveur dns primaire (master) & bind2 le secondaire (secondary)

on autorise le transfert de la zone `adehu.com` vers le serveur bind2 `r303-deb12-bind2`

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

on redémarre le service bind

```bash
systemctl restart bind9
```

on doit informer le deuxième serveur bind qu'il a cette zone avec `r303-deb12-bind1` en serveur dns maitre

j'ajoute aussi le sous domaine qu'il lui a été attribué

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

```bash
nano /etc/bind/adehu.com
```

*c'est le même que l'autre*

```txt {linenos=table}
$TTL 86400
$ORIGIN adehu.com.

@ IN SOA adehu.com. admin.adehu.com. (
2023092702 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS r303-deb12-bind1.adehu.com.
@ IN NS r303-deb12-bind2.adehu.com.
guest.adehu.com. IN NS r303-deb12-bind2
r303-deb12-bind1 IN A 192.168.122.3
r303-deb12-bind2 IN A 192.168.122.4
bind1 IN CNAME r303-deb12-bind1
bind2 IN CNAME r303-deb12-bind2
```

y compris la zone inverse

```bash
nano /etc/bind/adehu.com.inverse
```

*c'est le même que l'autre*

```txt {linenos=table}
$TTL 86400

@ IN SOA adehu.com. admin.adehu.com. (
2023092702& ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS r303-deb12-bind1.
@ IN NS r303-deb12-bind2.
11 IN PTR r303-deb12-bind1
12 IN PTR r303-deb12-bind2
```

vu qu'on a délegué un sous-domaine ici, il faut l'indiquer

```bash
nano /etc/bind/guest.adehu.com
```

```txt {linenos=table}
$TTL 86400
$ORIGIN guest.adehu.com.

@ IN SOA guest.adehu.com. guest.adehu.com. (
2023092702 ; serial
21600 ; refresh
10800 ; retry
43200 ; expire
10800 ) ; minimum

@ IN NS r303-deb12-bind2.guest.adehu.com.
adehu.com. IN NS bind1.adehu.com.
adehu.com. IN NS bind2.adehu.com.
bind1.adehu.com. IN A 192.168.122.3
bind4.adehu.com. IN A 192.168.122.4
r303-deb12-bind2 IN A 192.168.122.4
bind2 IN CNAME r303-deb12-bind2
```

on applique les modifications

```bash
named-checkzone adehu.com /etc/bind/adehu.com
named-checkzone adehu.com.inverse /etc/bind/adehu.com.inverse
systemctl restart bind9
```

pour le tester sur la machine host1

```bash
nslookup adehu.com 192.168.122.4
```

<!-- ## mr. billon s'il vous plait

- délégation de zone/sous-domaine?

***faire touch bind.log si je fais fichier log***

par defaut aussi bind ecrit ses logs dans /var/log/named

dans apparmor faut rajouter `/var/log/bind** rw,`pour bind

chown bind:bind /var/log/bind -->