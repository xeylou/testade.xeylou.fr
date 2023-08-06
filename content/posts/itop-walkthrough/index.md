---
title: "combodo itop walk-through"
date: 2023-08-05
draft: false
tags: ["gnu/linux", "monitoring", "open-source"]
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

I had harder time getting into it due to the notions to lean & to consider, inside & outside iTop to use it properly.
<!-- I had a harder time getting into it because there are more notions to learn & to consider, outside & inside iTop, to use it properly. -->

So once again, i'd be very grateful if you'd consider correcting me if someting wrong is said.

### glossary

Defining mandatory acronyms for this post.

ITSM - *IT Service Management*  
Type of tool usually used by companies to organise & deliver their IT services to their departments or to other companies. They can integrate monitoring tools or a help desk ticketing system for example.

CMDB - *Configuration Management Database*  
Term to define a database used to store & organise the hardware items & the software assets of a company or someone.

ITIL - *Information Technology Infrastructure Library*  
Set of relevant IT practices describing processes, procedures or actions for IT related operations like system administration or itsm management.

### presentation

[Combodo](https://www.combodo.com/) is a 13-year-old french company who created [iTop](https://www.combodo.com/itop), an open source, itil based, itsm & cmdb solution.

They are a profit based company, they created 2 non-free versions of iTop for business purposes: [essentials & professional/enterprise](https://www.combodo.com/itop#ancre_comparatif).

They also provide free & non-free external software to enhance iTop utilisation like a [front-end customiser](https://www.combodo.com/itsm-designer-195) or a [network related manager](https://www.combodo.com/teemip-194).

iTop is typically used by the IT department of a company to monitor services & implement a help desk ticketing system to the other departments. 

It is also used by companies to deliver IT services to other companies as a service provider.

## understandings 

Skiming through iTop core functionnalities, only the standard ones are covered.

### fundamentals

iTop is based on apache, php, graphviz & mysql. However, it can run on nginx instead of apache with extra work.

The [documentation](https://www.itophub.io/wiki/page?id=latest:start) is made for anyone who is susceptible to use itop.

### cmdb

The cmdb is the core of itop and needs to be configured at first.

CMDB works with `Objects`, which are groups of `Instances` sharing the same patern.

*(considering the "Persons" object, each instance of this object would have the same patern: a name, a surname, an age etc.)*

The cmdb can receive a populated `*.csv` file to create multiples instances of an object at once. *(instead of entering one by one every member of a company for example)*

iTop can receive custom objects but their implementation is not guided. The default ones are created without instances.

Objects & instances are stored in the `MySQL` database.

### itsm

The itsm is integrated with the ticket management system & will be described using the itil way.

When installing, iTop proposes two ways to implement it: to deliver services to departments or to other companies.

The itsm provides two types of tickets: `Users requests` & `Incidents`.

Mandatory objects are needed to use them: `Services`, `Contracts` & `SLAs`.

Here are their purposes & how they are related.

- Services  
Are defining what is provided by the service provider (IT department or company). Called to generate incidents or to supply users requests. Providers contracts are required.

- Contracts  
Splited in `Customer` & `Provider` contracts. Customer one defines service(s) provided to/pucharsed by the customer + the `SLAs`. Provider one links internal ressources (`CIs`) used for the service(s) provided.

- SLTs - *Service Level Target*  
Define metrics agreements between customers & providers. Two by default: TTO - *Time To Own*: time to take a ticket into account & TTR - *Time To Resolve* a ticket after creating.

- SLAs - *Service Level Agreement*  
Group of `SLTs` defining the agreement between a provider & a customer for a given set of services.

When a customer creates a ticket, it can select the service amongst the list of services defined for this customer.

Tickets deadlines are computed depending on the SLA signed with the customer.

### default objects

Native objects in itop are created during the installation process.

They should be used because related to [itop principles](#presentation).

The mandatory objects are covered here, many more can be used & discovered exploring iTop.

- Organizations  
Can be used for two purposes: name the different departments of a company when itop is used to deliver IT services within a company, or name the different companies a company is delivering IT services to.

- Locations  
Are used to group objects by geography *-servers, organisations etc*. A hierachy can be applied, locations can be linked to parents locations *(example: inside the company A, there is room A & room B in which have differents servers in racks A & racks B)*

- Persons  
Define the persons contacts & responsabilities regarding the IT services delivered. Can be deployed using `Profiles` to quickly assign permissions *(to the members of a department or a company for example)*.

- Teams  
Usefull to define permissions easier *- all the HR & finance teams can access to...*. Can also help the customer to use the ticketing system to communicate.

- CIs - *Configuration Items*  
Describe hardware devices: network devices, servers, personal computers, hypervisors, vms etc. Templates are available for a large type of CIs.

- Software Installed  
Present to easily index software installed on devices, address licences & so on.

- Services  
Object used to define what actions or access is delivered as a service to a customer. Can be subcategorised *- service A contains sub-service B & sub-service C*.

### objects agencement

Objects are related to each others by different means.

Graphs are made to show the links between them, or try.

Graphs are generated using the following rules:

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

Regarding only these three objects, links can be done. Before that, checking links between objects from [default objects](#default-objects).

`Organizations` are owning `CIs`. CIs are exposed to `Services` & are ruled by `Provider Contracts`. They can be related to `Documents` & appear in `Tickets`.

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

Relations between objects are too complex to give only one comprehensible graph for each one.

The graphs generated above were just linking a reduce number of native objects.

There is a lot more types of objects in itop, with their own instances properties changing the relations between objects according to their individual needs.

It would be meaningless to create decent relations graphs for all objects, since their dependencies & relationships could change each instance.

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

Even though this graph seems valid for the most part, iTop has many more objects than the ones covered. Links between them should be discovered & created using the web interface.

## implementation

This sections will implement iTop following a [companies charts](#companies) & an arbitrary [infrastructure](#infrastructure).

### companies charts

iTop will be used by two companies: `Company A` which is the service provider & `Company B` who use their services.

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
subgraph z[Company A Chart - Service Provider]
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

And here is the Company B one.

<div style="background-color:white">
{{< mermaid >}}
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart TD
subgraph z[Company B Chart - Consumer]
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
h[Person K]
end
subgraph i["Manufacturing
Manager"]
j[Person M]
end
subgraph k[Assistant]
m[Person N]
end
end
a---c
a---e
c---g
c---i
e---k
style z fill:#fff,stroke:#fff,stroke-width:4px
{{< /mermaid >}}
</div>

### requirements

This is the [iTop hardware recommendations](https://manage-wiki.openitop.org/doku.php?id=latest:install:requirements) from their documentation.

<!-- https://www.tablesgenerator.com/html_tables -->

| Activity | Recommendations |
|:--------:|:---------------:|
| <table><thead><tr><th>Tickets/month</th><th>Users</th><th>CIs</th></tr></thead><tbody><tr><td>&lt;200</td><td>&lt;20</td><td>&lt;50k</td></tr><tr><td>&lt;5k</td><td>&lt;50</td><td>&lt;200k</td></tr><tr><td>&gt;5k</td><td>&gt;50</td><td>&gt;200k</td></tr></tbody></table> | <table><thead><tr><th>Servers</th><th>CPU</th><th>Memory</th><th>MySQL DB size</th></tr></thead><tbody><tr><td>All-in-one</td><td>2vCPU</td><td>4Gb</td><td>10Gb</td></tr><tr><td>Web+MySQL</td><td>4vCPU</td><td>8Gb</td><td>20Gb</td></tr><tr><td>Web+MySQL</td><td>8vCPU</td><td>16Gb</td><td>50Gb</td></tr></tbody></table> |

### infrastructure

There is 13 people who will potentially use itop in the two companies combined (< 50). The number of `CIs` will be under 50'000 & the tickets/month under 200.

The all-in-one server will be chose with iTop & a MySQL server installed.

For a production use, looking for expandability by choosing the seperate solutions could be a better choice.

Here is the network infrastructure that will be used.

<!-- inversé sens company a & b pour disposition de
company a à gauche sur le schéma -->

<div style="background-color:white">
{{< mermaid >}}

graph TD
subgraph company-b[Company B Network]
router-b{Router}
switch-b[Network Switch]
consumer-pc(Consumer Device)
apache-b(Apache Server)
end

subgraph company-a[Company A Network]
router-a{Router}
switch-a[Network Switch]
itop-server(Debian Machine<br><i>2vCPU 4GB</i>)
db-server[(MySQL DB<br><i>10GB</i>)]
itop(iTop Community)
apache-a(Apache Server)
end

wan{WAN} --- router-a & router-b
router-a ---|192.168.122.0/24| switch-a
switch-a ---|192.168.122.212| itop-server
itop-server -.- db-server & itop
switch-a ---|192.168.122.111| apache-a
router-b ---|192.168.1.0/24| switch-b
switch-b ---|192.168.1.1| consumer-pc
switch-b ---|192.168.1.2| apache-b
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

The `Company A` will provide an apache web server from their LAN as a service & will monitor an other one from the `Company B` LAN.

### installations

I made an installation scripts for iTop Community & for a MySQL server according to iTop requirements.

Both scripts are interactive & made for debian *- tested for debian 12*, source code is available on [Github](https://github.com/xeylou/itop-walkthrough).

The iTop server installation can be done running the following commands.

```bash
mkdir itop_install && cd itop_install
wget https://github.com/xeylou/itop-walkthrough/debian-itop-install.sh
chmod +x debian-itop-install.sh
./debian-itop-install.sh
```

For the MySQL one.

```bash
mkdir mysql_install && cd mysql_install
wget https://github.com/xeylou/itop-walkthrough/debian-mysql-install.sh
chmod +x debian-mysql-install.sh
./debian-mysql-install.sh
```

An external mysql database can be used without this install script if an all privilieged user if created for iTop.

The installation can be resumed at `http://192.168.122.212`.

*(highlighted forms are clicked/changed values)*

![](350/00.png)
![](350/01.png)
The warning says the used php version (latest) is not tested for this iTop version by Combodo.
![](350/02.png)
![](350/03.png)
![](350/04.png)
![](350/05.png)
![](350/06.png)
The `Server Name` is *localhost* because the iTop instance  & the mysql server are hosted in the same host *- can be replaced by the ip address of the external mysql server if using the seperate solution*.

The `Login` & the `Password` was created in the installation proccess of the `debian-mysql-install.sh` script.
![](350/07.png)
The database name found was also created during the installation process.
![](350/08.png)
![](350/09.png)
`Person C` will have admin privilieges for this iTop instance.

The `Language` is set for the user only.
![](350/10.png)
Here the `Default Language` for all users can be changed. Can also be changed by individual users after deploying.
![](350/11.png)
![](350/12.png)
![](350/13.png)
![](350/14.png)
Since the `Company A` acts as a service provider, the second option is chose. The first option should be kept if delivering IT services to company departements.
![](350/15.png)
![](350/16.png)
Simple Ticket Management can be chose to get rid of `SLTs` & `SLAs`.
![](350/17.png)
![](350/18.png)
![](350/19.png)
The Customer Portal is the iTop interface but reagenced for users tickets. If not chose, tickets should be created using command-lines method.
![](350/20.png)
![](350/21.png)
![](350/22.png)
![](350/23.png)
![](350/24.png)
![](350/25.png)
![](350/26.png)
![](350/27.png)
![](350/28.png)

### confirguration

The cmdb (organizations, persons, teams etc.) needs to be configured first. Depending on the company/ies & the infrastructure/s sizes, it could take a long time.

Exporting & importing csv files will be done to configure itop quickly.

Manual objects modification will also be covered.

To avoid putting a gigantic amount of screenshots, i made short videos to configure itop after the [installation](#installations).
  
<!-- 

1. Organisations
2. Locations
3. Persons + Users + Their locations
4. Teams

contracts
cis

 -->

### monitoring
## close