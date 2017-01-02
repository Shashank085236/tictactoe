#! /bin/bash

#
#Brace expansion in form {x..y} give you all possible characters from range x to y. 
#In this case, {0..1} give you 0 and 1. Combine two pieces give you 2^2 four possible values:
#$ printf %s\\n {0..1}{0..1}
#00
#01
#10
#11
# Combine 4 pieces give you 2^4 sixteen possible values from 0 to 15 in binary form.
#

D2B=({0..1}{0..1}{0..1}{0..1});
D2B9=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1});

function d2b {
	echo ${D2B[$1]};
}

function d2b9 {
	echo ${D2B9[$1]};
}

function b2d {
	if [[ -z "$1" ]] ; then
		"Invalid input.Cannot convert from binary to decimal.";
	fi
	dec1=$(echo "ibase=2;$1"|bc)
    	echo ${dec1};
}

# $1=number in decimal and $2 position to set the bit
function set_bit {
	local shift=$(( 1<<($2-1) ));
	echo $(( $1 | shift ));
}

# $1= number in decimal and $2 position to unset the bit
function unset_bit {
	local shift=$(( 1 << ($2-1) ));
	echo $(( $1 & ~shift ));
}

# $1=number in decimal and $2 bit location to be tested
function is_set {
	local shift=$(( 1 << ($2-1) ));
	if [[ $(( $1 & shift )) == ${shift} ]]; then
		echo "true";
	else
		echo "false";
	fi
}


#
# count number of bits set using Kernighan's Algorithm
#  Algorithm : Subtraction of 1 from a number toggles all the bits (from right to left) till the rightmost set bit(including the righmost set bit). 
#	     So if we subtract a number by 1 and do bitwise & with itself (n & (n-1)), we unset the righmost set bit. 
#	     If we do n & (n-1) in a loop and count the no of times loop executes we get the set bit count.
#	     Beauty of the this solution is number of times it loops is equal to the number of set bits in a given integer.
#  Complexity : O(logn)
#

function count_set_bits {
	local n=$1;
	local count=0;
	while [ "$n" != "0" ]; do
		n=$(( n & (n-1) ));
		count=$(( count+1 ));
	done
	echo ${count};
}

# find first set bit location
# $1: number in decimal
function find_set_bit_loc {
	local loc=1;
	for i in $(seq 1 9);
	do
		if [[ $(is_set $1 $loc) == "true" ]]; then 
			echo $loc;
			return;
		else 
			loc=$((loc + 1));
		fi
	done
	echo ${loc};
}

####################################  TESTING #############################################


a=0000101100;
n=$(find_set_bit_loc $(b2d $a));
echo ${n};
