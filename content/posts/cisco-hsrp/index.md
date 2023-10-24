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
graph LR
subgraph HSRP (192.168.0.1)
r1{R1}
r2{R2}
end

sw1[SW1]
pc1[PC1]
pc2[PC2]

r1 ---|192.168.0.2| sw1
r2 ---|192.168.0.3| sw1
sw1 --- pc1 & pc2
{{< /mermaid >}}

deux routeurs se partagent une adresse ip virtuelle en plus des leurs

les machines du réseau local utilisent l'adresse virtuelle comme passerelle

hsrp définit un routeur comme `actif` & l'autre comme `passif`

les routeurs communiquent entre eux pour s'avoir qui redirige le traffic de l'ip virtuelle

le routeur passif prendra la redirection si il ne reçoit plus de message du routeur 

si celui-ci renvoie des messages ensuite, il reviendra actif & reprendra la redirection

le routeur avec la priorité la plus haute sera l'actif

## implémentation

R1

```bash {hl_lines=["8-10"]}
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
> `100` est numéro du groupe hsrp

> `standby 100 ip 192.168.0.1` définition adresse ip virtuelle

> `standby 100 priority 110` numéro de priorité du routeur configuré
>
> optionnel:
> `standby 100 preempt` active la préemption -> si nouveau routeur avec plus haute priorité dans un groupe, il le devient immédiatement celui actif

R2

```bash {hl_lines=["8-10"]}
enable
configure terminal
hostname R2
no ip domain-lookup
interface fa0/0
ip address 192.168.0.2 255.255.255.0

standby 100 ip 192.168.0.1
standby 100 priority 100
standby 100 preempt
end
```

le routeur R1 a une priorité de `110`, R2 `100`

R1 -> actif, R2 -> passif

pour tester la configuration, vous pouvez `ping -t 192.168.0.1` (ping à l'infini, comme sur distributions gnu/linux)

si lien coupé entre R1 & SW1 : après quelques timeout, les ping reprennent car R2 reprend la redirection