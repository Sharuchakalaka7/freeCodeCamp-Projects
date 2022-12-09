#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.




function fetch_team_id() {
	ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
	if [[ -z "$ID" ]]
	then
		MESSAGE="$($PSQL "INSERT INTO teams(name) VALUES ('$1')")"
		ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
	fi
	echo $ID
}




echo "$($PSQL "TRUNCATE TABLE games, teams")" > /dev/null
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")" > /dev/null
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")" > /dev/null

FILE="games.csv"
I=1

cat "$FILE" | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != "year" ]]
	then
		WINNER_ID=$(fetch_team_id "$WINNER")
		OPPONENT_ID=$(fetch_team_id "$OPPONENT")
		MESSAGE="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
	fi
done
