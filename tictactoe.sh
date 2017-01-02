#! /bin/bash

#
# @author : SHASHANK DWIVEDI
# Program : TIC TAC TOE
#
# This tic tac toe implementation has 3 levels.
# Level 1: This level is for beginers and AI moves are almost random.
# Level 2 and 3: These levels perform depth searches upto depth 2/3 based on minimax algorithm.
# 
# This game was just created for learning bash scripting with some fun.
# Type ./tictactoe.sh --help
# Enjoy!
#

BASH_DIR="${PWD}/utils"
if [[ ! -d "$BASH_DIR" ]]; then BASH_DIR="$PWD"; fi
source $BASH_DIR/console_logger.sh;
source $BASH_DIR/bits_helper.sh;

RED='\033[0;31m';
BLUE='\033[0;34m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
NC='\033[0m';

vline="|";
hline="- - ";

WL=(111000000 000111000 000000111 100100100 010010010 001001001 100010001 001010100);
curr=("1" "2" "3" "4" "5" "6" "7" "8" "9");
X=000000000;
O=000000000;

depth=2;

function help {
	echo "This is tic tac toe game with 3 levels.";
	echo "At level 1 AI performs almost random moves if moves are not so obvious."
	echo "Level 2 plays at intermediate level and level 3 is NOT supposed to get defeated."
	echo "How to play: (mostly self explanatory.)"
	echo "Step 1: choose a level."
	echo "Select if you want to move first."
	echo "Choose 1-9 to fill x in desired location in your turn.";
	exit 0;
}

# $arg1 : text and $arg2 : color (default NC)
function color_print {
	if [[ -z $1 ]] ; then
		warn "Empty string provided to color print!";
		return;
	fi
	local color=$([ "$2" == "" ] && echo "${NC}" || echo "${2}");
	printf "${color}$1${NC}";
}

function draw_input {
	if [[ -z $1 ]] ; then
		error "NO input provided to draw.";
		return;
	fi;
	if [[ "$1" == "x" ]] ; then
		color_print "x" ${RED};
	elif [[ "$1" == "o" ]] ; then 
		color_print "o" ${BLUE};
	else
		color_print "$1";
	fi
}

function draw {
	printf "\n";
	draw_input " "; draw_input "${curr[0]}";
	color_print "${vline}" ${GREEN};
	draw_input "${curr[1]}";
	color_print "${vline}" ${GREEN};
	draw_input "${curr[2]}"; draw_input "\n";
	echo -e ${GREEN}${hline}${hline};
	draw_input " "; draw_input "${curr[3]}";
	color_print "${vline}" ${GREEN};
	draw_input "${curr[4]}";
	color_print "${vline}" ${GREEN};
	draw_input "${curr[5]}"; draw_input "\n";
	echo -e ${GREEN}${hline}${hline};
	draw_input " "; draw_input "${curr[6]}";
	color_print "${vline}" ${GREEN};
	draw_input "${curr[7]}";
	color_print "${vline}" ${GREEN};
	draw_input "${curr[8]}"; draw_input "\n";
	echo -e "${NC}";
	printf "\n";
}

function random {
	local r=$(( ( RANDOM % 9 )  + 1 ));
	echo $r;
}

function validate_input {
	if [[ -z  "$1" || $(( $1 < 1 || $1 > 9 )) == 1 || ${curr[$1-1]} =~ ["x","o"] ]] ; then
		error "Invalid input.Please try again.";
		process_user_turn;
	fi
}

function find_random_vacancy {
	if [[ $(( ${1} < 10 )) == 1 && ! ${curr[$1-1]} =~ ["x","o"] ]] ; then
		echo $1;
		return;
	fi
        if [[ "$1" == 10 ]] ; then
               find_random_vacancy 1;
        else
               find_random_vacancy $(($1 + 1));
        fi
 }

#
# Analyzes current board state and returns a score which indicates how favorable the move is for AI.
# The more posative the better is score in favour of AI.
#

function score_state {
	echo "score_state X: $(d2b9 ${X})" >> log.txt
	echo "score_state O: $(d2b9 ${O})" >> log.txt
	local score=0;
	for i in "${WL[@]}"
	do	
		# calculate score for O
		local nsetbits=$(count_set_bits $(( $(b2d ${i}) & ${O} )));
		if [[ ${nsetbits} == 3 ]] ; then
			score=$((score + 100));
		elif [[ ${nsetbits} == 2 ]] ; then
			score=$((score + 10));
		elif [[ ${nsetbits} == 1 ]] ; then
			score=$((score + 1));
		fi
		# calculate score for X
		nsetbits=$(count_set_bits $(( $(b2d ${i}) & ${X} )));
		if [[ ${nsetbits} == 3 ]] ; then
			score=$((score - 100));
		elif [[ ${nsetbits} == 2 ]] ; then
			score=$((score - 10));
		elif [[ ${nsetbits} == 1 ]] ; then
			score=$((score - 1));
		fi
	done
	echo ${score};
}

#
# This is mind of AI. It performs exhausted search for best possible moves based on depth. 
# $1=depth of analysis
# $2= 1/0, (where 1=Maximizing player i.e AI, 0=Minimizing Player i.e Human)
# 

