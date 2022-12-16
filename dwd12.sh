#!/bin/bash
# @file dwd12.sh
# @brief DiceWare D12 password generator
# @description
# Documentation for shdoc - https://github.com/reconquest/shdoc

DWD12VERSION='A0.14'

# Gettext configure
source gettext.sh

# @description Prints message in user language, using Gettext
# @arg $1 string Message in English to translate
_1text() {
	TEXTDOMAINDIR="$DWD12LOCALE" gettext 'DWD12' "$*"
}

DWD12VOLS=''
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
if [ "$DWD12VOLS" == "" ]
then
  _1text "Error! No DWD12 volumes path created."
  echo
  exit
fi
if [ "$DWD12LOCALE" == "" ]
then
  DWD12LOCALE="locale/"
fi

DWD12SECRETS=''
for AUX in $HOME/.dwd12/secrets /usr/local/lib/dwd12/secrets /usr/lib/dwd12/secrets ./secrets
do
  if [ -d "$AUX" ]
  then
    DWD12SECRETS="$AUX $DWD12SECRETS"
  fi
done
if [ "$DWD12SECRETS" == "" ]
then
  _1text "Error! No DWD12 secrets path created."
  echo
  exit
fi
DWD12SIZE=4
_mode="normal"
_verbose=0 #Disable
_vfile=$(mktemp)

# @description Print only if mode verbose is active
# @arg $1 string Message to print
_vprint() {
  echo "${FUNCNAME[1]} $*" >> $_vfile
}

