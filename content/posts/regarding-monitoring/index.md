---
title: "regarding monitoring"
date: 2023-11-18
draft: true
tags: ["gnu/linux", "monitoring", "open-source"]
slug: "regarding-monitoring"
---

<!-- prologue -->

{{< lead >}}
having a broader vision of monitoring,  
clarifying needs && decisions to make
{{< /lead >}}

<!-- article -->

## introduction

i already talked about nagios && centreon before, and as far as my understanding goes, i was confident talking about them

but then, someone asked me some help to chose an appropriate monitoring solution for his needs; && i wasn't able to do so

because in my understanding, i put aside the aspects to consider to deploy a monitoring solution, what makes people chosing a solution over another

i wanted to came back to him, fully understanding his needs, restrictions && wants, to provide an appropriate solution

this article aims to help you choosing an appropriate monitoring solution, based on studying your needs, ressources && infrastructure

## why need monitoring?

one of the most important point to clarify is: **why do you need monitoring?**

asking you this question will help you choose what type of monitoring will suit you the most

:warning: do not misunderstand: why you need to monitor && what you need to monitor

this part is at the founding of your monitoring implementation: you won't need to change your monitoring solution on the future if you __plan from the start your monitoring usecases, its purposes && on the future__

<!-- define a scope of what you are demanding for what you call monitoring, that will help you not getting stuck every abroad choices you'd make -->

## what to monitor

once you've clarified the reasons you need to do monitoring, now or in the future, it's time to define its scope by clarifying what to monitor

this part seems the most obvious as it is for smaller projects, but it's always good to plan down the scope of your actions

mainly, monitoring is used to keep an eye on services, hardware, uptime or whatever that needs to be watched repetitivly && automatically

but __taking the time to think of what you'd need to monitor, the possible individualities or unecessaries__ seems to be for the good to me

think of what kind of metrics you want to monitor, because it'll define what kind of monitoring solution will also suit your metrics

that can lead to more advanced usecases, not obvious from start, like service discovery, logging connections, activities...

making clear what you want to monitor will considerably reduce the scope of the solutions you'd have for your needs too

define the type of metrics you want to monitor, e.g. for website uptime, please don't go w/ big solutions, a simple uptime kuma is more than enough..

that could also lead to use more than one solution, because none of them check all your requirements: __take time to think && make down what you need or will need to monitor once__

## monitoring != statistics

an observation i'd like to make is the misconception that monitoring is statistics

they both deals w/ analysis && data, but it's important to distinguish they are fields w/ different focuses and responsibilities

__monitoring is to make sure that something is working as planned at a given time, statistics is to make sure that thing is evolving well__

you can do data analytics over monitored metrics, but not the other way arround, as well as you don't hire a Data Analyst guy to do monitoring stuff ._.

## targetted audience

depending on the targetted audience of your monitoring, inconspicuous restrictions could show up

in the case you monitor multiple sites from various companies, you'd maybe need to let them access on their monitored metrics

i could have also named this part "the difference between the personnal && the production use of monitoring"

if the targetted audience is you, you don't need to make that much effort to understand what you'd want from your monitoring, i guess...

for a production use, you'd have to consider more aspects that will maybe lead you to more corporate solutions for availability, scalability, data ease of access, graphical interfaces...

for personnal use, the criticality of your solution isn't to consider sometimes

## support needed

do you have time to maintain the integrity of your monitoring solution? especially if it's big

do you need someone to talk to fix bugs quickly, so you don't have to go through forums || community chats to investigate - if the solution is ever pointed...

a serious deployment could also integrate a subscription from the manufacturer to debug || troubleshoot its solution quickly - for production use

## hidden cost

the people maintaining the solution in your team can be a hidden cost: taking on his time to troubleshoot, debug updates, maintaining...

they sometimes they also need to form people on how to use or quickly troubleshoot, document etc.

for me, the biggest cost is the time took by people who are responsible for the solution: the time spent && the time that will be spend

other than people, hidden cost can show up later by your solution: ease of moving data *"sh\*\* i can dump the database..."*, the storage consumming place...

i consider **ongoing maintenance, potential scaling problems, risk analysis for serious production, repairability && flexibility cost** - higher they are, higher will be the degree of complexity of use as hidden cost

## overall budget

do i really need to go into details for this one?...



<!--

types de données à monitorer, nombre d'hôtes ou de services à considérer

## ressources

budget, les serveurs pour ...

## monitoring != statistics

## target audience

## support needed

pour le cas d'un homelab, pas besoin de support pour aider à gérer les problèmes

par contre pour un déploiement sérieux, il est préférable de l'envisager selon l'importance qu'à la supervision dans votre activité

## hidden cost

le coût d'une personne à maintenir, documenter & former les gens sur sa solution

<!--

service discovery
taille de l'infra à monitorer
quelles actions on peut faire dessus (chez des clients pas pareil que chez nous)
criticité voulue (plus vers solution de homelab sympa ou propriétaire fermé)

-->