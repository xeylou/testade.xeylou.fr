---
title: "centreon it overview"
date: 2023-08-12
draft: false
tags: ["gnu/linux", "monitoring", "open-source"]
series: ["Exploring Monitoring Solutions"]
series_order: 3
slug: "centreon-overview"
---

<!-- prologue -->

{{< lead >}}
overviewing centreon it    
& getting fully hands-on
{{< /lead >}}

<!-- article -->

## introduction

The last article in this series will be devoted to discover & use Centreon IT.

Feel free to correct me by email if i've said something wrong.

### presentation

[Centreon IT](https://www.centreon.com) is french an open-source based monitoring solution.

It is highly [inspired by Nagios](https://www.centreon.com/centreon-and-nagios-3-milestones-to-understand-their-distinctiveness/), since it was a Nagios frontend at its beginning. 

Centreon's solutions has the same Nagios' plugins & hosts systems but can keep their hands on the plugins with their repository - where [the community can freely publish them for Nagios](https://www.xeylou.fr/posts/nagios-introduction/#fundamentals).

Centreon is a profit-oriented company who has a business model based on licensing the number of hosts monitored.

<!-- 

Quotation is based on the number of equipment devices being monitored. Prices start at 250 monitored devices, then 500, 1000, 2000… sky is the limit. Subscriptions include software licenses, access to our Support team by phone or by mail and unlimited software updates. And Managed Service Providers can benefit from a Pay-per-Use pricing model specifically designed to help them grow their business.

-->

The free solution called Centreon IT-100 is licensed for 100 monitored hosts only - called [Free Trial](https://www.centreon.com/free-trial/). Other differences with the commercial editions are listed in [their comparison table](https://www.centreon.com/centreon-editions/).

## namely

Informations on how Centreon IT works & its specific features.

### organisation

The solutions can be hosted on site, called `OnPrem` by Centreon, or cloud-based, called `Cloud`.

Centreon instances always works with a Central Server, called `centreon-central` used to configure monitoring, display & operate the collected data.

To monitor multiple sites, instances can be deployed & attached to a Central Server, the `Remote Servers`.

Monitored data is gathered using `Pollers`, attached to the Central or a Remote Server.

Here is what a `Centreon OnPrem` distributed architecture should looks like according to Centreon.

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
central[Central Server]
remote0[Remote Server]
remote1[Remote Server]
remote2[Remote Server]
poller0((Poller))
poller1((Poller))
poller2((Poller))
poller3((Poller))
poller4((Poller))
poller5((Poller))

central --- remote0 & remote1 & remote2
remote0 --- poller0 & poller1
remote1 --- poller2 & poller3
remote2 --- poller4 & poller5
{{< /mermaid >}}

The `Centreon Cloud` architecture does away with Remote Servers, as Pollers are connected to the Central Server via the cloud - using a vpn.

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD
central[Central Server]
poller0((Poller))
poller1((Poller))
poller2((Poller))

central --- poller0 & poller1 & poller2
{{< /mermaid >}}

### hosting 

[Centreon documentation](https://docs.centreon.com/) guides to host onprem & cloud solutions on different supports.

For an overview, they give `*.ovf` & `*.ova` images for virtual box & vmware respectively.

<!-- https://download.centreon.com/#Appliances/ -->
Installations alongside gnu/linux distros is preferable for production use.

<!-- https://docs.centreon.com/docs/installation/installation-of-a-central-server/using-packages/ -->
The documentation guides it for RHEL, Alma/Oracle/Rocky Linux since they are rhel based distros - *(or "were" since [rhel closed their source](https://www.redhat.com/en/blog/furthering-evolution-centos-stream))*.

Less attention is putted on Debian, the documentation is deprecated for it.

<!-- https://docs.centreon.com/docs/21.10/installation/installation-of-a-central-server/using-centreon-iso/ -->
<!-- https://download.centreon.com/#version-21-10/ -->
In the past - until ver. 21.10, they used to create `*.iso` images to install their solutions alongside centos.

### connectors & plugins

<!-- https://docs.centreon.com/cloud/monitoring/pluginpacks/ -->
Data collections can be made by templates called `Monitoring Connectors` who have assets of `Plugins`.

Plugins have the same function as Nagios ones.

Installed & used by pollers, they are sets of commands to monitor various kinds of metrics, on differents type of hosts regarding many protocols.

Plugins & connectors are maintained in their [centreon-plugins](https://github.com/centreon/centreon-plugins) & [centreon-connectors](https://github.com/centreon/centreon-connectors) repositories, where it seems community can contribute.

<!-- https://docs.centreon.com/docs/21.10/monitoring/pluginpacks/ -->
<!-- https://docs.centreon.com/docs/administration/licenses/ -->
Although it's opensource, a license is required to access the full Plugin Pack on their solutions.

## deploying

Installing Centreon IT-100, doing a simple windows & linux hosts monitoring.

### requirements

The infrastructure size depends on the number of hosts to monitor.

Centreon recommends using lvm to manage their file systems - working fine without, but should be planned for production use.

A stand-alone central server is used under 500 hosts. Pollers every 500 hosts are expected with a database server if more than 2'500 hosts.

For production use, it would be a good idea to think about scalability.

Since there would be to many informations to display (partitionning, specs, infrastructure), i let you refer to their [infrastructure sizes charts](https://docs.centreon.com/docs/installation/prerequisites/#characteristics-of-the-servers).

### infrastructure

The same [infrastructure use in the nagios article](https://www.xeylou.fr/posts/nagios-introduction/#infrastructure).

Here is what the used infrastructure looks.

{{< mermaid >}}
%%{init: {'theme':'dark'}}%%
graph TD

subgraph lan[LAN]
router{Router}
switch[Switch]
centreon(Centreon Central Server)
linux(Linux Host)
win(Windows Host)
apache(Apache Server)
end

wan{WAN} --- router
router --- switch
switch --- centreon & linux & win
linux -.- apache

{{< /mermaid >}}

### installation

Centreon IT will be installed without license on Debian 11.

I made an installation script available on [Github](https://github.com/xeylou/centreon-it-overview/deb11-centreon-install.sh).

To run it, run the following commands.

```bash
mkdir testing && cd testing
wget https://github.com/xeylou/centreon-it-overview/deb11-centreon-install.sh
chmod +x debian-centreon-install.sh
./debian-centreon-install.sh
```

This script installs Centreon IT from Centreon's apt repositories & instll a mysql server through mariadb.

Installation can be resume by going on the server web interface.

### monitoring
## close
<!-- https://thehackernews.com/2021/02/hackers-exploit-it-monitoring-tool.html -->
<!-- https://www.wired.com/story/sandworm-centreon-russia-hack/ -->