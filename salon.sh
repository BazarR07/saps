#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read  SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [ $SERVICE_ID_SELECTED -le 3 ]; then
      echo "You selected service $SERVICE_ID_SELECTED"
      echo "Enter your phone number"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "You are not registered, enter your Name:\n"
        read CUSTOMER_NAME
        INSERT_DATA=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo -e "When do you want your appointment, $CUSTOMER_NAME?"
      read SERVICE_TIME
      if [[ $SERVICE_TIME ]]
      then
        INSERT_APPOINT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        if [[ $INSERT_APPOINT_RESULTS == "INSERT 0 1" ]]
          then
          GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
          SERVICE_NAME=$(echo $GET_SERVICE_NAME| sed 's/ //g')
            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
      fi

    else
      MAIN_MENU "This service doesnt exist, pick another: "
    fi
}

MAIN_MENU