#!/bin/bash

cd src/step4
touch err.txt
if [ -f "helloworld" ]; then
    rm helloworld 2>&1 >/dev/null
fi
make helloworld > err.txt
# 2>&1 >/dev/null
if [ $? == 0 ]; then
  if [ ! -f "helloworld" ]; then	         
    echo "The executable 'helloworld' is not found. Please make sure that you have written Makefile as required!"
  else
    if diff <(./helloworld) <(printf '%s\n' "Hello world!"); then
      echo "passed!"
    else
      echo "The executable generated is not as expected."
    fi
  fi
else 
  echo "An error occurred during the building process."
fi