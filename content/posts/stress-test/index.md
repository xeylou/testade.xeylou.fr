---
title: "bash stresstest"
date: 2024-04-29
draft: true
tags: [ "gnu/linux", "ssh" ]
slug: "bash-stresstest"
---

<!-- prologue -->

{{< lead >}}
giving some comands i like to use  
to do stress tests && benchmarks
{{< /lead >}}

<!-- sources -->

<!--
https://www.linuxtricks.fr/news/11-le-sac-de-chips/374-operations-inutiles-donc-indispensables-saturer-son-systeme-cpu-ram-disque-reseau/
https://cleveruptime.com/docs/files/proc-loadavg
https://euro-linux.com/en/blog/load-average-process-states-on-linux/
https://www.malekal.com/quest-ce-que-le-load-average-sur-linux/#Comprendre_et_lire_le_load_average
-->

<!-- article -->

## introduction

i wanted to share && keep at one place commands i find usefull to do stress tests && benchmarks on hosts (cpu, disk ,network, ram)

i will also explain why i found them in particular extremely usefull && what they do

i am sure some variants can be found online to fit your needs if mine are not, you can also modify them as long as i hope you understand what you do

## cpu

for `*nix` hosts, a good way to check your cpu activity is by watching if its busy from your cpu load average file

its value can be found in `/proc/loadavg`, who is a virtual file refreshed every minute displaying you cpu load average for 1, 5 && 10 minutes

the fourth column shows the number of running processes on top of the total number of processes (in idle, zombie...)

the fifth one is the last PID created by the system

i will use this is example fron my machine to explain how its works

```bash
0.08 0.18 0.25 1/713 7436
```

the loadavg is figured out by averaging the number of jobs in the run queue (processes in R state for Running) && those waiting for disk I/O (in/out, entrée/sortie) to be processed by the CPU (in state D for Uninterruptible sleep)

so the higher the waiting processes are, the higher your cpu is busy && the higher will be your cpu load average

for example, i have a 8 thread cpu, if the loadavg is at 0.75 for the last minute, i'd have arround 6 processes waiting for cpu time or are blocked (0.75*8=6)

to give a more simple example, if my loadavg was at 1, i was using on average 100% of 1 cpu thread distributed on my cpu, 2 for 2 cpu threads && so on

on windows, they convert it to percentages : `(your load average / your number of cpu thread) * 100`, so for my example i was at 1% of my cpu at 0.08 loadavg

if my loadavg go up to 1, i would be at 12.5% of my cpu (because i have 8 cpu threads, so it'd be 12.5% of my cpu capabilities (1/8)*100)

---

i use a command to max out the utilization of one cpu thread, && its activity can not be distributed to other threads (because the program is coded to be single threaded)

so one thread will be at 100% of utilization && go high on temperature, the others idling at 0% at warm temperature

to do so, i use `bzip2` to compress using its higher level of compression something that is in theory infinitely full to something in theory infinitely empty (it will never end)

i compress `/dev/zero` && prompt the output to my terminal, to redirect it into `/dev/null` where it'll be deleted (nothing will append)

in result, one cpu thread will constantly compress something (who has infinite size) to something that has no size (no disk space will be used)

the only thing your os can do is to switch the thread in utilization (from cpu thread 0 to cpu thread 4...)

```bash
bzip2 -9c /dev/zero > /dev/null
```

to stress out your entire cpu, you could (but shouldn't) run this command as many times as the number of cpu threads you have

to kill all the bzip2 processes, you can do like so

```bash
kill -9 $(ps -ax | grep "bzip2" | awk '{ print $1 }')
```

or list them && kill one by one manually
