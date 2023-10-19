---
title: "inter-vlan cisco"
date: 2023-10-18
draft: true
tags: [ "cisco", "french" ]
series: ["r301"]
series_order: 2
slug: "inter-vlan"
---

<!-- prologue -->

{{< lead >}}
prise en main du routage  
inter-vlan sur équipements cisco
{{< /lead >}}

<!-- article -->

## introduction

je crée finalement une série d'articles dédiés à r301, le module étant très riche & évalué en pratique

cet article est dédié à la compréhension & l'étude des principes liés au routage inter-vlan sur des équipements cisco, pas à de la technique ou une utilisation avancée 

## rappels vlan

<!-- les vlan *virtual lan* servent à faire de la ségmentation réseau sur la couche 2 du modèle osi -->

les vlan servent à faire de la ségmentation réseau

les machines d'un vlan ne pourront communiquer qu'avec les machines de ce même vlan (ségmentation)

<!-- ainsi, les vlans seuls permettent de séparer les différents réseaux présents sur un équipement -->

l'attribution des vlan à des équipements se fait généralement sur un switch

les ports d'un switch sont associés à des vlans, les machines derrière ces ports sont en conséquent affectées à des vlan sans qu'elles ne le sachent

de ce fait, les machines du vlan `X` auront accès aux autres machines du réseau associées au vlan `X`

*side note: tous les ports des switchs cisco ont un vlan par défaut & natif : le vlan 1, donc tout le monde se voit partout*

## principes d'inter-vlan

les vlans ségmentarisent les réseaux sur la couche 2 du modèle OSI

il n'est pas possible de les contourner en remontant les couches, ni en les descendant (aller sur le support...)

cependant, il est parfois nécessaire de faire communiquer des machines appartenant à des vlan différents

*e.g. dans un réseau d'entreprise avec un vlan `COMPTA` & un vlan `SECRETAIRES`, les deux auraient besoin d'accéder au vlan `SERVICES`*

une machine devrait donc se charger de faire passer les trâmes d'un vlan à un autre

le remède à tout ça serait un `routeur`, transférant des trames d'un vlan à un autre, plutôt que d'un réseau à un autre

cela existe & est disponible sur tous les routeurs cisco

leur spécificité étant qu'ils font du routage entre les vlan : du `routage inter-vlan`

## notions annexes

ces notions seront abordés pour la suite

un lien peut transporter plusieurs vlans, mais ces vlan ne se verront pas

il faut que les deux ports, les deux extrémités du lien, soient configurés de la même manière d'un bout à l'autre

c'est le principe d'un lien `trunk`

## méthodes d'inter-vlans

un routeur peut faire du routage inter-vlan de la même manière qu'il le fait pour des réseaux physiques

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
r1{R1}
sw1[SW1]
sw2[SW2]
pc1[PC1]
pc2[PC2]

r1 ---|vlan 10| sw1
r1 ---|vlan 20| sw2
sw1 ---|vlan 10| pc1
sw2 ---|vlan 20| pc2
{{< /mermaid >}}

cependant, selon les réseaux, un bien plus grand nombre de vlan peuvent être amenés à être routés

l'idée de garder un lien par vlan devient alors insensée

l'utilisation de ports en mode trunk est alors recommandé, vu [notions annexes](#notions-annexes), pour transporter plusieurs vlan

le routage devenant alors `on stick`

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
r1{R1}
sw1[SW1]
pc1[PC1]
pc2[PC2]

r1 ---|trunk<br>vlan 10, 20<br>| sw1
sw1 ---|vlan 10| pc1
sw1 ---|vlan 20| pc2
{{< /mermaid >}}

<!-- exemples simples d'application des différentes [méthodes d'inter-vlan](#méthodes-inter-vlans) -->

<!-- https://www.ccnablog.com/inter-vlan-routing/#:~:text=Configuring%20inter-VLAN%20routing%20using%20router-on-a-stick%201%20Step%201.,4%20Step%204.%20...%205%20Step%205.%20 -->

## routage simple

comme dit [méthodes d'inter-vlan](#méthodes-dinter-vlans), le routage peut se faire en utilisant des liens physiques

cette méthode n'est pas utilisée car serait beaucoup trop chère (acheter un routeur physique 48 ports ça n'existe pas...)

je l'expose tout de même ici car demandé en td

les notions de routage restent les mêmes, les vlan ayant des adresses réseau différentes -> c'est comme des réseaux physiques

configuration du switch SW1

*les ports d'un siwtch sont UP par défaut*

```bash
enable
configure terminal
hotsname SW1
no ip domain-lookup
int g0/0
switchport access vlan 10
exit
int g0/1
switchport access vlan 20
exit
int g0/2
switchport access vlan 10
exit
int g0/3
switchport access vlan 20
exit
end
```

configuration du routeur R1

```bash
enable
configure terminal
hotsname R1
no ip domain-lookup
int g1/0
ip address 192.168.1.1 255.255.255.0
no shut
exit
int g1/1
ip address 192.168.2.1 255.255.255.0
no shut
exit
end
```

après avoir mis une adresse ip à PC1 & PC2 selon leur vlan, ils devraient pouvoir se pinguer entre eux

## routage on stick

le routage inter-vlan en on stick possède les mêmes caractéristiques que le [simple](#routage-simple)

la seule exception reste l'utilisation d'un lien `trunk` entre le switch & le routeur pour encapsuler les vlan

