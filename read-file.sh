#!/usr/bin/env bash

input=$1

display=false

while read -r line
do
  if [ "$line" = "--- start ip addresses ---" ]; then
      display=true
  fi

  if $display; then
      if [ "$line" == "--- end ip addresses ---" ]; then
        :
      elif [ "$line" != "--- start ip addresses ---" ]; then
        echo $line
        whois "$line" | grep org-name
        echo ""
      fi
  fi

  if [ "$line" = "--- end ip addresses ---" ]; then
      display=false
  fi

done < $input
