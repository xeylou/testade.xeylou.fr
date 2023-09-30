---
title: "postfix workshop"
date: 2023-09-30
draft: false
tags: [ "dns", "french", "gnu/linux", "mail", "workshop" ]
slug: "postfix-workshop"
---

<!-- prologue -->

{{< lead >}}
installation d'un serveur mail mx postfix,
utilisation avec dovecot & thunderbird
{{< /lead >}}

<!-- article -->

## introduction

*meilleure lecture en mode sombre, coin haut droit*

je continue l'avancée des workshops avec serveur mail postfix pour envoi & réception de mails

pourra être utilisé via dovecot avec utilisateurs gnu/linux ou virtuels

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
subgraph 192.168.122.0/24
postfix[r303-deb12-poostfix<br><font color="#a9a9a9">192.168.122.10</font>]
bind9[r303-deb12-bind9<br><font color="#a9a9a9">192.168.122.11</font>]
thunderbird[r303-deb12-client<br><font color="#a9a9a9">192.168.122.12</font>]
pstf(Service Postfix)
bind(Service Bind9)
clients(Mozilla Thunderbird)
gw{NAT<br><font color="#a9a9a9">192.168.122.1</font>}
end

wan{WAN}
wan---gw
gw---postfix & bind9
gw---thunderbird
postfix-.-pstf
bind9-.-bind
thunderbird-.-clients
{{< /mermaid >}}

## vm postfix

modification nom d'hôte
```bash
hostnamectl set-hostname r303-deb12-postfix
```
attribution adresse ip statique
```bash
nano /etc/network/interfaces
```
```bash {linenos=inline, hl_lines=["9-11"], linenostart=4}
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug enp1s0
iface enp1s0 inet static
address 192.168.122.10/24
gateway 192.168.122.1
```

<!-- <mark>very important words</mark>

H<sub>2</sub>O

X<sup>2</sup> -->

installation paquet postfix & mailutils pour envoie/réception de mails entre utilisateurs

```bash
apt install -y postfix mailutils
```

> `Internet Site` -> `rzo.lan`

*pour que postfix propose de prendre un nom de domaine, qui sera finalement utilisé pour les mails*

si installation bien déroulée -> service postfix actif

```bash
systemctl status postfix
```

fichier de configuration global postfix `/etc/postfix/main.cf`

commente tout ce qui touche au tls car pas utilisé

ajout informations pour utilisation du service

```bash
nano /etc/postfix/main.cf
```
```bash {linenos=inline, hl_lines=["2-4", "6-8", "11-13", "17-21"], linenostart=26}
# TLS parameters
# smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
# smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
# smtpd_tls_security_level=may

# smtp_tls_CApath=/etc/ssl/certs
# smtp_tls_security_level=may
# smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache


mydomain = rzo.lan
# smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = r303-deb12-postfix.rzo.lan
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = $mydomain, $myhostname, localhost.$mydomain, localhost
# relayhost = 
mynetworks = 127.0.0.0/8 192.168.122.0/24 
home_mailbox = Maildir/
mailbox_size_limit = 51200000
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4
```
<!-- https://www.postfix.org/postconf.5.html -->
> `alias_maps` table des noms & des adresses de `mydestination`  
> `alias_database` table des noms d'usages de `alias_maps`  
> `myorigin` pas de nom de domaine -> ajoute celui dans fichier  
> `mydestination` domaines acceptés d'échange  
> `recipient_delimiter` truc@$mydomain & truc+random@$mydomain == les mêmes (pourriel)

*recipient_delimiter faut le laisser en vide ou laisser le +*

*mydestination changé le deuxième, est-ce qu'il avait eu un bug car précisé au lieu de réutiliser variable*

vérification syntaxique après édition

```bash
postfix check
```

redémarrage du service pour application des modifications

```bash
systemctl restart postfix
```

création de deux gnu/linux users

{{< alert icon="circle-info">}}
**Note**  mot de passe contingeant à l'authentification...
{{< /alert >}}

```bash
adduser --gecos "" user1 && adduser --gecos "" user2
```

connexion à l'un des deux users pour test d'envoi

```bash
su user1
```

```bash
mail user2
```
> Cc:  
> Subject: test envoi user2  
> contenu du mail  

envoi avec retour à la ligne puis <mark>CTRL + D</mark>

connexion sur l'utilisateur récepteur

```bash
su user2
```

vérification de la réception du mail

```bash
ls ~/Maildir/new/ | wc -l
```

`1` si un nouveau mail car fichier dans `~/Maildir/new/`

dossier `~/Maildir` car défini dans `/etc/postfix/main.cf`

### dovecot

serveur imap & pop3

installation du daemon imap de dovecot

```bash
apt install -y dovecot-imapd
```

*autres paquets dans la suite `dovecot-*`, e.g. `dovecot-ldap` pour support ldap*

fichiers de configuration de dovecot dans `/etc/dovecot/conf.d/`

<!-- https://doc.dovecot.org/configuration_manual/authentication/ -->

modification des méthodes d'authentification

