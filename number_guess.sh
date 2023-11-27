#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 ))
echo -e "\n Enter your username:"
read USERNAME
if [[ $(echo -n "$USERNAME" | wc -c) -le 22 ]]
then
  usr_check=$($PSQL "select * from users where name = '$USERNAME'")
  if [[ -z $usr_check ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    new_usr=$($PSQL "insert into users (name) values ('$USERNAME')")
  else
    u_id=$($PSQL " select user_id from users where name = '$USERNAME' ")
    games_played=$($PSQL " select count(*) from games where user_id = '$u_id'")
    best=$($PSQL " select number_guesses from games where user_id = '$u_id' order by number_guesses asc limit 1")
    echo -e "\nWelcome back, $USERNAME! You have played $games_played games, and your best game took $best guesses."
  fi
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS
  num_guess=1
  while [[ "$GUESS" -ne "$NUMBER" ]]
  do
    if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:\n"
    elif [[ "$GUESS" -lt "$NUMBER" ]]
    then
      echo -e "\nIt's higher than that, guess again:\n"
    elif [[ "$GUESS" -gt "$NUMBER" ]]
    then
      echo -e "\nIt's lower than that, guess again:\n"
    fi
    read GUESS
    num_guess=$((num_guess + 1))
  done
  echo -e "\nYou guessed it in $num_guess tries. The secret number was $NUMBER. Nice job!"
  usr_id=$($PSQL "select user_id from users where name = '$USERNAME'")
  insert_game=$($PSQL "insert into games(user_id, number_guesses) values ($usr_id, '$num_guess') ")
else
  echo "This username is too long."
fi
