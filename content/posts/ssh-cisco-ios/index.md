---
title: "ssh cisco ios"
date: 2023-10-03
draft: true
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

les équipements cisco (switchs, routeurs, asa...) tournent sur une distribution gnu/linux qui s'appelle `cisco ios`

sera couvert la configuration & la connexion en ssh à ces équipements via une paire de clés ssh dans le cadre d'un td/tp

### génération des clés

sera utilisée une vm ubuntu pour la génération des clés ssh

cisco ios supporte uniquement l'algorithme de chiffrement `rsa`

génération d'une paire de clés ssh dans `~/.ssh/` suivant l'algorithme de chiffrement rsa de longueur 2048 bits sans passphrase

```bash
ssh-keygen -t rsa -b 2048 -N "" -f "$HOME/.ssh/cisco-ssh.key"
```
> `-t rsa` choix de l'algorithme de chiffrement  
`-b 2048` précision de la longueur de la clé  
`-c "~/.ssh/cisco-ssh.key"` définition emplacement  
`-N ""` indication d'une passphrasse (nulle)

*clé privée `~/.ssh/cisco-ssh.key` & clé publique `~/.ssh/cisco-ssh.key.pub`*

la clé publique devra être renseignée sur l'équipement cisco

pour afficher son contenu

```bash
cat ~/.ssh/cisco-ssh.key.pub
```

sortie de la commande :

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtiK1iUvKUFL6Ff8l9iR37yN4DdIR0CXAkLoRze/WY1sEHz1qwDThApO31WVhJRoxzGwIMNyQjbWDWUH5GvcPPipzyp5U1chwNsYWa4KiXgvBh/iVEq+a4kr0I/4jPJJXkjWNeBplLkYAYRIGF8w4CuQPHE0mjRuAzxTtuvFOD6ZaIP+kEWmoLrDCRPorW2y3WV6/fGLuDoLnS6v32qcxTS5bevpy9Iqw8Y4mVRpIHbQsnKNo3HZY5aOC0bxWCZ6m+EVXJnD5UiQbZmikPVGKqydKgEr/ZuqEjKKFiB+ETTIjYqFM7HjuurVenEiJ0BlVkp8B6aOIbpypp4skZfi1 xeylou@UPPA20102
```

<!-- contenu effectif de la clé *sans `ssh-rsa` & `user@hostname`*

```bash {linenos=inline}
AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtiK1iUvKUFL6Ff8l9iR37yN4DdIR0CXAkLoRze/WY1sEHz1qwDThApO31WVhJRoxzGwIMNyQjbWDWUH5GvcPPipzyp5U1chwNsYWa4KiXgvBh/iVEq+a4kr0I/4jPJJXkjWNeBplLkYAYRIGF8w4CuQPHE0mjRuAzxTtuvFOD6ZaIP+kEWmoLrDCRPorW2y3WV6/fGLuDoLnS6v32qcxTS5bevpy9Iqw8Y4mVRpIHbQsnKNo3HZY5aOC0bxWCZ6m+EVXJnD5UiQbZmikPVGKqydKgEr/ZuqEjKKFiB+ETTIjYqFM7HjuurVenEiJ0BlVkp8B6aOIbpypp4skZfi1
``` -->

cisco ios supporte maximum 254 caractères par ligne de commande

la clé sera renseignée par paquet équivalents de 100 octets

```bash
fold -b -w100 ~/.ssh/cisco-ssh.key.pub
```

```bash {linenos=inline}
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtiK1iUvKUFL6Ff8l9iR37yN4DdIR0CXAkLoRze/WY1sEHz1qwDThApO31WVh
JRoxzGwIMNyQjbWDWUH5GvcPPipzyp5U1chwNsYWa4KiXgvBh/iVEq+a4kr0I/4jPJJXkjWNeBplLkYAYRIGF8w4CuQPHE0mjRuA
zxTtuvFOD6ZaIP+kEWmoLrDCRPorW2y3WV6/fGLuDoLnS6v32qcxTS5bevpy9Iqw8Y4mVRpIHbQsnKNo3HZY5aOC0bxWCZ6m+EVX
JnD5UiQbZmikPVGKqydKgEr/ZuqEjKKFiB+ETTIjYqFM7HjuurVenEiJ0BlVkp8B6aOIbpypp4skZfi1 xeylou@UPPA20102
```

<!-- ***faire mini script pour retirer ssh-rsa & user@hostname*** -->

*pour le copier : selectionner dans le terminal, <mark>CTRL + &#8593; + C</mark>* 

ce sera le contenu à coller dans la configuration de l'équipement

### configuration cisco

j'utiliserai l'équipement suivant (routeur)

```cisco
enable
configure terminal
hostname GASPARD
no ip domain-lookup
```

initialisation des paramètres ssh

<!-- renseignement d'un nom de domaine pour générer de clés non utilisées -->

<!-- initialisation d'une clé pour initialisation des dossiers, paramètres relatifs -->

passage de SSH1 à SSH2 (désactivation de SSH1)

génération d'une clé pour initier l'environnement

renseignement d'un nom de domaine contingeant à la création

<!-- changement de la version de ssh de 1 vers 2 -->

```cisco
ip domain-name rzo.local
crypto key generate rsa modulus 2048
ip ssh version 2
```

les lignes virtuelles sont des supports pour configuration à distance

les anciennes versions de cisco ios en ont 5 (0-4) & 16 pour les récentes (0-15) 

configuration des lignes virtuelles pour accepter uniquement ssh avec authentification enregistrée en local

```cisco
line vty 0 15
transport input ssh
login local
```


initialisation d'un utilisateur pour l'accès ssh

<!-- l'utilisateur `xeylou` *sans mot de passe* aura toutes les permissions `15` -->

```cisco
ip ssh pubkey-chain
username xeylou
```

renseignement de sa clé publique

```cisco
key-string
```
> Coller le contenu de la clé ici

monter l'utilisateur en privilège pour accèder au menu enable

```cisco
line vty 0 15
ip ssh pubkey-chain
username xeylou privilege 15
```

```cisco
exit
exit
exit
exit
```

désactivation de l'authentification par mot de passe en ssh

```cisco
no ip ssh server authenticate user password
no ip ssh server authenticate user keyboard
```

### vérifications

concordance des clés sur l'équipement

```cisco
show running-config | begin pubkey
```

sur la vm ubuntu

```cisco
ssh-keygen -l -f $HOME/.ssh/cisco-ssh.key.pub
```

tentative de connexion depuis vm ubuntu

```cisco
ssh xeylou@ip-router-accessible
```

### références
https://networklessons.com/uncategorized/ssh-public-key-authentication-cisco-ios#Linux

LUI
https://medium.com/wxit/ssh-public-key-authentication-on-cisco-ios-52064bee5685

https://nsrc.org/workshops/2016/renu-nsrc-cns/raw-attachment/wiki/Agenda/Using-SSH-public-key-authentication-with-Cisco.htm#removing-passwords

https://networklessons.com/uncategorized/ssh-public-key-authentication-cisco-ios#Linux