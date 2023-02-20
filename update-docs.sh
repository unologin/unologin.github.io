#!/bin/bash

projects=(\
  "node-api" \
  "web-sdk" \
)

for project in ${projects[@]}; do
  svn export \
    --force \
    "https://github.com/unologin/$project.git/trunk/docs" \
    "docs/$project"
done
