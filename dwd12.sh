#!/bin/bash

DWD12VERSION='0.4'
DWD12VOLS='./sets/inicial'
DWD12SECRETS='./secrets'

# Run x d12
# @param Number of dices. Default: 1
function _rund12 {
	if [ $# -eq 0 ]
	then
		DICES=1
	else
		DICES="$1"
	fi
	tr -dc '123456789XJQ' < /dev/urandom | head -c "$DICES" | sed 's/\(.\)/\1\  /g' | sed 's/X/10/g' | sed 's/J/11/g' | sed 's/Q/12/g'; echo
}

# Sort a word
# @param Total of volumes
function _sortaword {
	VOLS=4 # UPDATE TO NUMBER OF VOLS IN SET
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
	echo "Tomo $VOL, $WRD"
}

# Sort the passphrase, just positions
# @param Number of volumes (default: 4)
# @param Number of words (default: 4)
function _predwd12 {
	VOLS=5
	WORDS=4
	if [ "$#" -gt 1 ]
	then
		if [ "$2" -gt 0 ]
		then
			if [ "$2" -lt 50 ]
			then
				WORDS="$2"
			fi
		fi
	fi
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
	for i in $(seq 1 "$WORDS")
	do
		echo -n "WORD $i: "
		_sortaword "$VOLS"
	done
}

# Password generator
# @param
function rundwd12 {
  VOLS=4
	echo -n "Passphrase: "
	for j in $(_predwd12 "$VOLS" | sed 's/[[:alpha:]]//g' | sed 's/^ //' | sed 's/://' | sed 's/,//' | sed 's/[ ]\+/-/g')
	do
		#IJ é um array a partir do resultado de sorteio de uma palavra dicewared12
		# onde 0: contagem de palavras; 1: tomo; 2, 3, 4: palavra
		IJ=(${j//-/ })
		JFILE=$(find "$DWD12VOLS" -maxdepth 1 -type f | sed -n "${IJ[1]}p")
		JWORD=$(( (IJ[2]-1)*144+(IJ[3]-1)*12+IJ[4] ))
		JDW=$(sed -n "$JWORD"p < "$JFILE")
		echo -n "$JDW "
	done
	echo
}

rundwd12
