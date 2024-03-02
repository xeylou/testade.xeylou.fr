---
title: "security notions"
date: 2023-09-01
lastmod: 2023-09-24
draft: false
tags: [ "monitoring", "security" ]
slug: "security-notions"
description: "taking a tour & understanding a variety of security notions"
---

<!-- prologue -->

{{< lead >}}
taking a tour & understanding  
variety of security notions
{{< /lead >}}

<!-- sources

https://www.headmind.com/fr/epp-edr-ndr-xdr-revolution-cyberdefense/
https://www.esecurityplanet.com/threats/xdr-emerges-as-a-key-next-generation-security-tool/
https://syscomgs.com/en/solutions/it-security-solutions/endpoint-security-ngav-edr/
https://www.nri-secure.com/blog/transition-from-legacy-av-to-edr

https://www.headmind.com/wp-content/uploads/2022/06/EPP-EDR-NDR-XDR-perimetres-de-detection-1024x520.png
https://www.criticalstart.com/epp-vs-edr-vs-mdr-endpoint-security-solutions-compared/ 
https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fsyscomgs.com%2Fwp-content%2Fuploads%2F2021%2F04%2FSlide2-768x373.jpeg&f=1&nofb=1&ipt=d3d6e12487ffac35d713125200a31fe9305ac41b010a060dc79705cace58cb03&ipo=images
https://www.malwarebytes.com/glossary
https://owasp.org/www-community/attacks/
https://travasecurity.com/learn-with-trava/blog/the-difference-between-threat-vulnerability-and-risk-and-why-you-need-to-know
https://resources.infosecinstitute.com/topics/hacking/file-inclusion-attacks/
https://owasp.org/www-community/attacks/Path_Traversal
https://owasp.org/www-community/attacks/Log_Injection

https://www.wired.com/story/2fa-randomness/
https://en.opensuse.org/SDB:Encrypted_filesystems?ref=itsfoss.com
https://itsfoss.com/luks/
https://www.nakivo.com/blog/3-2-1-backup-rule-efficient-data-protection-strategy/
https://www.office1.com/blog/traditional-antivirus-vs-edr-vs-next-gen-antivirus

-->

<!-- article -->

## introduction

learning network security, i had to write a post related to it

this post aims to learn or clarify hosts & networks security notions/jargon, not covering kinds of threats or attacks

i used simpler words than the ones found in my research to make it easier to read for non-native english speakers

i am not an expert by any means, please let me know if i've said something wrong

### glossary

defining mandatory concepts related to the notions covered

#### malware

malwares are malicious piece of code or software designed to harm or hijack a device or its data by any means

#### payload

payload is the part of a malware who responsible for the damages - *data exfiltration, making a host unusable, etc.*

#### vulnerability

vulnerabilities refer to hardware, software or procedures weaknesses that could be exploited by a `threat`

#### threat

threats are malicious or negative potential events exploiting known or yet unknown vulnerabilities

the word `threat actor` comming from it refers to people behind a malicious incident

#### risk

risks qualifies the probability that a threat exploits a vulnerability causing a
critical damage to the host or its neighbours

*risk = threat * vulnerability * damage*

#### attack

attacks are the usage *exploitation* of a vulnerability by a threat actor

classification for those are seperated, e.g: human threat, viruses...

#### threat model

