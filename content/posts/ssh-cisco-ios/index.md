---
title: "ssh cisco ios"
date: 2023-10-03
draft: false
tags: [ "french", "gnu/linux", "workshop" ]
slug: "ssh-cisco-ios"
---

<!-- prologue -->

{{< lead >}}
authentification ssh par  
clés sur équipements cisco
{{< /lead >}}

<!-- article -->

### introduction

les équipements cisco (switchs, routeurs, asa...) tournent sur une distribution gnu/linux `cisco ios`

sera couvert la configuration & la connexion en ssh à un routeur & un switch via une paire de clés ssh

la démarche reste la même entre ces équipements

### génération des clés

sera utilisée une vm ubuntu pour la génération des clés ssh

cisco ios supporte uniquement l'algorithme de chiffrement `rsa`

la taille de la clé est personnel (1024, 2048, 4096...)

génération d'une paire de clés ssh dans `~/.ssh/` suivant l'algorithme de chiffrement rsa de longueur 4096 bits sans passphrase

```bash
ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/cisco-ssh"
```
> `-t rsa` choix de l'algorithme de chiffrement  
`-b 4096` précision longueur de la clé  
`-c "~/.ssh/cisco-ssh.key"` définition emplacement  
`-N ""` indication passphrasse (nulle)

*clé privée `~/.ssh/cisco-ssh` & clé publique `~/.ssh/cisco-ssh.pub`*

la clé publique devra être renseignée sur l'équipement cisco

pour afficher son contenu

```bash
cat ~/.ssh/cisco-ssh.pub
```

exemple de sortie de la commande

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtiK1iUvKUFL6Ff8l9iR37yN4DdIR0CXAkLoRze/WY1sEHz1qwDThApO31WVhJRoxzGwIMNyQjbWDWUH5GvcPPipzyp5U1chwNsYWa4KiXgvBh/iVEq+a4kr0I/4jPJJXkjWNeBplLkYAYRIGF8w4CuQPHE0mjRuAzxTtuvFOD6ZaIP+kEWmoLrDCRPorW2y3WV6/fGLuDoLnS6v32qcxTS5bevpy9Iqw8Y4mVRpIHbQsnKNo3HZY5aOC0bxWCZ6m+EVXJnD5UiQbZmikPVGKqydKgEr/ZuqEjKKFiB+ETTIjYqFM7HjuurVenEiJ0BlVkp8B6aOIbpypp4skZfi1 xeylou@UPPA20102
```

le contenu effectif de la clé devra être utilisé (sans `ssh-rsa` & le commentaire en fin)

sauvegarde de la clé sans `ssh-rsa` & le commentaire `xeylou@UPPA20102`

```bash
cat ~/.ssh/cisco-ssh.pub | sed "s/ssh-rsa //g" | sed "s/ xeylou@UPPA20102//g" > ~/.ssh/cisco-ssh.pub
```

contenu de `~/.ssh/cisco-ssh.pub`

```bash {linenos=inline}
AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtiK1iUvKUFL6Ff8l9iR37yN4DdIR0CXAkLoRze/WY1sEHz1qwDThApO31WVhJRoxzGwIMNyQjbWDWUH5GvcPPipzyp5U1chwNsYWa4KiXgvBh/iVEq+a4kr0I/4jPJJXkjWNeBplLkYAYRIGF8w4CuQPHE0mjRuAzxTtuvFOD6ZaIP+kEWmoLrDCRPorW2y3WV6/fGLuDoLnS6v32qcxTS5bevpy9Iqw8Y4mVRpIHbQsnKNo3HZY5aOC0bxWCZ6m+EVXJnD5UiQbZmikPVGKqydKgEr/ZuqEjKKFiB+ETTIjYqFM7HjuurVenEiJ0BlVkp8B6aOIbpypp4skZfi1
```

la clé publique est en une seule ligne

cisco ios supporte maximum 254 caractères par ligne de commande

la clé sera renseignée par paquets équivalents de 72 octets

```bash
fold -b -w 72 ~/.ssh/cisco-ssh.pub
```

exemple de sortie de la commande

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtiK1iUvKUFL6Ff8l9iR37yN4DdIR0CXAkLoRze/WY1sEHz1qwDThApO31WVh
JRoxzGwIMNyQjbWDWUH5GvcPPipzyp5U1chwNsYWa4KiXgvBh/iVEq+a4kr0I/4jPJJXkjWNeBplLkYAYRIGF8w4CuQPHE0mjRuA
zxTtuvFOD6ZaIP+kEWmoLrDCRPorW2y3WV6/fGLuDoLnS6v32qcxTS5bevpy9Iqw8Y4mVRpIHbQsnKNo3HZY5aOC0bxWCZ6m+EVX
JnD5UiQbZmikPVGKqydKgEr/ZuqEjKKFiB+ETTIjYqFM7HjuurVenEiJ0BlVkp8B6aOIbpypp4skZfi1
```