# @description Run x d12
# @arg $1 int Number of dices. Default: 1
_rund12() {
  local DICES
	if [ $# -eq 0 ]
	then
		DICES=1
	else
		DICES="$1"
	fi
  _vprint "$(printf "$(_1text "Roll %sd12")" "$DICES")"
	tr -dc '123456789XJQ' < /dev/urandom | head -c "$DICES" | sed 's/\(.\)/\1\  /g' | sed 's/X/10/g' | sed 's/J/11/g' | sed 's/Q/12/g'; echo
}

# @description Sort a word
# @arg $1 int Total of volumes
_sortaword() {
  local VOLS MV PLUS V2 WRD VOL MSG
	VOLS=$_dvls
	if [ "$#" -ge 1 ]
	then
		if [ "$1" -gt 0 ]
		then
			if [ "$1" -lt 20 ]
			then
				VOLS="$1"
			fi
		fi
	fi
  _vprint "$(printf "$(_1text "Will work with %i volumes.")" "$VOLS")"
	MV=""
	PLUS=""
	if [ "$VOLS" -ge 10 ]
	then
		(( "V2 = $VOLS - 10" ))
		if [ "$V2" -ge 10 ]
		then
			_1text "It don't works for more then 19 volumes."
      echo
			return 1
		fi
		PLUS="A"
		if [ "$V2" -ge 1 ]; then PLUS="$PLUS""B"; fi
		if [ "$V2" -ge 2 ]; then PLUS="$PLUS""C"; fi
		if [ "$V2" -ge 3 ]; then PLUS="$PLUS""D"; fi
		if [ "$V2" -ge 4 ]; then PLUS="$PLUS""E"; fi
		if [ "$V2" -ge 5 ]; then PLUS="$PLUS""F"; fi
		if [ "$V2" -ge 6 ]; then PLUS="$PLUS""G"; fi
		if [ "$V2" -ge 7 ]; then PLUS="$PLUS""H"; fi
		if [ "$V2" -ge 8 ]; then PLUS="$PLUS""I"; fi
		if [ "$V2" -ge 9 ]; then PLUS="$PLUS""J"; fi
	fi
	if [ "$VOLS" -ge 1 ]; then MV="1"; fi
	if [ "$VOLS" -ge 2 ]; then MV="$MV""2"; fi
	if [ "$VOLS" -ge 3 ]; then MV="$MV""3"; fi
	if [ "$VOLS" -ge 4 ]; then MV="$MV""4"; fi
	if [ "$VOLS" -ge 5 ]; then MV="$MV""5"; fi
	if [ "$VOLS" -ge 6 ]; then MV="$MV""6"; fi
	if [ "$VOLS" -ge 7 ]; then MV="$MV""7"; fi
	if [ "$VOLS" -ge 8 ]; then MV="$MV""8"; fi
	if [ "$VOLS" -ge 9 ]; then MV="$MV""9"; fi
	MV="$MV$PLUS"
	WRD=$(_rund12 3)
	VOL=$(tr -dc "$MV" < /dev/urandom | head -c 1 | sed 's/^//g'; echo)
	if [ "$VOL" = 'A' ]; then VOL=10; fi
	if [ "$VOL" = 'B' ]; then VOL=11; fi
	if [ "$VOL" = 'C' ]; then VOL=12; fi
	if [ "$VOL" = 'D' ]; then VOL=13; fi
	if [ "$VOL" = 'E' ]; then VOL=14; fi
	if [ "$VOL" = 'F' ]; then VOL=15; fi
	if [ "$VOL" = 'G' ]; then VOL=16; fi
	if [ "$VOL" = 'H' ]; then VOL=17; fi
	if [ "$VOL" = 'I' ]; then VOL=18; fi
	if [ "$VOL" = 'J' ]; then VOL=19; fi
  MSG="$(printf "$(_1text "Volume %i, %s")" $VOL "$WRD")"
  _vprint "$MSG"
  echo "$MSG"
}

# @description Sort the passphrase, just positions
# @arg $1 int Number of volumes (default: 4)
# @arg $2 int Number of words (default: 4)
_predwd12() {
  local VOLS MSG

	VOLS=$_dvls
	if [ "$#" -ge 1 ]
	then
		if [ "$1" -gt 0 ]
		then
			if [ "$1" -lt 20 ]
			then
				VOLS="$1"
			fi
		fi
	fi
	for i in $(seq 1 "$DWD12SIZE")
	do
		MSG="$(printf "$(_1text "WORD %i: %s")" $i "$(_sortaword "$VOLS")")"
    _vprint "$MSG"
    echo "$MSG"
	done
}

# @description Password generator
rundwd12() {
  local ACTPOS VOLS SECPOS j IJ
  ACTPOS=0
  _vprint "$(printf "$(_1text "Running with %s set. Generating passphrase with %i words.")" "$DWD12SET" $DWD12SIZE)"
  
  if [ "$_mode" == "secure" ]
  then
    VOLS=$_dvls
    SECPOS=$(shuf -i 1-$DWD12SIZE -n 1)
    _vprint "$(printf "$(_1text "The position %i will turn into a secret-vol word.")" "$SECPOS")"
  else
    VOLS=$((_dvls + _dsec))
    SECPOS=-1
    if [ $_dsec -eq 1 ]
    then
      _vprint "$(printf "$(_1text "There are %i volumes. Number %i is the secret (%s)!")" $_dvls $VOLS "$DWD12SEC")"
    fi
  fi

  if [ $_verbose -eq 1 ]
  then
    _1text "Passphrase: "
  fi

	for j in $(_predwd12 "$VOLS" | \
      sed 's/[[:alpha:]]//g' | \
      sed 's/^ //' | \
      sed 's/://' | \
      sed 's/,//' | \
      sed 's/[ ]\+/-/g')
	do

		#IJ is an array from word shuffle result from dwd12
		# 0: word counter; 1: vol; 2, 3, 4: words
		IJ=(${j//-/ })
    ACTPOS=$((ACTPOS + 1))
    if [ $_dsec -eq 1 ]
    then
      # If mode is normal, x==max+1 => special
      # If mode is secure, secpos is a random number in (1..max)
      if [ ${IJ[1]} -eq $((_dvls + 1)) -o $ACTPOS -eq $SECPOS ]
      then
        JFILE=$(find $DWD12SECRETS -maxdepth 1 -name "$DWD12SEC.txt" | head -1)
      else
		    JFILE=$(find "$_dset" -maxdepth 1 -type f | sed -n "${IJ[1]}p")
      fi
    else
      JFILE=$(find "$_dset" -maxdepth 1 -type f | sed -n "${IJ[1]}p")
    fi
    _vprint "$(printf "$(_1text "Using a word from volume %s.")" "$JFILE")"
		JWORD=$(( (IJ[2]-1)*144+(IJ[3]-1)*12+IJ[4] ))
		JDW=$(sed -n "$JWORD"p < "$JFILE")
		echo -n "$JDW "
	done
	echo
}

# @description Choose a DWD12 set
# @arg $1 string Set ID
_dwd12set() {
  DWD12SET="$1"
  _vprint "$(printf "$(_1text "Selected set %s")" "$DWD12SET")"
}

# @description Choose the secret DWD12 volume
# @arg $1 string Volume name
_dwd12secret() {
  local _dsec
  if [ $(find $DWD12SECRETS -mindepth 1 -maxdepth 1 -name $1.txt | head -1) != "" ]
  then
    _dsec=1
    DWD12SEC="$1"
    _vprint "$(printf "$(_1text "Selected secret volume %s")" "$DWD12SEC")"
  else
    printf "$(_1text "Error! Secret volume %s not found.")\n" "$1"
    rm $_vfile
    exit
  fi
}

# @description Set passphrasesize
# @arg $1 int Passwphrase size
_dwd12words() {
  if [ "$1" -gt 0 ]
  then
    if [ "$1" -lt 50 ]
    then
      DWD12SIZE="$1"
      _vprint "$(printf "$(_1text "Passphrase size set to %i")" $DWD12SIZE)"
    fi
  fi
}

# @description Set verbose mode
# @arg $1 string false or true
_dwd12verbose() {
  _showvars "Before set verbose"
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
  _showvars "After set verbose"
}

# @description Prints all variable and values
_showvars() {
  if [ $_verbose -eq 2 ]
  then
    echo $1
    printf "$(_1text "Variables:")\n"
    printf "  $(_1text "Set: %s")\n" "$DWD12SET"
    printf "  $(_1text "Secret: %s")\n" "$DWD12SEC"
    printf "  $(_1text "Mode: %s")\n" "$_mode"
    printf "  $(_1text "Size: %i words")\n" $DWD12SIZE
    printf "  $(_1text "Verbose: %s")\n" "$_verbose"
  fi
}

# @description List all available volumes sets
showsets() {
  local s
  for s in $(find $DWD12VOLS -mindepth 1 -maxdepth 1 -type d)
  do
    echo $(basename $s) "  $s"
  done
}

# @description List all available secret volumes
showsecrets() {
  local s
  for s in $(find $DWD12SECRETS -maxdepth 1 -name '*.txt')
  do
    echo $(basename $s .txt) "  $s"
  done
}

# @description Prints information about actual vomules set
showinfo() {
  local i
  echo "DWD12 $DWD12VERSION"
  echo $0
  echo
  printf "$(_1text "Set: %s")\n" "$DWD12SET"
  printf "$(_1text "Path: %s")\n" "$_dset"
  printf "$(_1text "Volumes: %s")\n" "$_dvls"
  for i in $(find "$_dset" -maxdepth 1 -type f)
  do
    echo "  -" $(basename $i)
  done
  echo

  if [ $_dsec == 0 ]
  then
    printf "$(_1text "Not using secret volume.")\n"
  else
    printf "$(_1text "Secret volume: %s")\n" "$DWD12SEC"
  fi

  for i in $DWD12VOLS
  do
    printf "$(_1text "Sets in %i: %s.")\n" $i "$(ls $i | wc -l)"
  done

}

# @description Print help menu
showhelp() {
  echo "DWD12 $DWD12VERSION"
  echo "      $(_1text "Passphrase generator!")"
  echo
  echo "$ dwd12 [$(_1text "options")]"
  echo
  echo "  -s _set   $(_1text "Generate passphrase using the set _set.")"
  echo "  -x _svol  $(_1text "Use given secret volume.")"
  echo "  -z _svol  $(_1text "Use given secret volume (exactly 1 of the words in passphrase).")"
  echo "  -w _size  $(_1text "Gerenate passphrase with _size words.")"
  echo "  -i        $(_1text "Just show information about selected set.")"
  echo "  -l        $(_1text "List all volumes sets available to use.")"
  echo "  -X        $(_1text "List all secret volumes available.")"
  echo "  -v        $(_1text "Enable verbose mode.")"
  echo "  -h        $(_1text "Show this help menu")"
  echo
}

# @description Read the configuration file. PENDING
_readconf() {
  local FILE RCPARAM RCVALUE DWD12SET DWD12SEC _dsec
  FILE="$1"
  if [ -f "$FILE" ]
  then
    for line in $(egrep -v '^#' "$FILE" | egrep -v '^$')
    do
      RCPARAM=$(echo "$line" | cut -d '=' -f 1)
      RCVALUE=$(echo "$line" | cut -d '=' -f 2-)
      _vprint "From $FILE, $RCPARAM set to $RCVALUE"
      case $RCPARAM in
        SET ) _dwd12set "$RCVALUE" ;;
        SECRET ) _dwd12secret "$RCVALUE" ;;
        MODE )
          case "$RCVALUE" in
            normal | secure )
              _mode=$RCVALUE
              _vprint "$(printf "$(_1text "Mode set to %s")" "$RCVALUE")"
              ;;
            secret ) _mode=normal ;;
            * ) _vprint "$(printf "$(_1text "Invalid option (%s) to %s.")" "$RCVALUE" "$RCPARAM")"
          esac
          ;;
        WORDS ) _dwd12words "$RCVALUE" ;;
        VERBOSE )
          _dwd12verbose "$RCVALUE"
          ;;
      esac
    done
    _showvars "$(_1text "Inside readconf, middle.")"
  else
    _vprint "$(printf "$(_1text "Config file %s not found.")" "$FILE")"
  fi
  _showvars "$(_1text "Inside readconf, before go out.")"
}