```bash
nano /etc/dovecot/conf.d/10-auth.conf
```

précision de tout laisser passer en clair

```bash {linenos=inline, hl_lines=[6], linenostart=5}
# Disable LOGIN command and all other plaintext authentications unless
# SSL/TLS is used (LOGINDISABLED capability). Note that if the remote IP
# matches the local IP (ie. you're connecting from the same computer), the
# connection is considered secure and plaintext authentication is allowed.
# See also ssl=required setting.
disable_plaintext_auth = no
```

définition des méchanismes d'authentification (login obsolète mais toujours utilisé)

```bash {linenos=inline, hl_lines=[5], linenostart=96}
# Space separated list of wanted authentication mechanisms:
#   plain login digest-md5 cram-md5 ntlm rpa apop anonymous gssapi otp
#   gss-spnego
# NOTE: See also disable_plaintext_auth setting.
auth_mechanisms = plain login
```

modification de l'emplacement de destination des mails

```bash
nano /etc/dovecot/conf.d/10-mail.conf
```

```bash {linenos=inline, hl_lines=[9], linenostart=22}
# See doc/wiki/Variables.txt for full list. Some examples:
#
#   mail_location = maildir:~/Maildir
#   mail_location = mbox:~/mail:INBOX=/var/mail/%u
#   mail_location = mbox:/var/mail/%d/%1n/%n:INDEX=/var/indexes/%d/%1n/%n
#
# <doc/wiki/MailLocation.txt>
#
mail_location = maildir:~/Maildir
```

*pas de modification dans la gestion des logs `/etc/dovecot/conf.d/10-logging.conf`*

application des modifications

```bash
systemctl restart dovecot
```

vérification du fonctionnement

```bash
telnet -l user1 localhost 143
```
> a login user2 user2  

*où user2 l'utilisateur et le mot de passe*

### utilisateurs virtuels

création user `vmail` avec `/opt/messagerie` comme home directory

groupe `vmail` avec group id de 5000

```bash
groupadd -g 5000 vmail
```

création du user

```bash
useradd -g vmail -u 5000 vmail -d /opt/messagerie -m
```
> `-g` son groupe  
> `-u` user id de 5000  
> `-d` son répertoire utilisateur/home `~`  
> `-m` créer son `~` si inexistant  

indication à postfix du `vmail` & du `/opt/messagerie` pour la gestion des boites aux lettres

```bash
nano /etc/postfix/main.cf
```
```bash {linenos=inline, hl_lines=["18-25"], linenostart=26}
# TLS parameters
# smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
# smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
# smtpd_tls_security_level=may

# smtp_tls_CApath=/etc/ssl/certs
# smtp_tls_security_level=may
# smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache


mydomain = rzo.lan
# smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = r303-deb12-postfix.rzo.lan
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = $mydomain, $myhostname, localhost.$mydomain, localhost
default_transport = dovecot
mail_spool_directory = /opt/messagerie/
virtual_mailbox_base = /opt/messagerie/
virtual_mailbox_domains = hash:/etc/postfix/vdomain
virtual_mailbox_maps = hash:/etc/postfix/vmail
virtual_alias_maps = hash:/etc/postfix/valias
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000
# relayhost = 
mynetworks = 127.0.0.0/8 192.168.122.0/24 
home_mailbox = Maildir/
mailbox_size_limit = 51200000
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4
```
> `default_transport` protocole/serveur d'envoi, par défaut smtp  
> `mail_spool_directory` dossier de stockage des mails  
> `virtual_mailbox_domains` liste domaines où postfix destinataire  
> `virtual_mailbox_maps` adresses valides de `virtual_mailbox_domains`  
> `virtual_uid_maps` user id pour écrire les mails  
> `virtual_uid_maps` pareil que `virtual_uid_maps` pour group id

définition du domaine virtuel

```bash
nano /etc/postfix/vdomain
```
```bash {linenos=inline, hl_lines=[1], linenostart=1}
rzo.lan #
```

création de messageries virtuelles *accordément `virtual_mailbox_maps`*

```bash
nano /etc/postfix/vmail
```

```bash {linenos=inline, hl_lines=["1-3"], linenostart=1}
xeylou@rzo.lan rzo.lan/xeylou/
testing@rzo.lan rzo.lan/testing/
admin@rzo.lan rzo.lan/admin/
```

définition des alias virtuels pour ces utilisateurs *vu `virtual_alias_maps`*

```bash
nano /etc/postfix/valias
```
```bash {linenos=inline, hl_lines=["1-3"], linenostart=1}
root: admin@rzo.lan
xeylou: xeylou@rzo.lan
```

création d'un daemon postfix pour dovecot/`vmail`

```bash
nano /etc/postfix/master.cf
```
```bash {linenos=inline, hl_lines=["1-2"], linenostart=138}
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -f ${sender} -d ${recipient}
```

prise en compte des 3 fichiers modifiés

```bash
postmap /etc/postfix/vdomain
postmap /etc/postfix/vmail
postalias /etc/postfix/valias
postfix check
```

### modification dovecot
*3.7*