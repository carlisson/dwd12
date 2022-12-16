#!/usr/bin/env bash
# @file dwd12admin.sh
# @brief DiceWare D12 admin tools
# @description
# Documentation for shdoc - https://github.com/reconquest/shdoc

DWD12VERSION='A0.13'

GLOBALSETS=/usr/lib/dwd12/sets
LOCALSETS=/usr/local/lib/dwd12/sets
USERSETS=$HOME/.dwd12/sets

GLOBALSECS=/usr/lib/dwd12/secrets
LOCALSECS=/usr/local/lib/dwd12/secrets
USERSECS=$HOME/.dwd12/secrets

DWD12LOCALE=''
for AUX in $HOME/.dwd12 /usr/local/lib/dwd12 /usr/lib/dwd12 .
do
  if [ -d "$AUX/sets" ]
  then
    DWD12VOLS="$AUX/sets $DWD12VOLS"
  fi
  if [ -d "$AUX/locale" ]
  then
    DWD12LOCALE="$AUX/locale"
  fi
done

destination='user'
name='undefined'

_verbose=0 #Disable
_vfile=$(mktemp)

# Gettext configure
source gettext.sh

# @description Prints message in user language, using Gettext
# @arg $1 string Message in English to translate
_1text() {
	TEXTDOMAINDIR="$DWD12LOCALE" gettext 'DWD12' "$*"
}

# @description Print only if mode verbose is active
# @arg $1 string String to Print
function _vprint {
  echo "${FUNCNAME[1]} $1" >> $_vfile
}

# @description Show global variables, if verbose
# @arg $1 string Text to show that defines the moment of the code
# @stdout Introductory text and variable values
function _showvars {
  if [ $_verbose -eq 2 ]
  then
    echo $1
    printf "%s:\n" "$(_1text "Variables")"
    printf "  %s: %s\n" "$(_1text "Destination")" "$destination"
    printf "  %s: %s\n" "$(_1text "Name")" "$name"
    printf "  %s: %s\n" "$(_1text "Verbose")" "$_verbose"
  fi
}

# @description Set verbose mode on/off
# @arg $1 string Text "true" or "false"
function _setverbose {
  _showvars "$(_1text "Before set verbose")"
  case $1 in
    false )
      _verbose=0
      _vprint "$(_1text "Mode verbose turned off")"
      ;;
    true )
      _verbose=1
      _vprint "$(_1text "Mode verbose turned on")"
      ;;
  esac
  _showvars "$(_1text "After set verbose")"
}

# @description Copy a file to global, local or user directory
# @arg $1 string Origin name
# @arg $2 string Destiny name
function generic_copy {
  local FULLOR ORNAME
  FULLOR="$1"
  ORNAME="$2"
  case "$destination" in
    global )
      FULLDE="$GLOBALSETS/$name"
      mkdir -p "$GLOBALSETS"
      ;;
    local )
      FULLDE="$LOCALSETS/$name"
      mkdir -p "$LOCALSETS"
      ;;
    user )
      FULLDE="$USERSETS/$name"
      mkdir -p "$USERSETS"
      ;;
    * )
      exit;
      ;;
  esac
  if [ -d "$FULLDE" ]
  then
    printf "$(_1text "Set %s yet created in %s!")\n" $name $FULLDE
  else
    _vprint "cp -R $FULLOR $FULLDE"
    cp -R "$FULLOR" "$FULLDE"
  fi
}

# @description Copy full set
# @arg $1 string Set origin
function dcopy {
  local ORIGIN FULLOR
  ORIGIN="$1"
  if [ "$name" = "undefined" ]
  then
    _1text "You need to use -n name to set the name of the copy."
    echo
    exit
  fi
  FULLOR="$USERSETS/$ORIGIN"
  if [ ! -d "$FULLOR" ]
  then
    FULLOR="$LOCALSETS/$ORIGIN"
    if [ ! -d "$FULLOR" ]
    then
      FULLOR="$GLOBALSETS/$ORIGIN"
      if [ ! -d "$FULLOR" ]
      then
        printf "$(_1text "Set %s not found.")\n" $ORIGIN
        exit
      fi
    fi
  fi
  generic_copy "$FULLOR" "$name"
}

