#!/usr/bin/env bash

DWD12ADMINVERSION='0.6'

GLOBALSETS=/usr/lib/dwd12/sets
LOCALSETS=/usr/local/lib/dwd12/sets
USERSETS=$HOME/.dwd12/sets

GLOBALSECS=/usr/lib/dwd12/secrets
LOCALSECS=/usr/local/lib/dwd12/secrets
USERSECS=$HOME/.dwd12/secrets

destination='user'
name='undefined'

_verbose=0 #Disable
_vfile=$(mktemp)

# Print only if mode verbose is active
# @param string to Print
function _vprint {
  echo "${FUNCNAME[1]} $1" >> $_vfile
}

function _showvars {
  if [ $_verbose -eq 2 ]
  then
    echo $1
    echo "Variables:"
    echo "  Destination: $destination"
    echo "  Name: $name"
    echo "  Verbose: $_verbose"
  fi
}

function _setverbose {
  _showvars "Before set verbose"
  case $1 in
    false )
      _verbose=0
      _vprint "Mode verbose turned off"
      ;;
    true )
      _verbose=1
      _vprint "Mode verbose turned on"
      ;;
  esac
  _showvars "After set verbose"
}

function generic_copy {
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
    echo "Set $name yet created in $FULLDE!"
  else
    _vprint "cp -R $FULLOR $FULLDE"
    cp -R "$FULLOR" "$FULLDE"
  fi
}

# Copy full set
function dcopy {
  ORIGIN="$1"
  if [ "$name" = "undefined" ]
  then
    echo "You need to use -n name to set the name of the copy."
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
        echo "Set $ORIGIN not found."
        exit
      fi
    fi
  fi
  generic_copy "$FULLOR" "$name"
}

# Copy a volume from set to a new secret
function scopy {
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
        echo "Set $SETNAM not found."
        exit
      fi
    fi
  fi
  FULLOR="$FULLOR/$VOLNAM.txt"
  if [ ! -f "$FULLOR" ]
  then
    echo "Origin volume $VOLNAM not found in set $SETNAM ($FULLOR)."
    exit
  fi
  if [ -f "$FULLDE" ]
  then
    echo "Secret volume named $name exists in $FULLDE!"
  else
    _vprint "cp $FULLOR $FULLDE"
    cp "$FULLOR" "$FULLDE"
  fi
}

# Install a set from current directory
function setinstall {
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
    echo "Set $ORIG not found in current directory ($(pwd))"
  fi
}

# Print help menu
function showhelp {
  echo "DWD12 Admin $DWD12ADMINVERSION"
  echo "      Manage your DWD12 volumes!"
  echo
  echo "$ dwd12admin [options]"
  echo
  echo "  -d _dest  Destination (global, local or user)"
  echo "  -n _new   Destination name"
  echo "  -c _set   Copy this set"
  echo "  -x _s/_v  Copy this volume to a secret (setname/volname)"
  echo "  -i _set   Install this set (directory)"
  echo "  -I _svol  Install this secret volume [TO DO]"
  echo "  -u _set   Uninstall this set [TO DO]"
  echo "  -U _svol  Uninstall this secret volume [TO DO]"
  echo "  -V _set   List all volumes in a set. [TO DO]"
  echo "  -s        List all volume sets. [TO DO]"
  echo "  -S        List all secret volumes [TO DO]"
  echo "  -v        Enable verbose mode."
  echo "  -h        Show this help menu"
  echo
}

while getopts "d:n:c:i:x:vh" option
do
  case ${option} in
    d  )
      case "$OPTARG" in
        global|local|user)
          destination="$OPTARG"
          _vprint "Setting destination to $destination"
          ;;
        *)
          echo "Unknown option! Set destination to global, local or user."
          ;;
      esac
      ;;
    n )
      name="$OPTARG"
      _vprint "Setting destination name to $name"
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
