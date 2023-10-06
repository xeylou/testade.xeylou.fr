---
title: "programming knowledge"
date: 2023-09-03
draft: true
tags: [ "coding", "programming", "languages" ]
slug: "programming-knowledge"
---

<!-- prologue -->

{{< lead >}}
explaining some coding   
& programming concepts
{{< /lead >}}

<!-- article -->

## introduction

i've been coding & programming for about 3 years now & i think i am safe to say i know a thing or two

i merged knowledge & research to expose some coding & programming concepts

i won't be talking about development, just coding & progamming related stuff *- see below*

coding is the way to implement things, giving instructions to computers & learn how things works, e.g. coding sorting algorithms

programming is the way to use coding skills to create something or solve a problem using coding experience, e.g. programming a reservation planning

development (*by developpers obviously*) regroup processes like evaluating, conceiving, programming, documenting, testing, etc. a solution, e.g. developping a webapp

## languages levels

programming languages can be seperated in various ways, one of which is their proxmity to the computer language

### low-level
<!-- https://www.javatpoint.com/what-is-a-low-level-language -->

low-level languages aim to be near computer language

their code give computer hardware instructions to perform manipulations on its components

practicing a low-level programming language makes you learn a lot about how components & their communications works

<!-- dealing w/ the hardware, they work to control computer's operational semantics & provide little or no abstraction of programming ideas -->

they are used to control computer's operational semantics & provide little or no abstraction of programming ideas

since they are dealing w/ the hardware, the code can change from a computer to another depending of its hardware specification or architecture

they are oftenly non human-readable & have a relatively slow learning curve

those languages also let the programmer a wide control on storage, memory or cpu usage

the assembly language or the machine language/binary code are two types of low-level languages, e.g. assembler

they are commonly used to write kernels & drivers

### high-level
<!-- https://www.webopedia.com/definitions/high-level-language/ -->
closer to human language, high-level programming languages are for every day coding or programming stuff

they help developers by avoiding to manually give instructions to components and focus on their projects 

<!-- *(algebra, arithmetic, algorithms...)* -->

<!-- variables creation is straightforward & methods do manipulation on them w/out seeing the components -->

when comparing the performance of a low-level & a high-level language for the same task, the low-level one will be much faster: it requires little interpretation by the computer

all high-level languages require their code to be understandable by the computer, since they are human readable at first

an `interpreter` handle the translation of this code to bytecode

## paradigm
<!--
https://www.youtube.com/watch?v=HlgG395PQWw

https://www.youtube.com/watch?v=UOkOA6W-vwc
https://www.youtube.com/watch?v=B1p5OlO5tWg
-->

paradigms are the concepts used to structure & to think about code

<!-- followed by a programming language, the way your code will be structured -->

two main paradigms substain: imperative & declarative *oftenly called "functional"*

these two main paradigms has derived types of paradigms

programming languages can follow one *single paradigm* or more paradigms *multi paradigm*

### imperative

the *imperative paradigm* is based on instructing the machine how to change its state

to do so, the programmer gives explicit instructions, the *how*: do X then Y ~ to get Z

#### procedural

the *procedural paradigm* is based on the imperative one

procedural code instructs the device on how to finish a task in logical given steps (procedures)

in other words: the code gives a sequence of instructions to the computer

the code can be human read from top to bottom whereas the machine will look for procedures inside the code

it is the most known paradigm, using functions, local or global variables, doing parameters passing, etc.

#### object-oriented

*object-oriented paradigm* is based on objects, which are a structure that contain data or code

objects are reusable piece of code, like a blueprint, which can have `instances` of it

considering the "Persons" object, each instance of this object would have the same patern: a name, a surname, an age, etc.

*i took back the example of the [itop artcle](https://xeylou.fr/posts/itop-tour)*

`methods` can be called on the instances to modify them or do a specific action

### declarative

the *declarative paradigm* describe the *goal*, giving the wanted outcome rather than how to acheive it

the programmers giving the *what*: give me Z ~ using X & Y

declarative based paradigm get rid of control flow e.g. `if/else` statements or `loops`

#### functional

*functional programming* is all about functions

functions, like in math, can have functions in parameters, & can return a function

following this idea, to save the state of a function & use it later, there are `closures`

there is plenty to learn: high order functions, pure functions, currying, monads, etc.

functional programming is a good way to think about data immutability, apart from its unusual code approach

## typing

programming languages has some differences in their way to declare variables

they can be regrouped as so according to how they type them

### statically typed

*statically typed* languages, or *strongly typed*

are a way to think about the type of variable the programmer is using when coding

when declarating a variable, it requires to specify its type *(list, strings, integer, etc.)* to make a memory record

as so, the programmer as much control on its memory usage & what its variables will become

*side note: the typescript language is the statically typed version of javascript, a dynamically typed languge*
<!-- immutability objects? -->
<!-- typescript = js en statique -->

### dynamically typed

*dynamically typed* languages

are "made" to be quicker since all types a variable can become an other type of variable

the same list variable car become a string & after a interger in the same execution

python & javascript are two main languages that are dynamically typed

<!-- peut aller avec mutability/mutable objects -->
<!-- en python, un tableau peut devenir un entier, puis une chaine de charactère... -->

## bordel

programming model  
parallel computing  
execution model  
<!-- https://en.wikipedia.org/wiki/List_of_programming_languages_by_type -->

### interpreted

donne des erreurs lors de l'exécution
### compiled
donne des erreurs lors du compil
<!-- python compile en bytecode puis interprete donc pas bon exemple -->

<!-- ## type of language
### machine language
### assembly language -->

<!-- ## simple objects
### intergers
### floats
### strings
### lists
https://stackoverflow.com/questions/176011/python-list-vs-array-when-to-use
### arrays -->

## concepts
pointers, heritage, polymorphism, heuristic, data structure, etc.
### pointers
<!-- pour les deux en dessous prendre exemple de c & c++ -->
### heritage
### polymorphism
### heuristic
### data structure
### libraries

<!--
high level
low level

machine language
assembly language

compiled
interpreted

-- structuring
object-oriented
procedural

statically typed
dynamically typed

heritage
polymorphism
pointers

mutability
immutability objects

data structure
binary tree...

algorithms (sorting)
bubble, selection, insertion, 


libraries
-->
