---
title: "security notions"
date: 2023-09-01
draft: false
tags: [ "monitoring", "security" ]
slug: "security-analysis-hosts"
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

this post aims to learn or clarify host & network security notions/jargon, not covering kinds of threats & attacks

i used simpler words compared to the ones found in my research to make it easier to read for non-native english speakers

i am not an expert by any means, please let me know if i've said something wrong

### glossary

defining mandatory concepts related to the notions covered in the post

#### malware

malwares are malicious piece of code or software designed to harm or hijack a device by any means whatsoever

#### payload

payload is the part of a malware who responsible for the damages - *data exfiltration, make host unusable, etc.*

can be considered as the "action of the malware"

#### vulnerability

vulnerabilities refer to hardware, software or procedures weaknesses that could be exploited by a `threat`

#### threat

threats are malicious or negative potential events exploiting known or yet unknown vulnerabilities

the word `threat actor` comming from it refers to people behind a malicious incident

#### risk

risks refer to the possible implication of the damage or loss of assets and data

*risk = threat + vulnerability*

#### attack

i wanted to put attacks beside `threat` because attacks are always intentional compared to threats

an attack is always malicious & want to cause damages whereas threats sometimes don't

classification for those are seperated, e.g: human threat compared to viruses

#### threat model

threat modeling is the process of identifying potential `vulnerabilities` or security flaws (software), prioritising which weaknesses to address or mitigiate

creating a threat model can be used for other purposes - *for privacy -* to clarify wants, needs & what to do w/ them

#### endpoint

endpoints are the farrest devices on a network comming from outside, can be hosts or servers

<!--
## threats/attacks

many threats & attacks could be covered according to their domains #### *programming, networks, hardware, webclient/server...*

since there are too many of them & this post aims global host & network security, they will not be covered

here is my personal list of little-known threats or attacks i liked do reseach on

*macros (file-based), cache poisoning, trojan, log injection, worms, data exfiltration, path traversal*
-->

## endpoint protection

are covered various protection for endpoints/hosts according to many types of threats & attacks

i only wrote about relevent & still active protection notions (not hips for example)

### hardware side

#### fde

on the hardware side, `full-disk encryption` is a very good practice to preserve security & privacy for mobile hosts

having `Luks` for all kinds of needs & `BitLocker` for windows OSs

the better & common way to do fde is using the tpm chip

additionnaly for luks, it uses a master key asked before the boot sequence using a passphrase hash

#### dlp

to minimise data loss, the threat model could implement a `data loss prevention` procedure

a usefull data loss model could be the 3-2-1 backup strategy

- 3 copies of the data *(or more)*
- 2 backups on different storage media - *this one really help...*
- 1 backup copy offsite - *can be cloud, nas, etc.*

for personnal use, backuping on two different medias (e.g: a nas & a drive) could be enough, but please do not underestimate the value of backups in production use

once an host has been infected or show signs to, doing a quick & tested restoration is very usefull - *shame when you do a restore but it can't be restored*

### software side

#### authorisation

authorisation can be associated to permissions

in eather ways, a good practice is to always let the minimal permissions to the users

that can be a part of the `threat model`: who can access which ressources

in other words, when an user is compromised -> what can it access, what is at risk

disabling the root account is a good idea for most hosts & servers, prefering sudoer or accorded user permissions

