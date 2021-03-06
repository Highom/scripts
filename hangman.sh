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
declare endText;
declare underscores;
declare -A rightArray
declare -A wrongArray

function getRandomWord {
    i=$(( $RANDOM % ${#words[@]} + 1 ))
    #dunno where the trailing white space comes from so i just remove it here
    word=${words[i]%?}
}

function won {
    clear
    echo -e "\e[1;32mYou won!\e[0m"
    echo -e "Word was \e[36m$word\e[0m"
    endText="You won! Try again? [y/n]: "
}

function lost {
    clear
    echo -e "\e[1;31mGAME OVER\e[0m"
    echo -e "Word was \e[36m$word\e[0m"
    endText="You lost! Try again? [y/n]: "
}

function renderGameView {
    clear
    if [[ $try -ne 1 ]]; then
        echo -e "\e[35m$try\e[0m tries left!"
    else
        echo -e "\e[1;31mLast try!\e[0m"
    fi
    if [[ ${wrongArray[*]} != "" ]]; then
        echo -e "\e[1;31mWrongly guessed:\e[0m ${wrongArray[*]}"
    fi
    underscores=""
    for (( i=0; i<${#word}; i++ )); do
        char=${word:$i:1}
        if [[ ${rightArray["$char"]} ]]; then
            underscores+=" \e[1;36m$char\e[0m"
        else
            underscores+=" \e[1m-\e[0m"
        fi
    done
    echo -e "$underscores"
}

function wait {
    sleep 0.4;
}

#remove cursor
tput civis

#Main Loop
while true; do
    try=5
    right=0
    clear
    getRandomWord;
    #Game Loop
    while true; do
        renderGameView;
        read -p $'\e[1mPlayer:\e[0m ' Playerinput
        if [[ $Playerinput == $word ]]; then
            won;
            break;
        fi
        if [[ ${#Playerinput} -ne 1 ]] || ! [[ $Playerinput =~ [a-z] ]]; then
            echo  -e "\e[31mWrong Input\e[0m"
            wait;
            continue
        elif [[ ${rightArray["$Playerinput"]} ]] || [[ ${wrongArray["$Playerinput"]} ]] ; then
            echo  -e "\e[31mCharacter already guessed\e[0m"   
            wait;
            continue
        else
            wrong=true
            for (( i=0; i<${#word}; i++ )); do
                char=${word:$i:1}
                if [[ $char == $Playerinput ]]; then
                    rightArray["$char"]=$char
                    right=$((right+1))
                    wrong=false
                fi
            done
            if $wrong; then
                try=$((try-1))
                wrongArray["$Playerinput"]=$Playerinput
                if [[ $try -ne 0 ]]; then
                    echo -e "\e[31mWrong! $try tries left\e[0m"
                    wait;
                fi
            fi
        fi
        if [[ $try -eq 0 ]]; then
            lost;
            break;
        fi
        if [[ $right -eq  $((${#word})) ]]; then
            won;
            break
        fi
    done
    while true; do
        read -p "$endText" yn
        case $yn in
            [Yy]* ) break; break;;
            [Nn]* )clear; tput cnorm; exit;;
            * ) echo -e "\e[31mPlease answer yes or no.\e[0m";
        esac
    done
    #reset right and wrong Array for next Game
    rightArray=()
    wrongArray=()
done
