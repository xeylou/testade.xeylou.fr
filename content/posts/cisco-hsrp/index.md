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
hsrp sur routeurs cisco
{{< /lead >}}

<!-- article -->

## introduction

dernier article de la série des explications sur le module r301, dédié au protocole hsrp

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

deux routeurs se partagent une adresse ip virtuelle, ici 192.168.0.1

les machines du réseau local PC1 & PC2 utilisent l'adresse virtuelle comme passerelle par défaut

hsrp définit un routeur comme `actif` R1 & l'autre comme `passif` R2

les routeurs communiquent entre eux pour savoir qui redirige le traffic de l'ip virtuelle : si l'actif n'est plus présent, le deuxième routeur en "standby" prend le relai

le routeur passif R2 prendra la redirection si il ne reçoit plus de message hsrp hello du routeur R1 

si R1 renvoie des messages hello par la suite, il reprendra la redirection

le routeur avec la priorité la plus haute sera l'actif, sera le premier routeur avec la priorité inférieure la plus haute celui qui reprendra, & en suivant...

les routeurs se partagent leur configuration, l'intervale de temps de synchronisation peut être défini, pareil pour les messages hello

## implémentation

configuration du routeur actif R1, avec une priorité de 110

```bash {hl_lines=["7-9"]}
enable
configure terminal
hostname R1
no ip domain-lookup
interface fa0/0
ip address 192.168.0.2 255.255.255.0
standby 100 ip 192.168.0.1
standby 100 priority 110
standby 100 preempt
no shutdown
end
```
> `100` numéro groupe hsrp (applicable ensuite)
>
> `standby 100 ip 192.168.0.1` définition adresse ip virtuelle
>
> `standby 100 priority 110` numéro de priorité pour ce routeur
>
> `standby 100 preempt` active préemption -> si nouveau routeur avec plus haute priorité arrive dans un groupe, il devient l'actif

configuration du routeur passif R2, avec une priorité de 100

```bash {hl_lines=["7-9"]}
enable
configure terminal
hostname R2
no ip domain-lookup
interface fa0/0
ip address 192.168.0.3 255.255.255.0
standby 100 ip 192.168.0.1
standby 100 priority 100
standby 100 preempt
no shutdown
end
```

le routeur R1 a une priorité de `110` & R2 de `100`

R1 -> actif, R2 -> passif

pour tester la configuration, après configuration réseau du PC1 ou PC2, `ping -t 192.168.0.1` (ping à l'infini) depuis un pc

si lien coupé entre R1 & SW1 : après quelques timeout (5 secondes), les ping reprennent car R2 reprend la redirection

c'est de la haute disponibilité (redondance avec un système de bascule et réplication de la configuration) *resiliency != redundancy*

R2 prend le relai après environ 3 timeout car se laisse une marge d'erreur avant de s'attribuer l'ip virtuelle

quand R1 revient, un timeout est présent le temps qu'il reprenne l'adresse virtuelle