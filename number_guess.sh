#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET=$(( $RANDOM % 1000 + 1 ))

MAIN_MENU() {
	# echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

	# Prompt for username
	echo "Enter your username:"
	read USERNAME

	# Load user's data by username
	LOAD_DATA
	if [[ USER_ID -gt 0 ]]; then
		echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
	else
		echo "Welcome, $USERNAME! It looks like this is your first time here."
	fi

	# Set counter and play game
		# echo "SECRET: $SECRET"
	GUESS_COUNT=0
	PLAY_GAME
	echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job!"

	# Save new game data, and possibly user data
	SAVE_DATA
}

LOAD_DATA() {
	FIND_USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

	# No username found
	if [[ -z $FIND_USERNAME_RESULT ]]; then
		USER_ID=0
	
	# Otherwise (username found)
	else
		USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
		GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
		BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
	fi
}

PLAY_GAME() {
	# Prompt for a guess
	if [[ $1 ]]
	then
		echo "$1"
	else
		echo "Guess the secret number between 1 and 1000:"
	fi
	read GUESS

	# Increment counter
	(( ++GUESS_COUNT ))

	# If not integer - recurse
	if [[ ! $GUESS =~ ^[0-9]+$ ]]
	then
		PLAY_GAME "That is not an integer, guess again:"
	# If lower - recurse
	elif [[ $GUESS -lt $SECRET ]]
	then
		PLAY_GAME "It's higher than that, guess again:"
	# If higher - recurse
	elif [[ $GUESS -gt $SECRET ]]
	then
		PLAY_GAME "It's lower than that, guess again:"
	fi

	# Otherwise (when exact match), stop recursion
}

SAVE_DATA() {
	if [[ USER_ID -le 0 ]]
	then
		INSERT_UER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
		USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
	fi
	INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses, secret_number) VALUES ($USER_ID, $GUESS_COUNT, $SECRET)")
}

MAIN_MENU
