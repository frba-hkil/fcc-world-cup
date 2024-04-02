#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS #for each line
do
  if [[ $YEAR != "year" ]] #if line is not first line
    then #insert teams
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $WINNER_TEAM_ID && -z $OPPONENT_TEAM_ID ]] #if both teams don't exist in db yet
    then #then should insert both teams into db
      INSERT_BOTH_TEAMS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER'), ('$OPPONENT')")
      if [[ $INSERT_BOTH_TEAMS_RESULT == "INSERT 0 2" ]]
      then
        echo inserted into teams, $WINNER
        echo -e "\ninserted into teams, $OPPONENT"
      fi
    elif [[ -z $WINNER_TEAM_ID ]] #if only winner team is not in db yet
    then #then should insert only winner team in db
      INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo inserted into teams, $WINNER
      fi
    elif [[ -z $OPPONENT_TEAM_ID ]] #if only opponent team is not in db yet
    then
      INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo inserted into teams, $OPPONENT
      fi
    else #both teams exist already in db
      echo team $WINNER and $OPPONENT already exist in db. skipping
    fi
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
