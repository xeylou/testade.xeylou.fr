---
title: "introduction to nagios"
date: 2023-07-19
draft: false
tags: ["linux", "monitoring", "open-source", "windows"]
series: ["Exploring Monitoring Solutions"]
series_order: 1
slug: "nagios-introduction"

---

{{< lead >}}
understanding Nagios principles  
& deploying it using custom scripts
{{< /lead >}}

## introduction
For my work-study, i immersed myself in understanding Nagios for a week.

Here i expose what i've learned & what i've done with it.

I'd be extremely grateful if you'd consider correcting me if i said something wrong.

This article mainly talk about Nagios as the Nagios Core solution since it's an introduction.

### presentation
[Nagios Core](https://www.nagios.org/projects/nagios-core/) is a open source, widely used monitoring tool for hosts, applications & services.

The company behind Nagios, [Nagios Enterprises](https://www.nagios.com/about-nagios-enterprises/), afford to make Nagios Core free & open source by their financing policy.

They provide non-free solutions to make the Nagios Core utilisation simplified, such as a native & more sophisticated dashboard - [Nagios XI](https://www.nagios.com/products/nagios-xi/), or a better network implementation - [Nagios Network Analyzer](https://www.nagios.com/products/nagios-network-analyzer/).

These solutions are improvers for Nagios Core, highly prefered for production use but not essential to use Nagios Core.

### side notes

Nagios Core code can be found on [Github](https://github.com/NagiosEnterprises/nagioscore), it is mostly written in C language.

I found the [documentation](https://www.nagios.org/documentation/) quite well explained (using and compiling Nagios from source code) although sometimes confusing, obsolete or "oldish".

I keep in mind that Nagios Enterprise is a profit oriented company. Even if they seem to like the idea of keeping Nagios Core open-source, i cannot tell they will not [close their source for competiting or profit reason someday](https://www.redhat.com/en/blog/furthering-evolution-centos-stream).

You may also consider, regarding your deontology or your use cases, collecting your own metrics for your hosts to serve them into a dashboard - using Prometheus & Grafana for known examples.

## nagios principles

I will cover the basics of Nagios Core according to monitoring windows & linux hosts with their services.

### fundamentals
Nagios Core need to be installed on a host, bare metal or in a vm - no official docker image available.

To monitor hosts, the Nagios server will execute a sequence of commands at a sheduled time interval & will define the state of the monitored host/service according to the output of the command.

This series of tests can be customise according to what service you want to monitor on which host.

A simple & in use example can be the `HOST STATUS` check by Nagios: the Nagios server send an echo request to the host - ping command. If it receive an echo reply -> `HOST STATUS: ONLINE`, else -> `HOST STATUS: OFFLINE`.

In addition to well-known protocols, to monitor the largest amount of services, Nagios let its community post their own `Projects`.  
Since then, the community created & shared their free [plugins](#plugins) & [add-ons](#add-ons) to monitor their needed services on Nagios - all in their [Nagios Exchange](https://exchange.nagios.org/) platform.

### plugins

The commands used to monitor services are called `plugins`.

Plugins are located in `/usr/local/nagios/libexec/` with their name starting with `check_*`.

These plugins can be used as executable files to quickly check the status of services (very usefull during pre-production tests for my part).

Here is an example how to use the `check_http` plugin.

```sh
/usr/local/nagios/libexec/check_http -h
```
> displaying the help page  
> for the check_http plugin

Following to the `check_http` help page, we can execute the command on a host.

<!-- /usr/local/nagios/libexec/check_tcp -H 192.168.122.15 -p 80 -->

```sh
/usr/local/nagios/libexec/check_http -H 192.168.122.15
```
> HTTP OK: HTTP/1.1 200 OK - 10975 bytes in 0.002 second response time |time=0.001620s;;;0.000000 size=10975B;;;0

### add-ons

Plugins only check external metrics about hosts. To monitor internal ones like system utilisation (ram, cpu, disk..), Nagios use what they call `add-ons`.

Add-ons are software installed on hosts that make the Nagios server capable of gathering internal or restricted metrics.

Biggest add-ons are maintain by the community of Nagios users to keep gathering their services as they need to.

From the Nagios server side, the add-ons will be used as executable files like plugins are.

### nagios configuration files

Nagios configuration files `*.cfg` are located in `/usr/local/nagios/etc/`.

```
.
├── cgi.cfg
├── htpasswd.users
├── nagios.cfg
├── ressource.cfg
└── objects
   ├── commands.cfg
   ├── contacts.cfg
   ├── localhost.cfg
   ├── printer.cfg
   ├── switch.cfg
   ├── templates.cfg
   ├── timeperiodes.cfg
   └── windows.cfg
```

Since they are well documented inside & on the web, i'll just outline their purpose.

The `nagios.cfg` is the main Nagios configuration file. It contains informations like the log files location - can be changed, hosts directories location or services update interval.

A standard `htpasswd.users` is created in the installation process & define the Nagios users passwords.

CGIs check their `cgi.cfg` configuration file to gather user & groups rights & permission. It also contains the path for Nagios frontend files.

`ressource.cfg` define macros used in hosts configuration files for sensitive informations. Also provide plugins paths - handy for moving plugins or adding custom ones.

*(example of "sensitive informations": to monitor non public metrics about a database, you might need to log into using a username & a password at some point)*

The configuration files inside the `objects` directory are used to define commands, contacts, hosts, services etc. (more on that in [hosts configuration files](#hosts-configuration-files))

### hosts configuration files

Nagios monitor hosts by scheduling [plugins](#plugins) tasks or calling [add-ons](#add-ons) and reporting the results on a control panel.

To define what checks should be made on which host, Nagios use `Object Configuration Files`. 

These are `*.cfg` configuration files in which you define the host informations to monitor & the `check_` commands should be used.

It is recommended to create directories to manage your kinds of hosts - create a folder with all the `*.cfg` files for windows clients, linux servers etc.

## deployment
Here i demonstrate what i said in [how nagios works](#how-nagios-works).

Deploying an infrastructure based on the system monitoring of a `Windows Host` (server or client) & a `Debian Host`.  
The `Nagios Server` will also monitor a mysql server & an apache website hosted on the Debian Host.

### network plan
```goat
                               +-------------------------+
                               |                         |
                               |         Switch          |
                               |                         |
                               +----------+-+-+----------+
             +----------------------------+ + +---------------------------+
             |                              |                             |
             | .--------------.             | .--------------.            | .--------------.
             || 192.168.122.25 |            || 192.168.122.xx |           || 192.168.122.15 |
             | '--------------'             | '--------------'            | '--------------'
+------------+------------+   +-------------+-----------+    +------------+------------+
|                         |   |                         |    |                         |
|      Nagios Server      |   |       Windows Host      |    |       Debian Host       |
|                         |   |                         |    |                         |
+-------------------------+   +-------------------------+    +-------------------------+
```

### windows host

[Add-ons](#add-ons) are needed to monitor hosts system activity.

[NSClient++](https://nsclient.org/) will be the add-on used for windows. NSClient++ agent need to be installed on the host & the Nagios Server will be configured to call the agent to gather system metrics.

***parler du password***

### linux host

As well as for the [windows host](#windows-configuration), the debian server will have an add-on agent: [nrpe](https://exchange.nagios.org/directory/Addons/Monitoring-Agents/NRPE--2D-Nagios-Remote-Plugin-Executor/details).

I made a script to install nrpe on debian hosts, source code is on [Github](https://github.com/xeylou).

***change github link to the nrpe installer with code view***
### nagios server

The Nagios Server is a Debian machine hosting Nagios Core & Nagios Plugins.

I made a script for their installation on my [Github](https://github.com/xeylou), working & tested on debian 11 & 12.

To download & launch the installer, replicate these commands on your host.

```sh
wget https://github.com/xeylou/nagios-introduction/debian-nagios-install.sh
chmod +x debian-nagios-install.sh
./debian-nagios-install.sh
```

Once installed, the Nagios web interface can be reach at `http://192.168.122.25/nagios` with the user `nagiosadmin` & the password gave during the installation.

### overview
## opinion