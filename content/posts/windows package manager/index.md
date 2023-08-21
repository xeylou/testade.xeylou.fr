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

Highlighting gaps & problems from the non software management in windows.

### installation

To install a software in windows, an installer needs to be searched in a browser, downloaded (`.exe`, `.msi`...) & executed to download the wanted software.

By downloading an installer externally, the chances to install the wrong software, install additional ones or a malware is increased.

### updates 

Software updates are individuals, each software must search for its update - *background apps, when the computer starts etc.*

Nor the Windows Update or the Microsoft Store will check for your external installed software updates.

### uninstallation

Most of the time, software can be found in the control panel or the apps section of the windows settings.

However, software installed in non common path are not listed alongside those.

Dependencies installed to use them usually stay after uninstalling the software - *look at programs installed in the control panel, how many are wanted or used...*

## some improving

The Microsoft Store improves the software management in windows.

The software are trusted because approved & listed by Microsoft.

Software are searched & directly downloaded, no risks to download & execute a malicious program found online.

The software installed from the Microsoft Store can be all updates at once, no background apps etc.

However, the ms store apps list doesn't cover all the wanted users apps.

## real improvement

Windows, knowning how software are handled on linux, created their [package manager](https://learn.microsoft.com/en-us/windows/package-manager/#understanding-package-managers).

Package managers are tools used to install & manage software & their packages.

Linux users use them to quickly install software, update their system, their software & packages whenever they want, and also uninstall software including unused dependencies.

A package manager is a simpler & cleaner way to manage your system software & updates.

> packages managers can also be used in companies to avoid installing software one by one on hundred PCs, run grouped updates, install specific ver. of a software & more

## windows package managers

Package managers can be found for different purposes.

Here are some of them, their purposes, how to install & used them.

### smooth transition

To switch into a package manager easily, all installed apps can be found in the `Control Pannel`, under `Programs`, `Uninstall Programs`.

Certain other apps can be found in the `Settings` -> `Applications`.

Either, this command can be launched in an admin Terminal to list your installed apps - *games not include, just the epic launcher etc.*

```powershell
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSiz
```
Or exported to a file
```powershell
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize > C:\programs.txt
```
### winget
<!-- https://www.techradar.com/how-to/how-to-install-and-use-windows-package-manager 
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.5.2201/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle
-->

Winget is the windows package manager shipped with windows 11 - *can be installed in windows 10 using a command*.

Adobe products & other microsoft trusted software can be installed quickly & securely through it.

With `vlc` for example, instead of opening a web browser, searching vlc, downloading the installer, executing it, clicking next...  
Open a Terminal or a Powershell & run.
```powershell
winget install vlc
```
> multiple software can be installed at once, to install gimp & vlc for example `winget install gimp vlc`

Winget can search wanted packages, example with `gimp`.
```powershell
winget search gimp
```

List installed packages.
```powershell
winget list
```

Uninstall one or more packages.
```powershell
winget uninstall vlc gimp
```

Upgrade one or all packages at once.
```powershell
winget upgrade --id Adobe.Acrobat.Reader.64-bit
winget upgrade --all
```

Configuration can be exported if moving from a pc to an other.
```powershell
winget export packages.json
winget import packages.json
```

### ninite
<!-- https://blog.logrocket.com/6-best-package-managers-windows-beyond/#ninite -->
Leaving the command line, ninite aims to install & update your software all at once using a `.exe`.

Very usefull after a windows installation to download all your software at once if you didn't have winget at first.

Running it more than once will update the selected software.

On their website, software to download can be choose, from that it will generate a `.exe` to install them.

{{< button href="https://ninite.com/" target="_blank" >}}
Select software & "Get Your Ninite"
{{< /button >}}

### chocolatey

Most used package manager in windows, appeared before winget in 2011: chocolatey is a more open package manager.

More packages are in chocolatey, they are moderated & doesn't contain malware or bloatware.

Chocolatey is more open, more software widely used but not verified by windows are present in chocolatey.

A single powershell command can install chocolatey, runned as admin.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

The commands are similar to [winget](#winget) with the `choco` command.

> i personally use it when i got to be on windows & find it more convenient to use, also for new users because of its native graphical interface `choco install chocolateygui`

To list local installed software
```powershell
choco list --local
```

To upgrade all packages
```powershell
choco upgrade all
```

And the ultimate command entirely remove a software (those commands do the same).


```powershell
choco uninstall package --removedependencies
choco uninstall package -x
```
> if other software use the removed one dependencies, chocolatey doesn't uninstall them & tells you it didn't.


## bonus macos

The macos software management is different from the windows one.

Although, [homebrew](https://brew.sh/) has the same role as [chocolatey](#chocolatey) does for windows.