# MAIN CODE

DWD12SET=$(showsets | head -1 | cut -d\  -f 1)
DWD12SEC=$(basename $(find secrets -name '*.txt' | head -1) .txt)
_dsec=0

_showvars "$(_1text "Before configuration file")"

_readconf "/etc/dwd12/dwd12.conf"
_readconf "$HOME/.dwd12/dwd12.conf"

_showvars "$(_1text "After configuration file")"

while getopts "s:x:z:w:lXivh" option
do
  case ${option} in
    i ) #Information about the set of volumes
      _mode="info"
      _vprint "$(_1text "Mode set to info")"
      ;;
    s ) #Set of volumes
      _dwd12set "$OPTARG"
      ;;
    x ) #Set the secret volume
        _dwd12secret "$OPTARG"
        ;;
    z ) #Set the secret volume
        _dwd12secret "$OPTARG"
        _mode="secure"
        ;;
    v ) #Set mode verbose
      _dwd12verbose "true"
      ;;
    w) #Size of passphrase (in Words)
      _dwd12words "$OPTARG"
      ;;
    l  ) #List all sets available
      _1text "Sets available: "
      showsets
      rm $_vfile
      exit

      ;;
    X  ) # List all secret volumes
      _1text "Secret volumes: "
      showsecrets
      rm $_vfile
      exit

      ;;
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

_dset=$(find $DWD12VOLS -name $DWD12SET | head -1)
_dvls=$(find "$_dset" -maxdepth 1 -type f | wc -l)

if [ "$_dset" = "" ]
then
  printf "$(_1text "Error. Set %s not found.")" "$DWD12SET"
else
  case ${_mode} in
    info)
      showinfo
    ;;
    normal|secure)
      FINAL=$(rundwd12)
      if [ $_verbose -gt 0 ]
      then
        cat $_vfile
      fi
      echo $FINAL
      rm $_vfile
    ;;
  esac
fi
