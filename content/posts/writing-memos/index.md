---
title: "writing memos"
date: 2023-07-18T22:33:59+02:00
lastmod: 2023-07-19T22:33:59+02:00
draft: true
tags: ["testing", "syntax"]
series: ["Testing"]
series_order: 1
slug: changing-page-url
summary: "test"

---
{{< lead >}}
this document is a draft that  
contains personal info about writing
{{< /lead >}}

## overall aspect

- never use caps in titles (look at page title)

{{< button href="https://ninite.com/" target="_blank" >}}
OUVRIR LIEN DANS NOUVEL ONGLET
{{< /button >}}

{{< button href="https://ninite.com/" target="_target" >}}
OUVRIR LIEN, POUR DOWNLOAD
{{< /button >}}

- [x] huh
   - [ ] huh

### be a part of a series

see code above

### start an article

using lead for a very small description like above

{{< lead >}}
text
{{< /lead >}}

### mathematics formula
{{< katex >}}
\\(f(a,b,c) = (a^2+b^2+c^2)^3\\)

Inline notation: \\(\varphi = \dfrac{1+\sqrt5}{2}= 1.6180339887…\\) (double antislash delimeters)

Bloc notation (double dollars delimiters): 
$$
 \varphi = 1+\frac{1} {1+\frac{1} {1+\frac{1} {1+\cdots} } }
$$


### notes

{{< alert icon="fire">}}
**Info** That's kind of cool
{{< /alert >}}

{{< alert cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
**Never do ...**
{{< /alert >}}

{{< button href="https://github.com/xeylou" target="_self" >}}
Download the latest iso image
{{< /button >}}


### maps

{{< mermaid >}}
%%{init: {'theme':'base'}}%%
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

{{< mermaid >}}
%%{init: {'theme':'default'}}%%
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

{{< mermaid >}}
%%{init: {'theme':'forest'}}%%
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

{{< mermaid >}}
%%{init: {'theme':'neutral'}}%%
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

{{< mermaid >}}
%%{
  init: {
    'theme': 'base',
    'themeVariables': {
      'primaryColor': '#BB2528',
      'primaryTextColor': '#fff',
      'primaryBorderColor': '#7C0000',
      'lineColor': '#F8B229',
      'secondaryColor': '#006100',
      'tertiaryColor': '#fff'
    }
  }
}%%
        graph TD
          A[Christmas] -->|Get money| B(Go shopping)
          B --> C{Let me think}
          B --> G[/Another/]
          C ==>|One| D[Laptop]
          C -->|Two| E[iPhone]
          C -->|Three| F[fa:fa-car Car]
          subgraph section
            C
            D
            E
            F
            G
          end
{{< /mermaid >}}

[doc](https://mermaid.js.org/config/theming.html) [doc](https://mermaid.js.org/intro/n00b-syntaxReference.html)

ways to show a specific workflow  
adding white background for dark themes

<div style="background-color:white">
{{< mermaid >}}
graph LR;
A[Entry]-->B[System];
B-->C[Output]
{{< /mermaid >}}
</div>

flowchart
<div style="background-color:white">

{{< mermaid >}}
graph TD
A[Christmas] -->|Get money| B(Go shopping)
B --> C{Let me think}
B --> G[/Another/]
C ==>|One| D[Laptop]
C -->|Two| E[iPhone]
C -->|Three| F[Car]
subgraph Section
C
D
E
F
G
end
{{< /mermaid >}}
</div>

flowchart
<div style="background-color:white">

{{< mermaid >}}
graph LR
A[Christmas] -->|Get money| B(Go shopping)
B --> C{Let me think}
B --> G[/Another/]
C ==>|One| D[Laptop]
C -->|Two| E[iPhone]
C -->|Three| F[Car]
subgraph Section
C
D
E
F
G
end
{{< /mermaid >}}
</div>

sequence diagram

<div style="background-color:white">
{{< mermaid >}}
sequenceDiagram
autonumber
par Action 1
Alice->>John: Hello John, how are you?
and Action 2
Alice->>Bob: Hello Bob, how are you?
end
Alice->>+John: Hello John, how are you?
Alice->>+John: John, can you hear me?
John-->>-Alice: Hi Alice, I can hear you!
Note right of John: John is perceptive
John-->>-Alice: I feel great!
loop Every minute
John-->Alice: Great!
end
{{< /mermaid >}}
</div>

class diagram
<div style="background-color:white">
{{< mermaid >}}
classDiagram
Animal "1" <|-- Duck
Animal <|-- Fish
Animal <--o Zebra
Animal : +int age
Animal : +String gender
Animal: +isMammal()
Animal: +mate()
class Duck{
+String beakColor
+swim()
+quack()
}
class Fish{
-int sizeInFeet
-canEat()
}
class Zebra{
+bool is_wild
+run()
}
{{< /mermaid >}}
</div>

entry relationship

<div style="background-color:white">
{{< mermaid >}}
erDiagram
CUSTOMER }|..|{ DELIVERY-ADDRESS : has
CUSTOMER ||--o{ ORDER : places
CUSTOMER ||--o{ INVOICE : "liable for"
DELIVERY-ADDRESS ||--o{ ORDER : receives
INVOICE ||--|{ ORDER : covers
ORDER ||--|{ ORDER-ITEM : includes
PRODUCT-CATEGORY ||--|{ PRODUCT : contains
PRODUCT ||--o{ ORDER-ITEM : "ordered in"
{{< /mermaid >}}
</div>

[documentation](https://blowfish.page/samples/diagrams-flowcharts/) & [here](https://github.com/bep/goat)


## code and it's beautifying
related code stuff. everything will be write in `bash` but can be changed

### commands
```bash
mkdir git-project
cd git-project
git init
```

### edit a file
Explain what your are doing with the `path/to/the/file` before showing changes
```sh {linenos=table}
# /bin/sh

$test = 1
echo $test
```
can be related to [this](#indicate-numbers)

### tree
```
.
├── build
├── flake.nix
├── flake.lock
├── home
│  ├── config.nix
│  ├── home.nix
│  ├── modules
│  ├── overlays
│  ├── programs
│  ├── scripts
│  ├── secrets
│  ├── services
│  └── themes
├── imgs
├── notes
├── outputs
│  ├── home-conf.nix
│  └── nixos-conf.nix
└── system
   ├── cachix
   ├── cachix.nix
   ├── configuration.nix
   ├── fonts
   ├── machine
   ├── misc
   └── wm
```

do not copy code by selecting it but press the copy button (edited in toml)
```sh

```
### indicate numbers
> sometimes for lines, copy paste the third & remove hl_lines
```sh {linenos=table}
mkdir -p ~/testing-issues
cd testing-issues
echo "issue solved!"
```
if i want to show a part of a file (only showing specific lines of a big file)
```sh {linenos=table, linenostart=52}
mkdir -p ~/testing-issues
cd testing-issues
echo "issue solved!"
```
hilighting changes or what i am talking about
> hl_lines specify the line number of the code bloc below
```sh {linenos=table, hl_lines=["3-4"], linenostart=2}
echo "test"

# highlighting
# test

echo "done"
```