#export loc=0;
function minmax {
	local max_score=$( [ "${2}" == "1" ] && echo -1000 || echo 1000 );
	local loc=0;
	local depth=${1};
	if [[ "$1" == "0" || $(is_game_over) == "true" ]]; then
		max_score=$(score_state);
	else
		for i in $(seq 1 9);
		do
		if [[ $(is_set $(( O | X )) $i) == "false" ]]; then
			if [[ ${2} == 1 ]]; then
				# analyze for O	
				O=$(set_bit ${O} ${i});	
				local scorea=($(minmax $(($depth - 1)) 0));
				local score=${scorea[0]};
				if [[ ${score} -gt ${max_score} ]]; then
					max_score=${score};
					loc=${i};
					echo "New Loc for O at depth $1 = $loc , mscore: $max_score" >> log.txt;
				fi
				#backtrack
				O=$(unset_bit ${O} ${i});
			else
				# analyze for X
				X=$(set_bit ${X} ${i});
				local scorea=($(minmax $(($depth - 1)) 1));
                                local score=${scorea[0]};
				if [[ ${score} -lt ${max_score} ]]; then
					echo "X: changing maxscore from $max_score -> $score" >> log.txt
					max_score=${score};
					loc=${i};
					echo "New Loc for X at depth $1: $loc, mscore: $max_score" >> log.txt
				fi
				#backtrack
				X=$(unset_bit ${X} ${i});
			fi
		fi

		done
	fi
	ret=($max_score $loc);
	echo "${ret[@]}";
}

# This function find obvious moves for AI for performance improvement
function check_obvious_move {
	local pos=0; #invalid position
        for i in "${WL[@]}"
        do
		 if [[ ( $(count_set_bits $(( ${O} & $(b2d ${i}) )) ) == 2 ) && ( $(count_set_bits $(( $(( ${X} | ${O} )) & $(b2d ${i}) )) ) != 3 ) ]] ; then
                        local xor=$(( ( $(b2d ${i}) & ${O}) ^ $(b2d ${i}) ));
                        pos=$(find_set_bit_loc $xor);
                        break;
                fi
	done
	if [[ $pos == 0 ]]; then	
		for i in "${WL[@]}"
        	do
                	if [[ ( $(count_set_bits $(( ${X} & $(b2d ${i}) )) ) == 2 ) && ( $(count_set_bits $(( $(( ${X} | ${O} )) & $(b2d ${i}) )) ) != 3 ) ]] ; then
                        	local xor=$(( ( $(b2d ${i}) & ${X}) ^ $(b2d ${i}) ));
                       	        pos=$(find_set_bit_loc $xor);
                        	break;
                	fi
        	done
	fi
	echo ${pos};	
}

function find_move {
	local move=$(check_obvious_move);
	if [[ $move == 0 ]]; then	
		if [[ ${1} == 1 || $((${X} | ${O} )) == 0 ]] ; then
			move=$(find_random_vacancy $(random));
		else
			local arr=($(minmax ${1} 1));
			move=${arr[1]}
		fi
	fi
        echo ${move};
}

function is_game_over {
	for i in "${WL[@]}" 
	do
		if [[ $(( ${X} & $(b2d ${i}) )) == $(b2d ${i}) ||  $(( ${O} & $(b2d ${i}) )) == $(b2d ${i}) || 	$(( ${X} | ${O} )) == $(b2d 111111111) ]] ; then
       			echo "true";
			return;
		fi
		
	done
	echo "false";
}

function process_ai_turn {
	color_print "My turn: Let me think ...\n" ${BLUE};
	local ip=$(find_move ${depth});
	#warn "Move found for AI: $ip"
	curr[$((ip-1))]="o";
	O=$(set_bit ${O} ${ip});
	warn "STATE O:  $(d2b9 ${O})";
	#draw;
	if [[ "$(is_game_over)" == "false" ]] ; then
		process_user_turn;
	elif [[ $(( ${X} | ${O} )) == $(b2d 111111111) ]] ; then
		draw;
		color_print "It's draw!\n" ${GREEN};
	else
		draw;
		color_print "Yeey I Won!\n" ${GREEN};
		return;
	fi
}

function process_user_turn {
	color_print "Your turn: \n" ${RED};
	draw;
	read input;
	validate_input ${input};
	curr[${input}-1]="x";
	X=$(set_bit ${X} ${input});
	warn "STATE X: $(d2b9 ${X})";
	draw;
	if [[ "$(is_game_over)" == "false" ]] ; then
		process_ai_turn;
	elif [[	$(( ${X} | ${O} )) == $(b2d 111111111) ]] ; then
		color_print "It's draw!\n" ${GREEN};
	else
		color_print "Congratulations!, You Won!\n" ${GREEN};
		return;
	fi
}



if [[ "$1" == "--help" ]] ; then
	help;
fi;

echo "Pick level. 1 for beginner, 2 for intermediate 3 for expert: ";
read level;

case "$level" in
	1) depth=1;
	   ;;
	2) depth=2;
	   ;;
	3) depth=3
	   ;;
	*)
	   warn "You selected wrong choice.We will start in beginner's mode."
	   depth=1;
	   ;;
esac

echo "Do you want to go first? y/n: ";
read is_user_first;
if [[ ${is_user_first} =~ ["y","Y"] ]] ; then
	process_user_turn;
else
	process_ai_turn;
fi

