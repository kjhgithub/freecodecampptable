#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

GET_DATA() {
  DATA=$($PSQL "SELECT * FROM (SELECT * FROM elements FULL JOIN properties Using(atomic_number) INNER JOIN types USING(type_id)) AS t1 WHERE t1.atomic_number = $1 ")

  echo "$DATA" | while read TYID BAR AN BAR SYM BAR NAM BAR MASS BAR MELP BAR MELB BAR TYPEE
  do
    echo "The element with atomic number $AN is $NAM ($SYM). It's a $TYPEE, with a mass of $MASS amu. $NAM has a melting point of $MELP celsius and a boiling point of $MELB celsius."
  done
}

NOT_FOUND() {
  echo -e "I could not find that element in the database."
}

if [[ -z $@ ]]
then
  echo -e "Please provide an element as an argument."
elif [[ $1 =~ ^[0-9]+$ ]] && [[  $# = 1 ]]
then
  CHECK_NUMBERS=$($PSQL "SELECT atomic_number FROM properties WHERE atomic_number = $1") 
  if [[ -z $CHECK_NUMBERS ]]
  then
    NOT_FOUND
  else
    GET_DATA $1
  fi
elif [[ $1 =~ ^[a-zA-Z]+$ ]] && [[  $# = 1 ]]
then
  LOWERTEXT=$(echo "$1" | sed -e 's/.*/\L&/g')
  CAPITALIZER=$(echo "$LOWERTEXT" | sed -e 's/\b\(.\)/\u\1/g')
  if [[ ${#CAPITALIZER} -gt 2 ]]
  then
    GET_ATNUM_LONG=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$CAPITALIZER'")
    if [[ -z $GET_ATNUM_LONG ]]
    then
      NOT_FOUND
    else
      GET_DATA $GET_ATNUM_LONG
    fi
  else
    GET_ATNUM_SHORT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$CAPITALIZER'")
    if [[ -z $GET_ATNUM_SHORT ]]
    then
      NOT_FOUND
    else
      GET_DATA $GET_ATNUM_SHORT
    fi
  fi
else
  NOT_FOUND
fi


# The element with atomic number $P_ATOMIC_NUMBER is $E_NAME ($E_SYMBOL). It's a $P_TYPE_ID, with a mass of P_ATOMIC_MASS amu. $P_NAME has a $melting point of $P_MELTING_POINT celsius and a boiling point of $P_BOILING_POINT celsius.

# echo "$DOSTUFF" | while read TYPE
# do
#  DOSTUFF2=$($PSQL "INSERT INTO types(type) VALUES('$TYPE')")
#  echo "INSERTED!"
# done
