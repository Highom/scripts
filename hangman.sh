#!/bin/bash 

###################################################################
#Script Name	: Hangman
#Description	: Game where you try to find out the word.
#Args           : NONE
#Author       	: Yannick Ruck                                                
#Email         	: yannickruck@gmail.com                                           
###################################################################

readarray words < hangman.dat
declare word;
alphabet=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z")

function getRandomWord {
    i=$(( $RANDOM % ${#words[@]} + 1 ))
    word=${words[i]} 
}

#Main
    getRandomWord;
    echo "Length of Word: "$((${#word}-1))
    try=5
    while true; do
        read -p $'\e[1mPlayer:\e[0m ' Playerinput
        if [[ ${#Playerinput} -ne 1 ]] || ! [[ "${alphabet[*]}" =~ $Playerinput ]]; then
		    echo  -e "\e[31mFehlerhafte Eingabe\e[0m"
		    continue
        else
            wrong=true
            for (( i=0; i<${#word}; i++ )); do
                char=${word:$i:1}
                if [[ $char == $Playerinput ]]; then
                    echo $char at $(( i + 1 ));
                    #TODO: remove char from alphabet
                    wrong=false
                fi
            done
            if $wrong; then
                try=$((try-1))
                if [[ $try -ne 0 ]]; then
                    echo "Wrong! $try tries left"
                fi
            fi
        fi
        if [[ $try -eq 0 ]]; then
            echo "GAME OVER"
            echo "Word was $word"
            break;
        fi
        # echo ${alphabet[*]}
    done
