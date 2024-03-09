---
title: "windows containers"
date: 2024-02-07
draft: false
tags: [ "docker", "virtualization", "windows" ]
slug: "windows-container"
---

<!-- prologue -->

{{< lead >}}
discovering windows images   
containerazation and its use cases
{{< /lead >}}

<!-- sources -->

<!--
https://github.com/dockur/windows
https://www.youtube.com/watch?v=xhGYobuG508
-->

<!-- article -->

## introduction

i daily use docker at work && for personal use to host && deploy services quickly

to me, docker permits fast service deployment && management w/ docker compose || docker file..., ha w/ docker swarm || kubernetes (k8s, k3s, k0s, k8e...) && more

in that way, i recently discovered that windows could be containerized, thanks to [this video](https://www.youtube.com/watch?v=xhGYobuG508) && the work of [dockur](https://github.com/dockur/)

so i wanted to dig into what windows images containerization currently looks like, && if its keep the same properties as usual docker containerization such as replication, fast deployment, ease of use, on demand scaling etc.

## why containerize windows

i think containerizing windows would give you the flexibility that docker has over services

that means you could easily replicate a configuration, a volume... as long as windows permits it *(more on that later)*

you could also manage your infrastructure only using docker, thus is a free && widely used tool - no more windows proprietary integrations or limitating corporate windows integrated solutions etc.

more on that, windows could be inside your docker installation : using same docker networks, sharing services... to averall take the avantages of the docker management && integrate it to a windows environnement

if i go beyond what i saw previously, i'd say that i wish to see micro-services hosted on windows containerized environments (active directories, exchange servers...)

also, as far as my windows knowledge goes, i didn't heard of a movement of windows moving forward docker integration 

## how does it work

i'll only talk about [dockur](https://github.com/dockur/) work here, since it is the biggest windows containerization project i know

so what they've done, is using docker as a launching platform for kvm based virtualization to launch windows 11, 10 etc. images

to start, all of their integration is comming from an existing project aiming to bring qemu into a docker container, [qemux/qemu-docker](https://github.com/qemus/qemu-docker) *(based on their [`Dockerfile`](https://github.com/dockur/windows/blob/master/Dockerfile))*

```dockerfile {linenos=table, hl_lines=[2], linenostart=1}
FROM scratch
COPY --from=qemux/qemu-docker:4.15 / /

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND "noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN "true"

# [...]
```

that include the kvm acceleration, `*.iso` importation, as well as the web-based viewer...

in fact, thanks to [qemux](https://github.com/qemus), it has usb/disks pass-through, network integration, support for custom `*.iso` images, support for docker volumes etc.

after that, it turns to be shell scripts to run qemu commands && instruct a virtual machine on your host (exiting docker)

## still docker related?

in some terms, you still use docker to manage your environment; but in fact, you are exiting it to bring up commands to run a vm

to me it is still docker related for the management part (you can share disks from docker instructions, share drives, vertically scale...)

but from a hardware view, it has nothing to do w/ docker, only qemu/kvm

## my point of view

this kind of project is very very new ([two months](https://api.github.com/repos/dockur/windows) for `dockur` && [10 months](https://api.github.com/repos/qemus/qemu-docker) for `qemux`)

&& as i recall, to the public crowd as i am in, it didn't get that much noise, whereas i'm a tech enthousiast && neither me or my friends have heard of it

i think it's safe for now to test it || watch it grow rather than deploy it (not production tested, support?, only docker community?, microsoft reaction)

i think it is a good way to bypass windows restrictions && get a new way to host windows only services; && also integrated it well better w/ your existing docker infrastructure

i hope these projects go well near future, i'll keep watching them && support them