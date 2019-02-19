#!/bin/bash

# <bitbar.title>CP Board BitBar Plugin</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Sven Balnojan</bitbar.author>
# <bitbar.author.github>sbalnojan</bitbar.author.github>
# <bitbar.desc>Displays CodePipeline states</bitbar.desc>
# <bitbar.dependencies>bash,jq</bitbar.dependencies>

PATH=/usr/local/bin:$PATH

if [ -z "$1" ]
  then
    . ~/.cp_board_config.cfg
else
    . .cp_board_config.cfg
fi


check_status() {
  #read arg
  AH=false
  PIPE_STATE="Succeeded"
  while read -r line; do
    #echo "$line has state "
    STATE="$( echo $1 | jq -r ".[\"$line\"]" )"
    #echo $STATE
    if [ "$STATE" = "Failed" ]; then
      FAIL=true
    fi
    if [ "$STATE" = "Running" ]; then
      RUN=true
    fi
  done< <(echo "$1" | jq keys | jq -r ".[]" )

  if [[ $FAIL && ! $RUN ]]; then
    echo "Failed"
  elif [[ $RUN ]]; then
    echo "Running"
  else
    echo "Succeeded"
  fi
}

#response=$(curl $CPB_ENDPOINT)
response='{"pipe1":{"stage1":"Failed","stage2":"Succeeded","source":"Succeeded"},"pipe2":{"stagea":"Running","source":"Failed"},"pipe3":{"stage1":"Succeeded","source":"Succeeded"},"pipe4":{"stagez":"Succeeded","dource":"Succeeded"},"pipe5":{"dummystage":"Succeeded","source":"Succeeded"}}'

FAIL_COUNT=0
RUNNING_COUNT=0
TOTAL_COUNT=0

RESULT=()
while read -r line; do
   resp=$( echo $response | jq -r ".[\"$line\"]" )
   #echo $resp
   state=$( check_status "$resp" )
   new_res="$line-$state"
   TOTAL_COUNT=$((TOTAL_COUNT+1))

   if [ "$state" == "Failed" ]; then
     FAIL_COUNT=$((FAIL_COUNT+1))
     RESULT+=("$new_res | color=red")
   elif [ "$state" == "Running" ]; then
     RUNNING_COUNT=$((RUNNING_COUNT+1))
     RESULT+=("$new_res | color=blue")
   else
     RESULT+=("$new_res | color=green")
   fi
done< <(echo $response | jq -r keys | jq -r '.[]')
echo "$TOTAL_COUNT pipes = $((TOTAL_COUNT - RUNNING_COUNT - FAIL_COUNT )) (d) // $RUNNING_COUNT (r) // $FAIL_COUNT  (f)"
echo "---"

for ((i = 0; i < ${#RESULT[@]}; i++))
do
    echo "${RESULT[$i]}"
done

#echo $response | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"
