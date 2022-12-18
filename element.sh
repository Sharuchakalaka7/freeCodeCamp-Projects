#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

MAIN() {
	if [[ $1 ]]; then

		# Atomic number arg case
		if [[ $1 =~ ^[0-9]+$ ]]; then
			CONDITION="atomic_number=$1"

		# Symbol arg case
		elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
			CONDITION="symbol='$1'"

		# Name arg case
		elif [[ $1 =~ ^[A-Z][A-Za-z]*$ ]]; then
			CONDITION="name='$1'"

		# Default case
		else
			echo "I could not find that element in the database."
			return
		fi

		# Perform query
		QUERY_RESULTS=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE $CONDITION")

		# Message depending on query success
		if [[ -n $QUERY_RESULTS ]]; then
			echo $QUERY_RESULTS | while IFS=" | " read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT; do
				echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
			done

		# Default case (again)
		else
			echo "I could not find that element in the database."
		fi

	# No args case
	else
		echo "Please provide an element as an argument."
	fi

}

MAIN $@