# @description Copy a volume from set to a new secret
# @arg $1 string Secret volume origin in form: Set/volume
function scopy {
  local SETNAM VOLNAM FULLOR FULLDE
  SETNAM=$(echo $1 | cut -d\/ -f 1)
  VOLNAM=$(echo $1 | cut -d\/ -f 2)
  if [ "$name" = "undefined" ]
  then
    name="$VOLNAM"
    exit
  fi
  case "$destination" in
    global )
      FULLDE="$GLOBALSECS/$name.txt"
      mkdir -p "$GLOBALSECS"
      ;;
    local )
      FULLDE="$LOCALSECS/$name.txt"
      mkdir -p "$LOCALSECS"
      ;;
    user )
      FULLDE="$USERSECS/$name.txt"
      mkdir -p "$USERSECS"
      ;;
    * )
      exit;
      ;;
  esac
  FULLOR="$USERSETS/$SETNAM"
  if [ ! -d "$FULLOR" ]
  then
    FULLOR="$LOCALSETS/$SETNAM"
    if [ ! -d "$FULLOR" ]
    then
      FULLOR="$GLOBALSETS/$SETNAM"
      if [ ! -d "$FULLOR" ]
      then
        printf "$(_1text "Set %s not found.")\n" $SETNAM
        exit
      fi
    fi
  fi
  FULLOR="$FULLOR/$VOLNAM.txt"
  if [ ! -f "$FULLOR" ]
  then
    printf "$(_1text "Origin volume %s not found in set %s (%s).")\n" "$VOLNAM" "$SETNAM" "$FULLOR"
    exit
  fi
  if [ -f "$FULLDE" ]
  then
    printf "$(_1text "Secret volume named %s exists in %s!")\n" $name $FULLDE
  else
    _vprint "cp $FULLOR $FULLDE"
    cp "$FULLOR" "$FULLDE"
  fi
}

# @description Install a set from current directory
# @arg $1 string Origin set
function setinstall {
  local ORIGIN
  ORIG="$1"
  if [ "$name" = "undefined" ]
  then
    name=$(basename "$ORIG")
  fi
  if [ -d "$ORIG" ]
  then
    _vprint "Installing $ORIG to $destination."
    generic_copy "$ORIG"
  else
    printf "$(_1text "Set %s not found in current directory (%s).")\n" "$ORIG" "$(pwd)"
  fi
}

# @description Print help menu
# @stdout Usage instructions
function showhelp {
  echo "DWD12 Admin $DWD12VERSION"
  echo "      $(_1text "Manage your DWD12 volumes!")"
  echo
  echo "$ dwd12admin [$(_1text "options")]"
  echo
  echo "  -d _dest  $(_1text "Destination (global, local or user)")"
  echo "  -n _new   $(_1text "Destination name")"
  echo "  -c _set   $(_1text "Copy this set")"
  echo "  -x _s/_v  $(_1text "Copy this volume to a secret (setname/volname)")"
  echo "  -i _set   $(_1text "Install this set (directory)")"
  echo "  -I _svol  $(_1text "Install this secret volume [TO DO]")"
  echo "  -u _set   $(_1text "Uninstall this set [TO DO]")"
  echo "  -U _svol  $(_1text "Uninstall this secret volume [TO DO]")"
  echo "  -V _set   $(_1text "List all volumes in a set. [TO DO]")"
  echo "  -s        $(_1text "List all volume sets. [TO DO]")"
  echo "  -S        $(_1text "List all secret volumes [TO DO]")"
  echo "  -v        $(_1text "Enable verbose mode.")"
  echo "  -h        $(_1text "Show this help menu")"
  echo
}

while getopts "d:n:c:i:x:vh" option
do
  case ${option} in
    d  )
      case "$OPTARG" in
        global|local|user)
          destination="$OPTARG"
          _vprint "$(printf "$(_1text "Setting destination to %s")" "$destination")"
          ;;
        *)
          echo "$(_1text "Unknown option! Set destination to global, local or user.")"
          ;;
      esac
      ;;
    n )
      name="$OPTARG"
      _vprint "$(printf "$(_1text "Setting destination name to %s")" "$name")"
      ;;
    c )
      dcopy "$OPTARG"
      ;;
    i )
      setinstall "$OPTARG"
      ;;
    x )
      scopy "$OPTARG"
      ;;
    v ) #Set mode verbose
      _setverbose "true"
      ;;
    h | \? )
      showhelp
      rm $_vfile
      exit
      ;;
  esac
done

if [ $_verbose -gt 0 ]
then
  cat $_vfile
fi
rm $_vfile
