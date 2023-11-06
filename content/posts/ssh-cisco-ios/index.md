---
title: "ssh cisco ios"
date: 2023-10-03
draft: false
tags: [ "cisco", "french", "gnu/linux", "workshop" ]
series: ["r301"]
series_order: 1
slug: "ssh-cisco-ios"
---

<!-- prologue -->

{{< lead >}}
authentification par  
clés ssh sur équipements cisco
{{< /lead >}}

<!-- article -->

### introduction

les équipements cisco (switchs, routeurs, asa...) tournent sur une distribution gnu/linux `cisco ios`

sera couvert la configuration & la connexion en ssh à ces équipements via une paire de clés ssh

### génération des clés

sera utilisée une vm ubuntu pour la génération des clés ssh

cisco ios supporte uniquement l'algorithme de chiffrement `rsa`

la taille de la clé est à votre convenance (1024, 2048, 4096...)

génération d'une paire de clés ssh dans `~/.ssh/` suivant l'algorithme de chiffrement rsa de longueur 1024 bits sans passphrase

*taille minimum clé en rsa avec ssh en version 2: 768, j'ai pris 1024 car plus courant*

{{< alert icon="circle-info">}}
**Note** retenez la longueur de la clé si vous la changez, elle sera utile plus tard
{{< /alert >}}

```bash
ssh-keygen -t rsa -b 1024 -N "" -f "$HOME/.ssh/cisco-ssh"
```
> `-t rsa` choix de l'algorithme de chiffrement  
`-b 4096` précision longueur de la clé  
`-c "~/.ssh/cisco-ssh.key"` définition de leur emplacement  
`-N ""` indication passphrasse (nulle)

*clé privée `~/.ssh/cisco-ssh`, clé publique `~/.ssh/cisco-ssh.pub`*

la clé publique devra être renseignée sur l'équipement cisco

pour afficher son contenu

```bash
cat ~/.ssh/cisco-ssh.pub
```

exemple de sortie de la commande

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDXRp1IYBPwCUtXXwAlY3ewRY6lb9zO+LQ80Ynb1hLFq58F+3ui+MoyRYrD4uIK8Z3B91nQf0zhrmYGKVQHpdgvoWclp8E0QUcwAuWdZLl3zTt5nz97+h10yFg9eTnAYyPOZpaC5J/Obw34yM1pJAWPPrFo+no6KslsFNgFjOlvlQ== xeylou@null
```

le contenu effectif de la clé est sans le `ssh-rsa` au début & le commentaire en fin

la clé peut être renseignée avec ces informations quand même

cependant, tout est en une seule ligne

cisco ios supporte maximum 254 caractères par ligne de commande

la clé sera renseignée par paquets équivalents de 72 octets

```bash
fold -b -w 72 ~/.ssh/cisco-ssh.pub
```

exemple de sortie de la commande

<!-- AVANT J'AVAIS LAISSE SSH-RSA AU DEBUT -->

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDXRp1IYBPwCUtXXwAlY3ewRY6lb9zO+LQ8
0Ynb1hLFq58F+3ui+MoyRYrD4uIK8Z3B91nQf0zhrmYGKVQHpdgvoWclp8E0QUcwAuWdZLl3
zTt5nz97+h10yFg9eTnAYyPOZpaC5J/Obw34yM1pJAWPPrFo+no6KslsFNgFjOlvlQ== xey
lou@null
```

ce sera le contenu à coller dans la configuration de l'équipement

{{< alert icon="circle-info">}}
**Note**  *pour le copier depuis un terminal* <mark>CTRL + &#8593; + C</mark>
{{< /alert >}}

### configuration sur routeur

un cisco 2901 configuré comme suivant

```bash
enable
configure terminal
hostname GASPARD
no ip domain-lookup
```

génération d'une clé rsa de 1024 bits pour initier l'environnement ssh

renseignement d'un domaine contingeant à la création

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
**Générez une clé de la même longueur que celle de la vm**
{{< /alert >}}

```bash
ip domain-name rzo.local
crypto key generate rsa modulus 1024
```

création d'un utilisateur pour la connexion

utilisation de l'algorithme de chiffrement sha256 au lieu de md5 par défaut (256 bits contre 128)

```bash
username xeylou privilege 15 algorithm-type sha256 secret motdepasse
```
> `privilege 15` mêmes permissions que enable  
`algorithm-type sha256` choix méthode de chiffrement du mot de passe  
`secret motdepasse` définition d'un mot de passe *(optionnel)*

les lignes virtuelles sont des supports pour accéder à l'interface de commande cisco à distance

les anciennes versions de cisco ios en ont 5 (0-4) sinon 16 (0-15) 

configuration des lignes virtuelles pour y accéder uniquement par une connexion en ssh enregistrée sur la base d'utilisateur locale

```bash
line vty 0 15
transport input ssh
login local
```

