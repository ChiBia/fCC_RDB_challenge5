#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate a random number between 1 and 1000
SECRETN=$((1 + RANDOM % 1000))
# echo $SECRETN

echo "Enter your username:"
read USERNA

# checks if username exists
USERNA_ENTER=$($PSQL "select distinct(username) from games where username='$USERNA' ;")

# if username does not exist welcomes new user 
if [[ -z $USERNA_ENTER ]]
then 
  echo "Welcome, $USERNA! It looks like this is your first time here."
else
# if username exists checks history and welcomes with statistics
  N_PLAYED=$($PSQL "select count(username) from games where username='$USERNA' ;")
  BEST_GAME=$($PSQL "select min(number_guesses) from games where username='$USERNA' ;")
  echo "Welcome back, $USERNA! You have played $N_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUM

# creates counter for n guesses and checks with secret number
I=1
until [[ $GUESSED_NUM = $SECRETN ]]
do
  if [[ ! $GUESSED_NUM =~ ^[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
    read GUESSED_NUM
  elif [[ $GUESSED_NUM < $SECRETN ]]
  then 
    echo "It's higher than that, guess again:"
    read GUESSED_NUM
  elif [[ $GUESSED_NUM > $SECRETN ]]
  then 
    echo "It's lower than that, guess again:"
    read GUESSED_NUM
  fi
(( I++ ))
done

# creates a record
WRITE_TO_DB=$($PSQL "insert into games(username, number_guesses) values('$USERNA', '$I');")

# cheers and exit
echo "You guessed it in $I tries. The secret number was $SECRETN. Nice job!"
