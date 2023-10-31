---
title: "cisco ospf"
date: 2023-10-20
draft: false
tags: [ "cisco", "french" ]
series: ["r301"]
series_order: 3
slug: "cisco-ospf"
---

<!-- prologue -->

{{< lead >}}
compréhension du protocole  
ospf sur routeurs cisco
{{< /lead >}}

<!-- article -->

## introduction

dans mon avancée sur les explications du module r301, je m'attaque au routage dynamique avec ospf

encore une fois, cette série est pour se familiariser aux principes des protocoles & aux commandes *- pour les tp*

ce n'est pas une application avancée pour les lab par exemple, c'est un point de départ, une documentation

## routage dynamique

dans notre utilisation des routeurs cisco, nous étions conformé au routage statique

après le renseignement des adresses ip sur ses interfaces, le routeur créait sa table de routage en conséquent, sinon nous ajoutions manuellement des routes

cependant, pour gérer des réseaux de routeurs (15, 20, 50 routeurs...) -> indiquer manuellement les routes sur chaque routeur peut vite devenir ennuyant, surtout à la maintenance

en opposition avec le routage statique, le routage dynamique permet aux routeurs de communiquer leur table de routage & donc de se partager leurs routes

les algorithmes de recherche & de partage des routes sont définis par leur(s) `protocole(s) de routage`

parmis les protocoles les plus connus: rip (choissant le nombre de routeur vers la destination le plus court) & ospf (préférant l'état des liens entre les routeurs - leur débit, disponibilité...)

## ospf

*open shortest path first*

est un protocole non affilié à cisco, regardant l'état des liens entre les routeurs, construisant son interprêtation du réseau

pour ceux qui l'ont vu en terminal, ospf est l'implémentation de l'algorithme de Dijkstra

celui-ci créer un `coût` se basant sur la bande passante *pour éviter la congestion* & sur la disponibilité du lien

voici un exemple d'utilisation de ospf

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph LR
r1{R1}
r2{R2}
r3{R3}

r1 ---|100 Mits/s| r2
r1 ---|10 Mbits/s| r3
r2 ---|100 Mbits/s| r3
{{< /mermaid >}}

ici, pour aller de R1 à R3, ospf préfèrera passer par R2

le coût d'utilisation de deux liens à 100 Mbits/s étant moins élevé que celui d'un lien à 10 Mbits/s

le protocole rip aurait pris le lien entre R1 & R3, ayant le moins de "sauts" entre les deux

une formule mathématique existe pour calculer les coûts, je préfère vous mettre un tableau pour ceux courants

<table><thead><tr><th>Bande passante</th><th>Coût OSPF</th></tr></thead><tbody><tr><td>10 Gbits/s</td><td>1</td></tr><tr><td>1 Gbits/s</td><td>1</td></tr><tr><td>100 Mbits/s</td><td>1</td></tr><tr><td>10 Mbits/s</td><td>10</td></tr><tr><td>1544 Kbps (série)</td><td>64</td></tr></tbody></table>

ospf peut sectariser par sous réseaux qu'il appelera des `area`

un ensemble de routeur font parti d'une area, deux area pouvant s'interconnecter pour échanger leurs routes

<!-- https://www.ictshore.com/free-ccna-course/ospf-understanding/ -->

les routeurs avec ospf configuré s'envoient des messages `hello` pour vérifier leur configuration

ces messages passent par différentes `STATES`, `full` signifiant qu'ils connaissent désormais les mêmes réseaux chacun

<!-- area, state (full c'est dernier bon), messages hello -->

<!-- ip ospf cost 999 ou bandwith 64 -->

## configuration

avant de commencer le routage dynamique, les adresses ip doivent être présentes sur les interfaces

suite à cela, la configuration de base de ospf peut commencer

```bash
router ospf 1
```
> numéro renseigné `router ospf 1` pour indiquer le numéro de la configuration

pour être identifié sur le réseau ospf, le routeur doit possèder un `id`

sans configuration, celui-ci est l'interface la plus haute configurée (loopback puis interfaces physiques)

cet id peut être changé en une commande, plutôt que de configurer une interface

```bash
router-id 1.1.1.1
```

sinon

```bash
interface loopback 0
ip address 1.1.1.1 255.255.255.255
```

les routes seront indiqués avec l'adresse considérée comme passerelle, appartenant à ce routeur

sera aussi renseigné le masque mais en inversé (wildcard) - e.g. 255.255.255.0 -> 0.0.0.255

sera aussi précisée la zone à laquelle appartient la route

suite à ça, reste qu'à indiquer les routes du routeur à ospf

```bash
network 192.168.0.1 0.0.0.255 area 1
```
> sous la forme `network <ip interface> <wildcard> area <numéro zone>`
>
> `area 1` un chiffre ou un nombre pour identifier la zone

## vérifications

vérifier ses voisins ospf

```bash
show ip ospf neighbor
```

voir si des routes sont crées par ospf

```bash
show ip route
```
> toutes les routes commençant par `O` sont apprises par ospf

regarder les états des messages `HELLO`

```bash
show ip ospf interface
```

pour une interface spécifique

```bash
show ip ospf interface se0/1/0
```

voir si ospf actif au niveau des protocoles de routage

```bash
show ip protocols
```

deux moyens de changer le coût d'une interface

```bash
interface se0/1/0
bandwith 64

interface se0/1/0
ip ospf cost 10
```

changer les intervales des messages `HELLO` ou `DEAD`

```bash
interface se0/1/1
ip ospf hello-interval 5
ip ospf dead-interval 20
```

<!-- ```bash
enable
configure terminal
hostname R3
no ip domain-lookup
enable secret class
line console 0
password cisco
login
exit

do show ospf neighbor
do show ip ospf interface
do show ip route ! O -> apprisent par ospf
do show ip protocols

interface se0/1/1
ip ospf cost 10

interface se0/1/0
ip ospf hello-interval 5
ip ospf dead-interval 20

do show ip ospf interface se0/1/0

int loopback 0
ip address 1.1.1.1 255.255.255.255

interface g0/0
bandwith 64 ! 64 Mbits/s

do write ! copy run start
``` -->