passage de ssh version 1 à 2 (désactivation de la version 1)

```bash
ip ssh version 2
```

importation de la clé publique à l'utilisateur `xeylou`

```bash
ip ssh pubkey-chain
username xeylou
key-string
```
> coller la clé publique effective ici

pour indiquer la fin de la clé
```bash
exit
```

désactivation de tous les types d'authentification sauf par clé ssh *(publickey)*

ces commandes peuvent ne pas être supporté par la version de cisco ios utilisée

<!--
Public-key authentication method

Keyboard-interactive authentication method

Password authentication method
-->

```bash
no ip ssh server authenticate user password
no ip ssh server authenticate user keyboard
```

attribution d'un adresse ip à une des interfaces

```bash
int g0/0
ip address 192.168.0.1 255.255.255.0
no shut
```

### configuration sur switch

la configuration ssh est identique

```bash
enable
configure terminal
hostname SW7
no ip domain-lookup
ip domain-name rzo.lan
crypto key generate rsa modulus 4096
username xeylou privilege 15 algorithm-type sha256 secret motdepasse
line vty 0 15
login local
transport input ssh
ip ssh version 2
ip ssh pubkey-chain
username xeylou
key-string
```
> renseignement du contenu effectif de la clé publique
```bash
exit
no ip ssh server authenticate user password
no ip ssh server authenticate user keyboard
```

configuration de l'interface d'accès qui sera un vlan pour les switchs

*un vlan dédié serait préférable*

```bash
int vlan 1
ip add 192.168.0.2 255.255.255.0
no shut
```

### connexion ssh

configuration des commandes `ssh gaspard` & `ssh sw7` pour se connecter aux équipements

sur l'hôte qui accédera aux équipements

```bash
nano ~/.ssh/config
```

cisco ios utilise des protocoles obsolètes que openssh refuse d'utiliser par défaut

renseignement de ceux-ci dans la configuration des alias

pour le routeur

```bash {linenos=inline}
Host gaspard
  hostname = 192.168.0.1
  user = xeylou
  KexAlgorithms = diffie-hellman-group-exchange-sha1
  HostKeyAlgorithms = ssh-rsa
  PubKeyAcceptedAlgorithms = ssh-rsa
  IdentityFile "~/.ssh/cisco-ssh"
```
> `KexAlgorithms` changement d'algorithme d'échange de clé  
`HostKeyAlgorithms` chiffrement proposé par la vm ubuntu  
`PubKeyAcceptedAlgorithms` pareil par l'équipement  

manipulation supplémentaire à faire pour l'alias du switch

les ciphers définissent les algorithmes utilisés pour sécuriser la connexion ssh (ne pas transmettre en clair dès le départ)

rajout d'une ligne pour définir un cipher supporté par les switchs

```bash {linenos=inline, hl_lines=8, linenostart=9}
Host sw7
  hostname = 192.168.0.2
  user = xeylou
  KexAlgorithms = diffie-hellman-group-exchange-sha1
  HostKeyAlgorithms = ssh-rsa
  PubKeyAcceptedAlgorithms = ssh-rsa
  IdentityFile "~/.ssh/cisco-ssh"
  Ciphers aes256-cbc
```

connexion depuis la vm ubuntu

```bash
ssh gaspard
ssh sw7
```

<!-- ### références
https://networklessons.com/uncategorized/ssh-public-key-authentication-cisco-ios#Linux

LUI
https://medium.com/wxit/ssh-public-key-authentication-on-cisco-ios-52064bee5685

https://nsrc.org/workshops/2016/renu-nsrc-cns/raw-attachment/wiki/Agenda/Using-SSH-public-key-authentication-with-Cisco.htm#removing-passwords

https://networklessons.com/uncategorized/ssh-public-key-authentication-cisco-ios#Linux -->

### supplément

vérification concordance des clés

génération d'une empreinte (fingerprint) des clés publiques des deux côtés (équipements & machine cliente) savoir si elles sont jumelles

sur les équipements

```bash
show running-config | begin pubkey
```

comparable au hash sur la vm ubuntu

```bash
ssh-keygen -l -f $HOME/.ssh/cisco-ssh.key.pub
```

définition d'une acl pour n'autoriser uniquement les adresses ip locales à se connecter en ssh

```bash
enable
configure terminal
ip access-list standard SSH_ACL
permit 192.168.0.0 0.0.0.255
line vty 0 15
access-class SHH_ACL in
```

ajout d'un timeout de 10 minutes (inactivité) *sinon infini*

```bash
exec timeout 10 0
```

définition de maximum 3 tentatives de connexion *ralentissement bruteforce*

```bash
ip ssh authentication-retries 3
service tcp-keepalives-in
service tcp-keepalives-out
```

activation de scp pour transfert de fichiers via ssh

```bash
ip scp server enable
```