as always, make sure to use good passwords, for [ssh using keys or certificates](https://xeylou.fr/posts/ssh)

#### authentication

using a login & a password, you cannot verify the person accessing a ressource, only the user 

since then came human intervention to garantee the person accessing the ressource

back then, simple questions where asked to know if the intended person using the login waas the one intended: name of the person dog, where did he was born, etc.

this authentication method was highly subjected to doxing

now, 2fa comes in, widely present, authentication part is living on the person's phone

2fa can take form of push notifications (malicious ones can be injected), sms verifications (warning sim swapping) or authenticators codes using totp

mfa (multifactor athentication) can also be applied

### os/software side

#### epp

<!-- https://www.crowdstrike.com/cybersecurity-101/endpoint-protection-platforms/ -->

endpoint protection platform is the suite of technos used to protect endpoints  

#### ng-av/edr

av (antivirus) & ngav (next gen antivirus) or edr (endpoint detection & response) are commonly used technos to protect endpoints

*all the sources i found was saying different things, so i putted together ng-avs & edrs, i am wondering if that is not just marketing for the same solutions*

"legacy avs" are based in signature recognition to stop known malware

an individual hash can be generated for each file, standard avs compare them to a list of malware they have to know if a file is one or not

new or yet unknown malwares could not be discovered

<!-- that also introduce the notion of `false positive` if a non-malicious file is flagged by an av... -->

variations of a malware (malformed sinature trick) can be done, so its bypass the check since it is not in the db

ngav use behaviour detection on top of the signature recognition, if an activity is suspicious -> the file created it can be put un quarantine

some may introduce ai, i guess for machine learning although

av & ngav are ressources hungry

be aware that more than one av could lead to more ressource usage & the avs to try cancel each other, since they are accessing & seeing each other activities

<!--
#### hips
host intrusion prevention system
-->

## networks solutions

networks solutions are preferable to stop malicious traffic (the malware from incoming) before accessing the endpoints

#### firewall

firewalling protects networks from unwanted traffic by a set of pre-programmed rules

also provide a network segmentation, seperation of the lan (local area network) into smaller ones w/ their dedicated rules

*not to compare w/ software firewalls who applies rules to an host only*

#### proxy

proxy servers could be you intermediate to access the internet in your lan - *not mentionning vpn*

very usefull to reduce a network attack surface 

since all the traffic is going through, it can monitor it or gather metrics

it also provide sort of firewalling since you are restricted by what the proxy permit you to go

also great for privacy since your host is not directly exposed

*many use of proxies or "proxy servers can be found doing research*

#### ids & ips
<!-- https://www.okta.com/identity-101/ids-vs-ips/ -->

intrusion detection system & intrusion protection system are the "avs of network" - *i call them*

the ids analyse real-time traffic for signature matching known attacks or suspicious behaviour

it can make alerts related to it & according to the threat model, call the ips to stop the traffic related to it or push an alert to let the secops team choose

#### soc
<!-- https://www.ibm.com/topics/security-operations-center -->

the security operations center - *found it can be called isoc (information...)*

*the masterpiece to have, centralising & thinking*

socs unifiy & coordinate security tools (edr, firewall, proxy, etc.) to a main dashboard

extremely useful to correlate informations & choose actions

it use all other solutions ressources to monitor, maybe detect & respond (alert or do an action)

for some socs, they can: shutdown endpoints or disconnect them, reroute their traffic, run avs scan, etc.

people are present at full-time to maintain the socs since it is a very important protection mesure (ciso, analysts, devops/secdevops...)

#### ndr/xdr
network detection & response and extended detection & response

ndr monitor network layer 2-7 osi traffic, no agent on the endpoints

xdr tend to gather more informations, on endpoints by installing agents for example

xdr seems to be more corporate solutions & focus on properitaty

ndr can be implemented solo but xdr may cause friction if it's not the only protection system deployed

#### siem
<!-- https://www.microsoft.com/en-us/security/business/security-101/what-is-siem -->

security information & event manager

oftenly used w/ a soc, it is the helper of the security teams

data gathered by the firewalls, network appliances, ids... can be gathered by the siem & filtered since all their informations isn't always relevant

the siem is: collecting, aggregating, identifying, categorising, analysing incidents or events

siem needs continuous learning by the security team or by ai (machine learning) to keep categorising data

these data are send to the soc next

#### soar
<!-- 
https://www.microsoft.com/en-us/security/business/security-101/what-is-soar 
https://swimlane.com/blog/siem-soar/ 
-->

security orchestration, automation & response

seems to go a step further than the siem

looks like an inbetween of a soc & a siem but with an advantage to the soc: the automation - *in the name...*

it automates and orchestrates time-consuming, manual tasks for the secops, so they can speed up on response time

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