#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

hugo -t hugo-coder

cd public

git add .
git commit -m "Rebuilding site `date`"
git push origin master

cd ..

git add .
git commit -m "$msg"
git push origin master
