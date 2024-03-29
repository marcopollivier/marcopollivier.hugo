#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Config Hugo

## Build the project.
hugo -t hugo-coder

##  Go To Public folder
cd public
cp ../docs/README.md .

# Config Git

## Checkout master on submodules
git checkout master

##  Add changes to git.
git add .

## Commit changes.
msg="Rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

## Push source and build repos.
git push origin master --force

## Config root Hugo project

# Come Back up to the Project Root
cd ..
git add .
git commit -m "$msg"
git push origin master
