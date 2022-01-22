#!/bin/bash

# You need to run git-clone repo_name to clone new git in your second account
PROJECT_REPO=$1
FOLDER=$2
REPLACED_DOMAIN=${PROJECT_REPO/.com/.me}

if [[ -z $PROJECT_REPO ]]
then
  echo "Usage: git-clone {project-repo}"
  exit 1
fi

if [[ -z $FOLDER ]]
then
   git clone $REPLACED_DOMAIN

   IFS='/'
   read -a RPARR <<<"$PROJECT_REPO"

   IFS='.'
   read -a PROJECT <<<"${RPARR[1]}"
   cd ${PROJECT[0]}

else

   git clone $REPLACED_DOMAIN $FOLDER
   cd $FOLDER
fi

echo "Update git user information..."

git config user.name "Hoang Kiem"
git config user.email kiemhd@outlook.com

echo "done!"