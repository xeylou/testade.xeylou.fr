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

la taille des clés est à votre convenance (1024, 2048, 4096... bits)

je recommande 1024 bits, les processeurs des équipements cisco à l'iut sont vieux donc prennent du temps pour des tailles de clés plus élevées...

génération d'une paire de clés ssh dans `~/.ssh/` suivant l'algorithme de chiffrement rsa avec une longueur 1024 bits, sans passphrase

{{< alert icon="circle-info">}}
**Note** si vous changez la longueur de la clé, retenez la pour plus tard
{{< /alert >}}

```bash
ssh-keygen -t rsa -b 1024 -N "" -f "$HOME/.ssh/cisco-ssh"
```
> `-t rsa` choix de l'algorithme de chiffrement  
`-b 1024` précision de la longueur de la clé  
`-c "~/.ssh/cisco-ssh.key"` définition de leur emplacement  
`-N ""` indication passphrasse (aucune)

*clé privée `~/.ssh/cisco-ssh`, clé publique `~/.ssh/cisco-ssh.pub`*

*la taille minimum d'une clé rsa avec ssh en version 2 est de 768 bits, j'ai préféré prendre 1024 car plus courant*

la clé publique devra être renseignée sur l'équipement cisco

pour afficher son contenu

```bash
cat ~/.ssh/cisco-ssh.pub
```

exemple de sortie de la commande

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDXRp1IYBPwCUtXXwAlY3ewRY6lb9zO+LQ80Ynb1hLFq58F+3ui+MoyRYrD4uIK8Z3B91nQf0zhrmYGKVQHpdgvoWclp8E0QUcwAuWdZLl3zTt5nz97+h10yFg9eTnAYyPOZpaC5J/Obw34yM1pJAWPPrFo+no6KslsFNgFjOlvlQ== xeylou@null
```

le contenu effectif de la clé serait sans le `ssh-rsa` au début & le commentaire en fin (ici `xeylou@null`)

la clé peut être renseignée avec ces informations quand même

cependant, elle occupe une seule grande ligne

or, cisco ios supporte maximum 254 caractères par ligne de commande

la clé sera renseignée par paquets équivalents de 72 octets

```bash
fold -b -w 72 ~/.ssh/cisco-ssh.pub
```

exemple de sortie de la commande

<!-- AVANT J'AVAIS LAISSE SSH-RSA AU DEBUT -->

```bash {linenos=table}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDXRp1IYBPwCUtXXwAlY3ewRY6lb9zO+LQ8
0Ynb1hLFq58F+3ui+MoyRYrD4uIK8Z3B91nQf0zhrmYGKVQHpdgvoWclp8E0QUcwAuWdZLl3
zTt5nz97+h10yFg9eTnAYyPOZpaC5J/Obw34yM1pJAWPPrFo+no6KslsFNgFjOlvlQ== xey
lou@null
```

ce sera le contenu à coller dans la configuration de l'équipement

{{< alert icon="circle-info">}}
**Note**  *pour le copier depuis un terminal, selectionnez puis faites* <mark>CTRL + &#8593; + C</mark>
{{< /alert >}}

### configuration sur routeur

pour un routeur cisco 2901 configuré comme suivant

```bash
enable
configure terminal
hostname GASPARD
no ip domain-lookup
```

renseignement d'un domaine contingeant à la création de l'environnement ssh (pas important)

génération d'une paire de clés rsa 1024 bits pour initier l'environnement ssh

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
**Générez une paire de clés de même longueur que celles générées sur la vm**
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

les anciennes versions de cisco ios en ont 5 (0-4) sinon 16 (0-15), && encore ça peut varier...

configuration des lignes virtuelles pour y accéder uniquement via une connexion ssh enregistrée sur la base d'utilisateurs locale

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
> coller la clé publique découpée sur la vm ici

indication de la fin de la clé
```bash
exit
```

désactivation de tous les types d'authentification sauf par clé ssh *(publickey)*

ces commandes peuvent ne pas être supportées par la version de cisco ios utilisée, je les donne quand même

<!--
Public-key authentication method

Keyboard-interactive authentication method

Password authentication method
-->

```bash
no ip ssh server authenticate user password
no ip ssh server authenticate user keyboard
```

attribution d'une adresse ip à une des interfaces du routeur

```bash
int g0/0
ip address 192.168.0.1 255.255.255.0
no shut
```

### configuration sur switch

la configuration ssh est identique pour un switch

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
> renseignement de la clé publique ici
```bash
exit
no ip ssh server authenticate user password
no ip ssh server authenticate user keyboard
```

configuration de l'interface d'accès qui sera un vlan

*un vlan dédié serait préférable, mais bon!*

```bash
int vlan 1
ip add 192.168.0.2 255.255.255.0
no shut
```

### connexion ssh

configuration des commandes `ssh gaspard` & `ssh sw7` pour se connecter aux équipements depuis la vm

sur l'hôte qui accédera aux équipements (la vm)

```bash
nano ~/.ssh/config
```

cisco ios utilise des protocoles obsolètes que openssh refuse d'utiliser par défaut

renseignement de ceux-ci dans la configuration des alias

renseignement pour le routeur

```bash {linenos=table}
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

une manipulation supplémentaire est à faire pour le switch

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

connexion en ssh depuis la vm ubuntu

```bash
ssh gaspard
ssh sw7
```

*pensez à être sur le même réseau que les équipements*

à cette étape, vous devriez normalement pouvoir vous connecter au routeur & au switch sans avoir à renseigner de mot de passe

une fois une connexion ssh active initiée, vous êtes au même niveau qu'un `enable` sur un port console (tous les droits)

je suis toujours là si des choses se sont mal passées ou que tout est vraiment nul

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

définition d'une acl pour autoriser uniquement les adresses ip locales à se connecter en ssh

```bash
enable
configure terminal
ip access-list standard SSH_ACL
permit 192.168.0.0 0.0.0.255
line vty 0 15
access-class SHH_ACL in
```

ajout d'un timeout au bout de 10 minutes d'inactivité *sinon infini*

```bash
exec timeout 10 0
```

définition de maximum 3 tentatives de connexion *ralentissement de bruteforce*

```bash
ip ssh authentication-retries 3
service tcp-keepalives-in
service tcp-keepalives-out
```

activation de scp pour transfert de fichiers via ssh

```bash
ip scp server enable
```