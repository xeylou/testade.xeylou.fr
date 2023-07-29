---
title: "combodo itop walk-through"
date: 2023-07-27
draft: false
tags: ["linux", "monitoring", "open-source", "windows"]
series: ["Exploring Monitoring Solutions"]
series_order: 2
slug: "itop-walkthrough"

---

<!-- prologue -->

{{< lead >}}
walk-throughing combodo itop solution &  
creating a living it service delivery infrastructure
{{< /lead >}}

<!-- article -->

## introduction

As with Nagios, i dived a week into Combodo iTop monitoring solution.

Once again, i'd be very grateful if you'd consider correcting me if i said someting wrong.

### glossary

Defining acronyms used in this post.

ITSM - *IT Service Management*  
Type of tool usually used by companies to organise & deliver their IT services to other companies or to their departments. They can integrate monitoring tools or a help desk ticketing system for example.

CMDB - *Configuration Management Database*  
Term to define a database used to store & organise the hardware items & the software assets of a company (or someone).

ITIL - *Information Technology Infrastructure Library*  
Set of good IT practices that describe processes, procedures or tasks for IT related stuff like system administration or itsm management.

### presentation

[Combodo](https://www.combodo.com/) is a 13-year-old french company who created [iTop](https://www.combodo.com/itop), an open source, itil based, itsm & cmdb solution.

They are a profit based company, they created 2 non-free versions of iTop for business purposes: [essentials & professional/enterprise](https://www.combodo.com/itop#ancre_comparatif). They also provide free & non-free external software to enhance iTop utilisation.

## itop principles

Skiming through iTop functionnalities.

### basics

iTop is based on php, apache, graphviz & mysql. Although, it should run on nginx instead of apache with extra work.

The [documentation](https://www.itophub.io/wiki/page?id=latest:start) is for anyone who is susceptible to use itop.

### cmdb

The cmdb is the core of itop and need to be configured first.

## implementing itop

The implementation is made in two major steps: installing iTop & configuring it.

### installation
### confirguration
## close

It is very complicated to make your hands on. They do bootcamp like https://www.combodo.com/itop-cmdb-online-training-april-4-5 for 140$/h.
Jira is not free.