ce sera le contenu à coller dans la configuration de l'équipement

{{< alert icon="circle-info">}}
**Note**  *pour le copier : selectionner dans le terminal puis* <mark>CTRL + &#8593; + C</mark>
{{< /alert >}}

### configuration routeur

modèle 2901 configuré comme suivant

```bash
enable
configure terminal
hostname GASPARD
no ip domain-lookup
```

génération d'une clé rsa de 4096 bits pour initier l'environnement ssh

renseignement d'un domaine contingeant à sa création

```bash
ip domain-name rzo.local
crypto key generate rsa modulus 4096
```

création d'un utilisateur pour la connexion

utilisation de l'algorithme de chiffrement sha256 au lieu de md5 par défaut (256 bits contre 128)

```bash
username xeylou privilege 15 algorithm-type sha256 secret motdepasse
```
> `privilege 15` mêmes permissions que enable  
`algorithm-type sha256` choix méthode de chiffrement mot de passe  
`secret motdepass` définition d'un mot de passe *(optionnel)*


les lignes virtuelles sont des supports pour accèder à l'interface de commandes cisco à distance

les anciennes versions de cisco ios en ont 5 (0-4) sinon 16 (0-15) 

configuration des lignes virtuelles pour y accèder uniquement par une connexion en ssh enregistrée sur la base d'utilisateur locale

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
> coller la clé effective ici

<!-- désactivation de l'authentification par mot de passe en ssh

```bash
no ip ssh server authenticate user password
no ip ssh server authenticate user keyboard
``` -->
puis faire

```bash
exit
```

attribution d'un adresse ip à une des interfaces

```bash
int g0/0
ip address 192.168.0.1 255.255.255.0
no shut
```

### configuration switch

la configuration ssh est identique

```bash
en
conf t
hostname GASPARD
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

changement d'interface pour l'accès qui sera un vlan

```bash
int vlan 1
ip add 192.168.0.2 255.255.255.0
no shut
```

### connexion ssh

les commandes `ssh GASPARD` ou `ssh SW7` pourront être faites pour se connecter aux équipements

```bash
nano ~/.ssh/config
```
pour se connecter au routeur

```bash {linenos=inline}
Host GASPARD
  hostname = 192.168.0.1
  user = xeylou
  KexAlgorithms = diffie-hellman-group-exchange-sha1
  HostKeyAlgorithms = ssh-rsa
  PubKeyAcceptedAlgorithms = ssh-rsa
  IdentityFile "~/.ssh/cisco-ssh"
```

les ciphers vont définir l'algorithme utilisé pour initié la connexion ssh (ne pas transmettre dès le départ en clair)

rajout d'une ligne pour en définir un supporté par les switchs

pour se connecter au switch

```bash {linenos=inline, hl_lines=8}
Host SW7
  hostname = 192.168.0.2
  user = xeylou
  KexAlgorithms = diffie-hellman-group-exchange-sha1
  HostKeyAlgorithms = ssh-rsa
  PubKeyAcceptedAlgorithms = ssh-rsa
  Ciphers aes256-cbc
```

tentative de connexion depuis vm ubuntu

```bash
ssh GASPARD
ssh SW7
```

### références
https://networklessons.com/uncategorized/ssh-public-key-authentication-cisco-ios#Linux

LUI
https://medium.com/wxit/ssh-public-key-authentication-on-cisco-ios-52064bee5685

https://nsrc.org/workshops/2016/renu-nsrc-cns/raw-attachment/wiki/Agenda/Using-SSH-public-key-authentication-with-Cisco.htm#removing-passwords

https://networklessons.com/uncategorized/ssh-public-key-authentication-cisco-ios#Linux

### bonus

vérification concordance des clés

sur les équipements

```bash
show running-config | begin pubkey
```

comparable au hash sur la vm ubuntu

```bash
ssh-keygen -l -f $HOME/.ssh/cisco-ssh.key.pub
```

définition d'une acl pour accepter uniquemennt les adresses ip locales

```bash
en
conf t
ip access-list standard SSH_ACL
permit 192.168.0.0 0.0.0.255
line vty 0 15
access-class SHH_ACL in
```

ajout d'un timeout de 10 minutes (inactivité) *sinon infini*

```bash
exec timeout 10 0
```

définition de maximum 3 tentative de connexion *ralentissement bruteforce*

```bash
ip ssh authentication-retries 3
service tcp-keepalives-in
service tcp-keepalives-out
```

activation de scp pour transfert de fichiers via ssh

```bash
ip scp server enable
```