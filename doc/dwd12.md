# dwd12.sh

DiceWare D12 password generator

## Overview

Documentation for shdoc - https://github.com/reconquest/shdoc

## Index

* [_1text](#_1text)
* [_vprint](#_vprint)
* [_rund12](#_rund12)
* [_sortaword](#_sortaword)
* [_predwd12](#_predwd12)
* [rundwd12](#rundwd12)
* [_dwd12set](#_dwd12set)
* [_dwd12secret](#_dwd12secret)
* [_dwd12words](#_dwd12words)
* [_dwd12verbose](#_dwd12verbose)
* [_showvars](#_showvars)
* [showsets](#showsets)
* [showsecrets](#showsecrets)
* [showinfo](#showinfo)
* [showhelp](#showhelp)
* [_readconf](#_readconf)

### _1text

Prints message in user language, using Gettext

#### Arguments

* **$1** (string): Message in English to translate

### _vprint

Print only if mode verbose is active

#### Arguments

* **$1** (string): Message to print

### _rund12

Run x d12

#### Arguments

* **$1** (int): Number of dices. Default: 1

### _sortaword

Sort a word

#### Arguments

* **$1** (int): Total of volumes

### _predwd12

Sort the passphrase, just positions

#### Arguments

* **$1** (int): Number of volumes (default: 4)
* **$2** (int): Number of words (default: 4)

### rundwd12

Password generator

### _dwd12set

Choose a DWD12 set

#### Arguments

* **$1** (string): Set ID

### _dwd12secret

Choose the secret DWD12 volume

#### Arguments

* **$1** (string): Volume name

### _dwd12words

Set passphrasesize

#### Arguments

* **$1** (int): Passwphrase size

### _dwd12verbose

Set verbose mode

#### Arguments

* **$1** (string): false or true

### _showvars

Prints all variable and values

### showsets

List all available volumes sets

### showsecrets

List all available secret volumes

### showinfo

Prints information about actual vomules set

### showhelp

Print help menu

### _readconf

Read the configuration file. PENDING

