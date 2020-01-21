#!/usr/bin/env bash

DWD12ADMINVERSION='0.1'

GLOBALSETS=/usr/lib/dwd12/sets
LOCALSETS=/usr/local/lib/dwd12/sets
USERSETS=$HOME/.dwd12/sets

GLOBALSECS=/usr/lib/dwd12/secrets
LOCALSECS=/usr/local/lib/dwd12/secrets
USERSECS=$HOME/.dwd12/secrets

_verbose=0 #Disable
_vfile=$(mktemp)

# Print only if mode verbose is active
# @param string to Print
function _vprint {
  echo "${FUNCNAME[1]} $1" >> $_vfile
}

# Print help menu
function showhelp {
  echo "DWD12 Admin $DWD12VERSION"
  echo "      Manage your DWD12 volumes!"
  echo
  echo "$ dwd12admin [options]"
  echo
  echo "  -d _dest  Destination (global, local or user) [TO DO]"
  echo "  -n _new   Destination name [TO DO]"
  echo "  -c _set   Copy this set [TO DO]"
  echo "  -x _vol   Copy this volume to a secret [TO DO]"
  echo "  -i _set   Install this set (directory) [TO DO]"
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

while getopts "s:x:z:w:lXivh" option
do
  case ${option} in
    h  )
      showhelp
      rm $_vfile
      exit
      ;;
    \? ) #For invalid option
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
