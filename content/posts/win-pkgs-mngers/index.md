---
title: "software in windows"
date: 2023-08-21
draft: false
tags: ["windows"]
slug: "win-pkgs-mngers"
---

<!-- prologue -->

{{< lead >}}
software management differences  
& package managers for windows
{{< /lead >}}

<!-- sources 

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSiz
exporte pas les jeux (epic games, origin...)

-->

<!-- article -->

## software management

highlighting gaps & problems from the non software management in windows

### installation

to install a software in windows, an installer needs to be searched in a browser, downloaded (`.exe`, `.msi`...) & executed to download the wanted software

by downloading an installer externally, the chances to install a wrong software, install additional ones or a malware is increased

### updates 

software updates are individuals, each software must search for its update - *background apps, when the computer starts etc.*

nor the Windows Update or the Microsoft Store will check for the external installed software updates (apps you installed)

### uninstallation

most of the time, software can be found in the control panel or in the apps section of the windows settings

however, software installed in non common path are not listed alongside those (standalone or portable applications...&)

dependencies installed to use them usually remain after uninstalling the software - *how many programs in the control panel are not used...*

## some improving

the Microsoft Store has improved the software management in windows

the software listed are trusted because approved & listed by Microsoft

software are searched & directly downloaded, no risks to download additional software or execute a malicious program online

the software installed from the Microsoft Store can be all updated at once, no background apps etc. (not as catastrophic as each app has its own updates ritual)

however, the ms store apps list doesn't cover all the wanted users apps

## real improvement

windows, maybe knowning how software are handled on linux, created their [package manager](https://learn.microsoft.com/en-us/windows/package-manager/#understanding-package-managers)

package managers are tools used to install & manage software w/ their packages/dependencies

linux users use them to quickly install software, update their system, their software & packages **whenever they want**, and also uninstall software including unused dependencies, folders created for no residuals...

a package manager is a simpler & cleaner way to manage your system software & updates

> packages managers can also be used in companies to avoid installing software one by one on hundred PCs, run grouped updates, install specific ver. of a software & more

## windows package managers

package managers can be found for different purposes

here are some of them, how to install & use them

### smooth transition

to switch into a package manager easily, all installed apps can be found in the `Control Pannel`, under `Programs`, `Uninstall Programs`

certain other apps can be found in the `Settings` -> `Applications`

either, this command can be launched in an admin. terminal to list installed apps - *games not include, just the launchers*

```powershell
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSiz
```
to export the list to a file
```powershell
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize > C:\programs.txt
```
### winget
<!-- https://www.techradar.com/how-to/how-to-install-and-use-windows-package-manager 
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.5.2201/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle
-->

winget is the windows package manager shipped with windows 11 - *can be installed in windows 10 using a command*

adobe products & other microsoft trusted software can be installed quickly & securely through it

with `vlc` for example, instead of opening a web browser, searching vlc, downloading the installer, executing it, clicking next...  
open Powershell & run
```powershell
winget install vlc
```
> multiple software can be installed at once, to install gimp & vlc for example `winget install gimp vlc`

winget can search wanted packages too, example with `gimp`
```powershell
winget search gimp
```

list installed packages *(yes, usefull, unusual from windows)*
```powershell
winget list
```

uninstall one or more packages
```powershell
winget uninstall vlc gimp
```

upgrade one or all packages at once
```powershell
winget upgrade --id Adobe.Acrobat.Reader.64-bit
winget upgrade --all
```

configuration can also be exported if moving from a pc to an other
```powershell
winget export packages.json
winget import packages.json
```

### ninite
<!-- https://blog.logrocket.com/6-best-package-managers-windows-beyond/#ninite -->
leaving the command line, ninite aims to install & update software all at once using a `.exe`

very usefull after a windows installation to download all your software at once if you don't want winget

running it more than once will update the selected software

on their website, software to download can be choosen, from that it will generate a `.exe` to install them

{{< button href="https://ninite.com/" target="_blank" >}}
select software to install & "Get Your Ninite"
{{< /button >}}

### chocolatey

most used package manager in windows, appeared before winget in 2011: chocolatey is a more open package manager

more packages are in chocolatey, they are moderated & doesn't contain malware or bloatware

chocolatey is more open, so more widely used software are present than in winget, those who are not verified yet by windows but by their editors or chocolatey team

a single powershell command can install chocolatey, runned as admin
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

chocolatey has a strong & native gui called `chocolateygui` to avoid using commandline compared to winget

```bash
choco install chocolateygui
```

using it, all software can be upgraded at once, & its telling you an error if it can't (standard installers don't)

the commands are similar to [winget](#winget) with the `choco` command

> i personally use chocolatey when i got to be on windows host & find it more convenient to use, also for new users because of its native gui

list installed software, so you can quickly see your unused apps to uninstall or quickly install your software to a new windows host using chocolatey
```powershell
choco list
```

upgrade all packages
```powershell
choco upgrade all
```

or upgrade vlc only
```powershell
choco upgrade vlc
```

and the ultimate command to remove a software with its dependencies if not use by other software *- those commands are the same*

```powershell
choco uninstall package --removedependencies
choco uninstall package -x
```
> if an other software uses the removed one dependencies, chocolatey doesn't uninstall them & tells you it didn't

## bonus macos

the macos software management is different from the windows one

although, [homebrew](https://brew.sh/) has the same role as [chocolatey](#chocolatey) does for windows