#! /bin/bash

read -p "Project name (cannot be empty!): " PROJECT_NAME

# project name convertion

if [ -n "$PROJECT_NAME" ]; then

  PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
  PROJECT_NAME_UPPER=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]')

  PROJECT_NAME_KEBABCASE=""
  PREFIX=""

  for ITEM in $PROJECT_NAME_LOWER; do
    if [ -n "$PROJECT_NAME_KEBABCASE" ]; then
      PREFIX="$PROJECT_NAME_KEBABCASE"
      PROJECT_NAME_KEBABCASE="${PREFIX}-${ITEM}"
      PREFIX="$PROJECT_NAME_KEBABCASE"
    else
      PROJECT_NAME_KEBABCASE="${ITEM}"
      PREFIX="$PROJECT_NAME_KEBABCASE"
    fi

  done

  #create folder structure

  mkdir "$PROJECT_NAME_UPPER"
  cd "$PROJECT_NAME_UPPER"
  mkdir project-assets
  mkdir "$PROJECT_NAME_KEBABCASE"

else
  echo "project name is empty you dumb piece of shit!!!"
fi

#1. Create folder structure:
# -project name
#   |-project-assets
#   |-$project-name (here lies git repository)

#2. Initialize git repository:
#   - initialize locally with propper branch:
#       - create repository with main or master (user deccision on branch name)
#         - if master than will be additional steps in remote
#         - if main than will be additional steps in local repo
#       - create ask user if development branch is needed
#       - create development branch (dev/devel/develop/development) from main/master
#   - ask if github repo is needed
#       - if yes:
#       - ask if private or public (default private)
#       - initialize remote with main branch (master or main) ?how to do that?
#   - pull from remote
