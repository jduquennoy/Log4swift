#!/bin/bash


for folder in `find . -type d -depth 1`
do
  echo -n "Testing $folder ... "
  pushd "$folder" > /dev/null
  rm result.log result.err 2>/dev/null
  ./test.sh 1> result.log 2>result.err
  result=$?
  if [ $result -eq 0 ]; then
    echo "SUCCESSS"
  else
    echo "ERROR, code $result. Please check logs in folder $folder"
  fi
  popd > /dev/null
done