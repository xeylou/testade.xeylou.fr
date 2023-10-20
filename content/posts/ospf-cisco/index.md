---
title: "ospf cisco"
date: 2023-10-20
draft: false
tags: [ "cisco", "french" ]
series: ["r301"]
series_order: 3
slug: "ospf-cisco"
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

pour une utilisation avancée, je vous laisse vous renseigner par vous-même

## routage dynamique

dans notre utilisation des routeurs cisco, nous étions conformé au routage statique

après le renseignement des adresses ip sur les interfaces d'un routeur, le routage se faisait en conséquent ou en ajoutant manuellement des routes à la table de routage

cependant, pour gérer un réseau de routeurs (15, 20, 50 routeurs...) -> indiquer manuellement les routes sur chaque routeur peut vite devenir embêtant à la maintenance

en opposition avec le routage statique, le routage dynamique aux routeurs de communiquer pour se partager leurs routes

les algorithmes de recherche & de partage des routes sont définis par leur(s) `protocole(s) de routage`

parmis les protocoles les plus connus: rip (choissant le chemin le plus court) & ospf (regardant l'état des liens entre les routeurs - débits, disponibilité...)

## ospf

*open shortest path first*

est un protocole non affilié à cisco, regardant l'état des liens entre les routeurs, construisant son interprêtation du réseau

celui-ci créer un `coup` se basant sur la bande passante pour éviter la congestion & sur la disponibilité (down ou up)

les meilleurs routes sont alors crées & partagées entre eux