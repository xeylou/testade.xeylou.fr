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

I had a harder time getting into it because there are a lot more notions to learn & to consider, outside & inside iTop, to use it properly.

So once again, i'd be very grateful if you'd consider correcting me if i said someting wrong.

### glossary

Defining mandatory acronyms of this post.

ITSM - *IT Service Management*  
Type of tool usually used by companies to organise & deliver their IT services to their departments or to other companies. They can integrate monitoring tools or a help desk ticketing system for example.

CMDB - *Configuration Management Database*  
Term to define a database used to store & organise the hardware items & the software assets of a company or someone.

ITIL - *Information Technology Infrastructure Library*  
Set of relevant IT practices that describe processes, procedures or tasks for IT related stuff like system administration or itsm management.

### presentation

[Combodo](https://www.combodo.com/) is a 13-year-old french company who created [iTop](https://www.combodo.com/itop), an open source, itil based, itsm & cmdb solution.

They are a profit based company, they created 2 non-free versions of iTop for business purposes: [essentials & professional/enterprise](https://www.combodo.com/itop#ancre_comparatif).

They also provide free & non-free external software to enhance iTop utilisation like a [front-end customiser](https://www.combodo.com/itsm-designer-195) or a [network related manager](https://www.combodo.com/teemip-194).

iTop is typically used by the IT department of a company to monitor services & implement a help desk ticketing system to the other departments. 

It is also used by companies to deliver IT services to other companies as a service provider.

## understandings 

Skiming through iTop core functionnalities, only the important ones all covered.

### fundamentals

iTop is based on apache, php, graphviz & mysql. However, it can run on nginx instead of apache with extra work.

The [documentation](https://www.itophub.io/wiki/page?id=latest:start) is made for anyone who is susceptible to use itop.

### cmdb

The cmdb is the core of itop and needs to be configured at first.

CMDB works with `Objects`, which are groups of `Instances` that share the same patern.

*(considering the "Persons" object, each instances of this object would have the same patern: a name, a surname, an age etc.)*

The cmdb can receive a populated `*.csv` file to create multiples instances of an object at once. *(instead of entering one by one every member of a company for example)*

iTop can receive custom objects but their implementation is not guided. The default ones are created without instances.

Objects & instances are stored in the `MySQL` database.

### itsm

The itsm is integrated with the ticket management system.

When installing, iTop proposes two ways to implement it: to deliver services to departments or to other companies.

The itsm provides two types of tickets: `Users requests` & `Incidents`.

Mandatory objects are needed to use them: `Services`, `Contracts` & `SLAs`.

**Services**  
Are the objects defining what is provided by the service provider (IT department or company). They are called to generate incidents or to supply users requests. Providers contracts required.

**Contracts**  
Splited in `Customer` & `Provider` contracts. The customer one defines what service(s) is provided/pucharsed by the customer + `SLAs`. The provider one links internal used ressources (`CIs`) according to the customer contract & what service(s) is provided.

**SLTs - *Service Level Target***  
Define metrics agreements between a customer & the provider. Two type by default: the TTO - *Time To Own* is the time between ticket's creation & the time to take it into account, TTR - *Time To Resolve* a ticket after creating.

**SLAs - Service Level Agreement**  
Group of `SLTs` defining the agreement between a provider and a customer for a given set of services.

When a customer creates a ticket, it can select the service amongst the list of services defined for this customer.

Tickets deadlines are computed depending on the SLA signed with the customer.

### default objects

Native objects in itop are created during the installation process.

They should be used because related to [itop principles](#presentation).

The mandatory objects are covered here, many more can be used & discovered exploring iTop.

**Organizations**  
Can be used for two purposes: name the different departments of a company when itop is used to deliver IT services within a company, or name the different companies a company is delivering IT services to.

**Locations**  
Are used to group objects by geography (servers, organisations etc.). A hierachy can be applied, locations can be linked to parents locations *(example: inside the company A, there is room A & room B in which have differents servers in racks A & racks B)*

**Persons**  
Defined the persons contacts & responsabilities regarding the IT services delivered. Can be deployed using `Profiles` to quickly assign permissions to the members of a department or a company.

**Teams**  
Usefull to define permissions easier *(HR & finance can access to..)*. Also help the customer to use the ticketing system & link objects.

**CIs - *Configuration Items***  
Describe hardware devices (network devices, servers, personal computers, printers & smartphones). Templates are available to all types of CIs.

**Software Installed**  
Present to easily index software installed on devices.

**Services**  
Object used to define what actions or device is delivered as a service to a customer. Can be subcategorised *(service A contains sub-service B & sub-service C)*.

### objects agencement

Objects are related to each others by different means.

I will make graphs & try to link them - no spoil.

Graphs following rules:

- Rectangles are highest objects.
- Rounded objects are those receiving links.
- Text in lowercaps are instructions, uppercaps are objects name.

`Persons` integrate `Teams` according to their `Role`.

<div style="background-color:white">
{{< mermaid >}}
graph LR
A[Persons] -->|Roles| B(Teams)
{{< /mermaid >}}
</div>

`Teams` are parts of an `Organization`.

<div style="background-color:white">
{{< mermaid >}}
graph LR
A[Teams] -->|parts of| B(Organizations)
{{< /mermaid >}}
</div>

`Organizations` are linked to `Locations`.

<div style="background-color:white">
{{< mermaid >}}
graph LR
A[Organizations] -->|are located| B(Locations)
{{< /mermaid >}}
</div>

`Organizations` are owning `CIs`. Those CIs, depending what they are, have rich `Properties` containing all types of other objects. CIs are exposed to `Services` & are ruled by `Provider Contracts`. `Documents` can be linked to them & they can be related to `Tickets`.

<div style="background-color:white">
{{< mermaid >}}
graph LR
B[Organizations] -->|owning| A(CIs)
A -->|exposed to| C(Services)
D[Provider Contracts] -->|rule| A
A -->|appear in| E(Tickets)
A -->|related to| F(Documents)
{{< /mermaid >}}
</div>

Relations for `Documents`.

<div style="background-color:white">
{{< mermaid >}}
graph LR
C[Organizations] -->|owning| A(Documents)
A -->|used for| D(Contracts)
D -->|defining| A
A -->|give informations| F(CIs)
A -->|linked to| E(Services)
{{< /mermaid >}}
</div>

Relation between objects is too complex to give only one comprehensible graph.

Instances properties change for each, relations between objects change according instances needs.

It would be meaningless to create a relaton graph for all objects.

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
**Do not refer to this graph. Please read above.**
{{< /alert >}}

<div style="background-color:white">
{{< mermaid >}}
graph LR
subgraph iTop Company View
A[Persons] -->|Roles| B(Teams)
B -->|parts of| C(Organizations)
C -->|are located| I(Locations)
C -->|owning| D(CIs)
D -->|related to| E
D -->|exposed to| G(Services)
H(Provider Contracts) -->|rule| D
D -->|appear in| F
C -->|owning| E(Documents)
E -->|used for| H
H -->|defining| E
E -->|linked to| G
E -->|give informations| D
A -->|see activity| D
A -->|attached to| F(Tickets)
J[Other Objects] -->|give properties| D
J -->|structure| E
end
{{< /mermaid >}}
</div>

Even though this graph seems valid, iTop has many more objects than the ones covered. Links between them should be discovered & created using the web interface.

## implementation

This sections will implement iTop following a [companies plan](#companies) & an [infrastructure](#infrastructure).

### companies plan

iTop will be used by two companies: `company A` who is the service provider one & `company B` who will use the services.

Here is the Company A agency graph.

<!-- 
not very visible
{{< mermaid >}}
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart LR
subgraph "Company A"
  a["`Person A
  **CEO**`"] --- b["`Person B
  **Executive Assistant**`"]
  a --- c["`Person C
  **Technical Manager**`"]
  c --- d["`Person D
  **Network & Sysadmin**`"]
  c --- e["`Person E
  **Network & Sysadmin**`"]
  c --- f["`Person F
  **work-study student**`"]
  c --- g["`Person G
  **work-study student**`"]
end
{{< /mermaid >}} -->

<div style="background-color:white">
{{< mermaid >}}
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart TD
subgraph z[Company A - Service Provider]
subgraph m[CEO]
a[Person A]
end
subgraph h[Executive Assistant]
b[Person B]
end
subgraph i[Technical Manager]
c[Person C]
end
subgraph j[Network & Sysadmins]
d[Person D]
e[Person E]
end
subgraph k[Work-Study Students]
f[Person F]
g[Person G]
end
end
m---h
m---i
i---j
i---k
style z fill:#fff,stroke:#fff,stroke-width:4px
{{< /mermaid >}}
</div>

The Company B one.

<div style="background-color:white">
{{< mermaid >}}
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart TD
subgraph z[Company B]
subgraph a[CEO]
b[Person H]
end
subgraph c[Technical Manager]
d[Person I]
end
subgraph e[Sales Manager]
f[Person J]
end
subgraph g[Head of Logistics]
h[Person k]
end
subgraph i[Manufacturing Manager]
j[Person M]
end
subgraph k[Assistant]
m[Person N]
end
end
a---c
a---e
c---g
c---j
e---k
style z fill:#fff,stroke:#fff,stroke-width:4px
{{< /mermaid >}}
</div>

### requirements

This is [iTop documentation hardware recommendations](https://manage-wiki.openitop.org/doku.php?id=latest:install:requirements).

<!-- https://www.tablesgenerator.com/html_tables -->

| Activity | Recommendations |
|:--------:|:---------------:|
| <table><thead><tr><th>Tickets/month</th><th>Users</th><th>CIs</th></tr></thead><tbody><tr><td>&lt;200</td><td>&lt;20</td><td>&lt;50k</td></tr><tr><td>&lt;5k</td><td>&lt;50</td><td>&lt;200k</td></tr><tr><td>&gt;5k</td><td>&gt;50</td><td>&gt;200k</td></tr></tbody></table> | <table><thead><tr><th>Servers</th><th>CPU</th><th>Memory</th><th>MySQL DB size</th></tr></thead><tbody><tr><td>All-in-one</td><td>2vCPU</td><td>4Gb</td><td>10Gb</td></tr><tr><td>Web+MySQL</td><td>4vCPU</td><td>8Gb</td><td>20Gb</td></tr><tr><td>Web+MySQL</td><td>8vCPU</td><td>16Gb</td><td>50Gb</td></tr></tbody></table> |

### infrastructure

There is in total 13 people in the two companies (< 50). The number of `CIs` will be under 50'000 & the tickets/month under 200.

An all-in-one server can be created with iTop installed & a MySQL database.

For expandability, the seperate solution will be used according to the following graph.

<!-- inversé sens company a & b pour disposition de
company a à gauche sur le schéma -->

<div style="background-color:white">
{{< mermaid >}}

graph TD
subgraph company-b[Company B Network]
router-b{Router}
switch-b[Network Switch]
consumer-pc(Consumer Device)
end

subgraph company-a[Company A Network]
router-a{Router}
switch-a[Network Switch]
itop-server(iTop Server<br><i>4vCPU 8GB</i>)
db-server[(MySQL Server<br><i>20GB</i>)]
end

wan{WAN} --- router-a & router-b
router-a --- switch-a
switch-a --- itop-server
switch-a --- db-server
router-b --- switch-b
switch-b --- consumer-pc
{{< /mermaid >}}
</div>

<!-- 
<div style="background-color:white">
{{< mermaid >}}
graph TD
subgraph company-b[Company B Network]
router-b((Router))
switch-b[/Network Switch/]
consumer-pc(Consumer Device)
end
subgraph company-a[Company A Network]
router-a((Router))
switch-a[/Network Switch/]
itop-server(iTop Server)
db-server[(MySQL Server)]
end

wan{WAN} --- router-a & router-b
router-a --- switch-a
switch-a --- itop-server
switch-a --- db-server
router-b --- switch-b
switch-b --- consumer-pc
{{< /mermaid >}}
</div>
-->

### installations

<!-- 2 scripts car si déjà un mysql + dire qu'il faut les privilèges etc. -->

### confirguration

<!-- 1. administration des données -> organizations
2. gestion des configurations -> locations 
3. gestion des configurations -> Contacts
4. gestion des configurations -> tableau de bord -> racks + chassis
4. gestion des configurations -> new CIs
4. User contracts -->

<!-- You can easily create Network devices, Server, Personal Computers, Printers and Mobile Phone as
soon as your organizations and locations are created. -->

<!-- Before creating the softwares installed on an infrastructure, you have to define the “typology” of
standard applications known in iTop. This is done via menu “Data Administration Applications” . →
You need as well to create the Licences if you wan to manage such objects but this can be done later.
Once done, you can create the softwares installed on an infrastructure. The attribute “device”
depends on the selected owner organization, the attribute software is the list of applications you
have created in “Data Administration Applications” -->

## close

<!-- It is very complicated to make your hands on. They do bootcamp like https://www.combodo.com/itop-cmdb-online-training-april-4-5 for 140$/h.
Jira is not free.

C'est vraiment long de tout comprendre. Puis ensuite tout intégrêt à itop (création de tous tous les objects et les liens) 

iTop's learning curve seems very low & very long at first. -->