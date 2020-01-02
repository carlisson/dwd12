#!/bin/bash

DWD12VERSION='0.10'

DWD12VOLS=''
for AUX in $HOME/.dwd12/sets /usr/local/lib/dwd12/sets /usr/lib/dwd12/sets ./sets
do
  if [ -d "$AUX" ]
  then
    DWD12VOLS="$AUX $DWD12VOLS"
  fi
done
if [ "$DWD12VOLS" == "" ]
then
  echo "Error! No DWD12 volumes path created."
  exit
fi

DWD12SECRETS='./secrets'

DWD12SET='inicial'

DWD12SIZE=4

_mode="normal"
_verbose=0 #Disable
_vfile=$(mktemp)

# Print only if mode verbose is active
# @param string to Print
function _vprint {
  echo "${FUNCNAME[1]} $1" >> $_vfile
}

# Run x d12
# @param Number of dices. Default: 1
function _rund12 {
	if [ $# -eq 0 ]
	then
		DICES=1
	else
		DICES="$1"
	fi
  _vprint "Roll "$DICES"d12"
	tr -dc '123456789XJQ' < /dev/urandom | head -c "$DICES" | sed 's/\(.\)/\1\  /g' | sed 's/X/10/g' | sed 's/J/11/g' | sed 's/Q/12/g'; echo
}

# Sort a word
# @param Total of volumes
function _sortaword {
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
  _vprint "Will work with $VOLS volumes"
	MV=""
	PLUS=""
	if [ "$VOLS" -ge 10 ]
	then
		(( "V2 = $VOLS - 10" ))
		if [ "$V2" -ge 10 ]
		then
			echo "It don't works for more then 19 volumes."
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
	VOL=$(tr -dc "$MV" < /dev/urandom | head -c 1 | sed 's/^/ /g'; echo)
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
  _vprint "Volume $VOL, $WRD"
  echo "Volume $VOL, $WRD"
}

# Sort the passphrase, just positions
# @param Number of volumes (default: 4)
# @param Number of words (default: 4)
function _predwd12 {
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
		echo -n "WORD $i: "
    _vprint "$VOLS"
		_sortaword "$VOLS"
	done
}

# Password generator
# @param
function rundwd12 {
  VOLS=$_dvls
	echo -n "Passphrase: "
	for j in $(_predwd12 "$VOLS" | sed 's/[[:alpha:]]//g' | sed 's/^ //' | sed 's/://' | sed 's/,//' | sed 's/[ ]\+/-/g')
	do
		#IJ é um array a partir do resultado de sorteio de uma palavra dicewared12
		# onde 0: contagem de palavras; 1: tomo; 2, 3, 4: palavra
		IJ=(${j//-/ })
		JFILE=$(find "$_dset" -maxdepth 1 -type f | sed -n "${IJ[1]}p")
		JWORD=$(( (IJ[2]-1)*144+(IJ[3]-1)*12+IJ[4] ))
		JDW=$(sed -n "$JWORD"p < "$JFILE")
		echo -n "$JDW "
	done
	echo
}

function showinfo {
  echo "DWD12 $DWD12VERSION"
  echo
  echo "Set: $DWD12SET"
  echo "Path: $_dset"
  echo "Volumes: $_dvls"

}

function showhelp {
  echo "DWD12 $DWD12VERSION"
  echo "      Passphrase generator!"
  echo
  echo "$ dwd12 [options]"
  echo
  echo "  -s _set   Generate passphrase using the set _set."
  echo "  -w _size  Gerenate passphrase with _size words."
  echo "  -i        Just show information about selected set."
  echo "  -h        Show this help menu"
  echo
}

while getopts "s:w:ivh" option
do
  case ${option} in
    i ) #Information about the set of volumes
      _mode="info"
      _vprint "Mode set to info"
      ;;
    s ) #Set of volumes
      DWD12SET="$OPTARG"
      _vprint "Selected set $DWD12SET"
      ;;
    v ) #Set mode verbose
      _verbose=1
      _vprint "Mode verbose turned on"
      ;;
    w) #Size of passphrase (in Words)
  		if [ "$OPTARG" -gt 0 ]
    	then
    		if [ "$OPTARG" -lt 50 ]
    		then
    			DWD12SIZE="$OPTARG"
          _vprint "Passphrase size set to $DWD12SIZE"
    		fi
    	fi
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

# _vols=$(find "$_7LIB/dwvols" -maxdepth 1 -type f | wc -l)
_dset=$(find $DWD12VOLS -name $DWD12SET)
_dvls=$(find "$_dset" -maxdepth 1 -type f | wc -l)
if [ "$_dset" = "" ]
then
  echo "Error. Set $DWD12SET not found."
else
  case ${_mode} in
    info)
      showinfo
    ;;
    normal)
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
