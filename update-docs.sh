#!/bin/bash

projects=(\
  "node-api" \
  "web-sdk" \
  "next-sdk"
)

for project in ${projects[@]}; do
  svn export \
    --force \
    "https://github.com/unologin/$project.git/trunk/docs" \
    "$project"
done