threat modeling is the process of identifying potential [vulnerabilities](#vulnerability) or security flaws, prioritising weaknesses to address or mitigiate to minimize the [risks](#risk)

<!-- a threat model can be usefull for other purposes  
*for privacy/confidentiality to clarify privacy wants, mandatory needs & resulting actions* -->

#### endpoint

endpoints are the farrest devices on a network comming from the outside, can be hosts or servers

<!--
## threats/attacks

many threats & attacks could be covered according to their domains #### *programming, networks, hardware, webclient/server...*

since there are too many of them & this post aims global host & network security, they will not be covered

here is my personal list of little-known threats or attacks i liked do reseach on

*macros (file-based), cache poisoning, trojan, log injection, worms, data exfiltration, path traversal*
-->

## endpoint protection

are covered various protections for endpoints/hosts according to many types of threats & attacks

i only wrote about relevant & still active protection solutions

### hardware side

#### fde
<!-- https://www.howtogeek.com/237232/what-is-a-tpm-and-why-does-windows-need-one-for-disk-encryption/ -->
on the hardware side, `full-disk encryption` is a very good practice to preserve security & privacy for portable devices

having `Luks` for all kinds of needs & `BitLocker` for windows OSs

the better & common way to do fde is by using the tpm *trusted platform module* chip to generate the encryption keys & keeping part of it to itself

additionnaly for luks, it uses a master key asked before the boot sequence using a passphrase hash to boot into the OS

#### dlp

to minimise data loss (i.e. "availability" in production use), the threat model could implement a `data loss prevention` procedure

a usefull data loss model could be the 3-2-1 backup strategy

- 3 copies of the data *- (or more)*
- 2 backups on different storage media *- really helps*
- 1 backup copy offsite - *can be cloud, nas...*

for personnal use, backuping on two different medias (e.g: a nas & a disk or cloud) can do the job, but please do not underestimate the value of backups in production use

once an host has been infected or is showing signs to, doing a quick & tested restoration is very usefull & saves time

### software side

#### authorisation

authorisation can be associated to permissions

a good practice is to always let the minimal permissions to the users, restricting them to do only what they are intended to

that can be a part of the `threat model`: who can access which ressources

in other words, when an user is compromised -> what can he access, so what became at risk?

disabling the root account is also a good practice for most hosts, prefering a sudoer or proper user permissions

as always, good passwords are always a most & for the ssh protocol the [usage of keys or certificates in highly recommended](https://xeylou.fr/posts/ssh)

#### authentication

using a login & a password cannot verify the identity of the person accessing a ressource for that user 

since then, human intervention has guaranteed the identity of the person accessing the resource

back then, simple questions where asked to know if the intended person using the credentials was the one intended - *e.g name of its dog, where did he was born, etc.*

this authentication method was highly subjected to doxing/osint

nowadays, 2fa is used, living on the intended person's phone or an dedicated hardware device (yubikey)

2fa can take the form of push notifications *(malicious ones can be injected)*, sms verifications *(warning sim swapping attack method)* or authenticators codes using the totp protocol

mfa (multifactor authentication) is also a thing

### os/software side

#### epp

<!-- https://www.crowdstrike.com/cybersecurity-101/endpoint-protection-platforms/ -->

`endpoint protection platform` define the suite of technos or solutions used to protect endpoints  

#### ng-av/edr

*antivirus (av)*, *next gen antivirus (ngav)* & *endpoint detection & response (edr)* 

are commonly used solutions to protect endpoints

*sources i found says different things about them, so i put ng-avs & edrs together, i wonder if their names are not just a marketing thing for the same solutions*

"legacy avs" are based in signature recognition to stop known malware file

an individual hash could be generated for each file. standard avs compare them to a list of malicious files hash to know if the checked file is one of them or not to flag it

it is only working against file-based attack & new or yet unknown malwares, otherwise it could not be discovered using this method

<!-- that also introduce the notion of `false positive` if a non-malicious file is flagged by an av... -->

variations of a malware *(malformed sinature trick)* can also be done, so its bypass the hash check since it is not in the signature database

ngav use behaviour detection on top of the signature recognition, so if a software/program/service activity is suspicious -> the file or its activity can be put in quarantine or be stopped

some may introduce sandboxing & ai *- machine learning* although av & ngav are already well ressources hungry

edr & ng-avs are very important security solutions since only the endpoint can see the unencrypted ongoing or incomming traffics *(e.g. https traffic)*

be aware that more than one av could lead to more ressource usage & them trying to cancel each other, since they are accessing same files & seeing each other activity

<!--
#### hips
host intrusion prevention system
-->

## network solutions

network solutions are preferable so threats or attacks are stopped before reaching the endpoints

#### firewall

firewalling protects networks from unwanted traffic by setting a set of pre-programmed rules

it can also provide a network segmentation, separating the lan *local area network* into smaller ones w/ their dedicated rules

*not to compare w/ software firewalls who applies rules to an host applications only*

#### proxy

proxy servers could be an intermediate to access the internet in a lan (local area network)

very usefull to reduce a network attack surface since all the traffic is going through it

it can monitor traffic or gather metrics

it also provide sort of firewalling since you are restricted by what the proxy permit you to access to

it is also great for privacy since hosts are not directly exposed, the proxy is

*many use of proxies can be found doing research*

#### reverse proxy

reverse proxies act the same as normal proxies but for incomming traffic

endpoints are behind the reverse proxy so that all incomming connexions need to pass through the reverse proxy to access the hosts

the advantages are the same

#### ids & ips
<!-- https://www.okta.com/identity-101/ids-vs-ips/ -->

*intrusion detection systems* & *intrusion protection systems*

the ids & the ips analyse real-time traffic for signature matching known attacks or suspicious behaviour

the difference between them is that ips can act as a hardware switch to cut a malicious traffic whereas the ids only raise alerts

they are oftenly shipped inside a firewall by some companies

#### soc
<!-- https://www.ibm.com/topics/security-operations-center -->

*security operations center* or isoc *information security operations center*

is the structure (people, room, screens & devices) where logs are gathered & correlated

people are present at full-time to maintain the soc since it is a very important protection mesure (the ciso *chief information security officer*, analysts, devops/secdevops teams...)

the soc integrate various solutions such as a [siem](#siem) or a [soar](#soar) for example

the soc team makes decisions to act on the feedback according to the logs activity

#### ndr/xdr
*network detection & response* and *extended detection & response*

the ndr monitor network layer 2-7 traffic, no agent on the endpoints

xdr tend to gather more informations by installing agents on endpoints to gather data

xdr seems to be more corporate solutions & focus on properitaty

ndr can be implemented on its own but a xdr may cause friction if it's not the only protection system deployed

#### siem
<!-- https://www.microsoft.com/en-us/security/business/security-101/what-is-siem -->

*security information & event manager*

is offenly used in a soc environment, it gather, centralize & organize all logs from various devices

logs gathered from the firewalls, network appliances, ids... can be filtered by the siem since all their informations aren't always relevant

the siem is: collecting, aggregating, identifying, categorising & analysing incidents or events

the siem needs continuous learning by the security team *(this report is normal because we know [...], it is current that [...]...)* or by ai *(machine learning)* to keep categorising the data well but that has more to do with a [soar](#soar)

#### soar
<!-- 
https://www.microsoft.com/en-us/security/business/security-101/what-is-soar 
https://swimlane.com/blog/siem-soar/ 
-->

*security orchestration, automation & response*

go a step further than the siem, taking advantage of the automation

doing the same job as a [siem](#siem) but go a step futher by automating and orchestrating time-consuming manual tasks of the secops team, so they can speed up on real incident response time

<!-- ## other
### incident metrics -->
<!-- https://www.atlassian.com/incident-management/kpis/common-metrics -->
<!-- #### mtbf
mean time between failures is the average time between repairable failures of a techno product
#### mttd
#### mttr
#### mttf
#### mtta
### dwell time

### vulnerability scanners
osv-google, tools owasp -->

<!-- 
full disk encryption
edr
differences edr av (antivirus)

soc
siem
edr
epp
mdr
xdr
ndr
-->
