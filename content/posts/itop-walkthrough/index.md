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
walk-throughing combodo itop & creating a  
living it service delivery infrastructure
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
Term to define a database used to store & organise the hardware items & the software assets of a company or someone.

ITIL - *Information Technology Infrastructure Library*  
Set of relevant IT practices that describe processes, procedures or tasks for IT related stuff like system administration or itsm management.

### presentation

[Combodo](https://www.combodo.com/) is a 13-year-old french company who created [iTop](https://www.combodo.com/itop), an open source, itil based, itsm & cmdb solution.

They are a profit based company, they created 2 non-free versions of iTop for business purposes: [essentials & professional/enterprise](https://www.combodo.com/itop#ancre_comparatif).

They also provide free & non-free external software to enhance iTop utilisation like a [front-end customiser](https://www.combodo.com/itsm-designer-195) or a [network related manager](https://www.combodo.com/teemip-194).

## understandings 

Skiming through iTop core functionnalities.

### fundations

iTop is based on apache, php, graphviz & mysql. However, it can run on nginx instead of apache with extra work.

The [documentation](https://www.itophub.io/wiki/page?id=latest:start) is made for anyone who is susceptible to use itop.

### cmdb

The cmdb is the core of itop and needs to be configured at first.

CMDB works with `Objects`, which are groups of `Instances` that share the same patern.

*(considering the "Persons" object, all instances of this object would have the same patern: a name, a surname, an age etc.)*

The cmdb can receive a populated `*.csv` file to create multiples instances of an object at once. *(instead of entering manually every member of your company for example)*

iTop can receive custom objects but the implementation for them is not guided.

Objects & instances are stored in the `MySQL` database attached to itop.

## implementation
### configuration size
### infrastructure
### installations
### confirguration
## close

It is very complicated to make your hands on. They do bootcamp like https://www.combodo.com/itop-cmdb-online-training-april-4-5 for 140$/h.
Jira is not free.