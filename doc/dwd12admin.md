# dwd12admin.sh

DiceWare D12 admin tools

## Overview

Documentation for shdoc - https://github.com/reconquest/shdoc

## Index

* [function _vprint {](#function-_vprint-)
* [function _showvars {](#function-_showvars-)
* [function _setverbose {](#function-_setverbose-)
* [function generic_copy {](#function-generic_copy-)
* [function dcopy {](#function-dcopy-)
* [function scopy {](#function-scopy-)
* [function setinstall {](#function-setinstall-)
* [function showhelp {](#function-showhelp-)

### function _vprint {

Print only if mode verbose is active

#### Arguments

* **$1** (string): String to Print

### function _showvars {

Show global variables, if verbose

#### Arguments

* **$1** (string): Text to show that defines the moment of the code

#### Output on stdout

* Introductory text and variable values

### function _setverbose {

Set verbose mode on/off

#### Arguments

* **$1** (string): Text "true" or "false"

### function generic_copy {

Copy a file to global, local or user directory

#### Arguments

* **$1** (string): Origin name
* **$2** (string): Destiny name

### function dcopy {

Copy full set

#### Arguments

* **$1** (string): Set origin

### function scopy {

Copy a volume from set to a new secret

#### Arguments

* **$1** (string): Secret volume origin in form: Set/volume

### function setinstall {

Install a set from current directory

#### Arguments

* **$1** (string): Origin set

### function showhelp {

Print help menu

#### Output on stdout

* Usage instructions

