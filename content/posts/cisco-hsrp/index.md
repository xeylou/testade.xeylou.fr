---
title: "cisco hsrp"
date: 2023-10-22
draft: false
tags: [ "cisco", "french" ]
series: ["r301"]
series_order: 4
slug: "cisco-hsrp"
---

<!-- prologue -->

{{< lead >}}
utilisation du protocole  
hsrp sur routers cisco
{{< /lead >}}

<!-- article -->

## introduction

dernier article de la série des explications du module r301, dédié au protocole hsrp

son implémentation simple ne prend pas beaucoup de temps

## fonctionnement

*hot standby router protocol*

protocole de redondance de passerelle dans un réseau local

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
subgraph 192.168.0.1
r1{R1<br><font color="#a9a9a9">192.168.0.2</font>}
r2{R2<br><font color="#a9a9a9">192.168.0.3</font>}
end

sw1[SW1]
pc1[PC1]
pc2[PC2]

r1 --- sw1
r2 --- sw1
sw1 --- pc1 & pc2
{{< /mermaid >}}

deux routeurs se partagent une adresse ip virtuelle, ici 192.168.0.1, en plus des leur

les machines du réseau local (PC1 & PC2) utilisent l'adresse virtuelle comme passerelle

hsrp définit un routeur comme `actif`, ici R1 & l'autre comme `passif` - R2

les routeurs communiquent entre eux pour savoir qui redirige le traffic de l'ip virtuelle & quand

le routeur passif prendra la redirection si il ne reçoit plus de message hsrp (hello) du routeur R1 

si celui-ci renvoie des messages par la suite, il reprendra la redirection

le routeur avec la priorité la plus haute sera l'actif

## implémentation

configuration du routeur actif R1, avec une priorité de 110

```bash
enable
configure terminal
hostname R1
no ip domain-lookup
interface fa0/0
ip address 192.168.0.2 255.255.255.0

standby 100 ip 192.168.0.1
standby 100 priority 110
standby 100 preempt
end
```
> `100` numéro du groupe hsrp
>
> `standby 100 ip 192.168.0.1` définition adresse ip virtuelle
>
> `standby 100 priority 110` numéro de priorité pour ce routeur
>
> `standby 100 preempt` active préemption -> si nouveau routeur avec plus haute priorité arrive dans un groupe, il devient l'actif

configuration du routeur passif R2, avec une priorité de 100

```bash
enable
configure terminal
hostname R2
no ip domain-lookup
interface fa0/0
ip address 192.168.0.2 255.255.255.0

standby 100 ip 192.168.0.2
standby 100 priority 100
standby 100 preempt
end
```