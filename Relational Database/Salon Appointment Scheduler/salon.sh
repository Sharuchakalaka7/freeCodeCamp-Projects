#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Store ~~~~~\n"

MAIN_MENU() {
	# Initial Message
	echo -en "\n$([[ $1 ]] && echo $1 || echo "Welcome to our Salon!")"

	# List services
	echo " Here are our services:"
	LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")
	echo "$LIST_OF_SERVICES" | while IFS=" | " read SERVICE_ID NAME
	do
		echo "$SERVICE_ID) $NAME"
	done

	# Prompt and read SERVICE_ID_SELECTED
	echo -e "\nWhat service would you like?"
	read SERVICE_ID_SELECTED

	# If not number, repeat
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then
		MAIN_MENU "Not a number. Please try again with an appropriate service number."
		return
	fi

	# If no such service_id, repeat
	SERVICES_FOUND=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	if [[ -z $SERVICES_FOUND ]]
	then
		MAIN_MENU "No services with this ID. Please try again."
		return
	fi

	# Process the remainder of the service booking
	PROCESS_BOOKING
}

PROCESS_BOOKING() {
	# Prompt and read CUSTOMER_PHONE
	echo -e "\nNext, please enter your phone number:"
	read CUSTOMER_PHONE

	# Find CUSTOMER_NAME by CUSTOMER_PHONE
	CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

	# If non existent name
	if [[ -z $CUSTOMER_NAME ]]
	then
		# Prompt and read CUSTOMER_NAME
		echo -e "\nYou must be our new customer. What is your name?"
		read CUSTOMER_NAME

		# Insert row into database
		CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
	fi

	# Prompt and read SERVICE_TIME
	echo -e "\nLastly, what time would you like to book your appointment (24hr time)?"
	read SERVICE_TIME
	
	# Find service name and customer id
	SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

	# Insert row into database
	APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

	# Exit message
	echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

if [[ $1 == "--reset" ]]
then
	TRUNCATE_RESULT=$($PSQL "TRUNCATE TABLE appointments, customers")
	APPOINTMENT_SEQ_RESTART_RESULT=$($PSQL "ALTER SEQUENCE appointments_appointment_id_seq RESTART WITH 1")
	CUSTOMER_SEQ_RESTART_RESULT=$($PSQL "ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1")
else
	MAIN_MENU
fi
