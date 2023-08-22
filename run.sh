#! /bin/bash

GH_USERNAME=""
YN_OPTIONS=("yes" "no")

function select_option {

  # little helpers for terminal print control and key input
  ESC=$(printf "\033")
  cursor_blink_on() { printf "$ESC[?25h"; }
  cursor_blink_off() { printf "$ESC[?25l"; }
  cursor_to() { printf "$ESC[$1;${2:-1}H"; }
  print_option() { printf "   $1 "; }
  print_selected() { printf "  $ESC[7m $1 $ESC[27m"; }
  get_cursor_row() {
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo ${ROW#*[}
  }
  key_input() {
    read -s -n3 key 2>/dev/null >&2
    if [[ $key = $ESC[A ]]; then echo up; fi
    if [[ $key = $ESC[B ]]; then echo down; fi
    if [[ $key = "" ]]; then echo enter; fi
  }

  # initially print empty new lines (scroll down if at bottom of screen)
  for opt; do printf "\n"; done

  # determine current screen position for overwriting the options
  local lastrow=$(get_cursor_row)
  local startrow=$(($lastrow - $#))

  # ensure cursor and input echoing back on upon a ctrl+c during read -s
  trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
  cursor_blink_off

  local selected=0
  while true; do
    # print options by overwriting the last lines
    local idx=0
    for opt; do
      cursor_to $(($startrow + $idx))
      if [ $idx -eq $selected ]; then
        print_selected "$opt"
      else
        print_option "$opt"
      fi
      ((idx++))
    done

    # user key control
    case $(key_input) in
    enter) break ;;
    up)
      ((selected--))
      if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi
      ;;
    down)
      ((selected++))
      if [ $selected -ge $# ]; then selected=0; fi
      ;;
    esac
  done

  # cursor position back to normal
  cursor_to $lastrow
  printf "\n"
  cursor_blink_on

  return $selected
}

function prompt {
  echo "Select one option using up/down keys and enter to confirm:"
}

function create_project {
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

  echo "Choose project type"
  prompt

  PROJECT_OPTIONS=("Empty JS Project" "Vite" "Next.js" "Create React App")

  select_option "${PROJECT_OPTIONS[@]}"
  PROJECT_TYPE_INDEX=$?
  PROJECT_TYPE="${PROJECT_OPTIONS[$PROJECT_TYPE_INDEX]}"
  echo $PROJECT_TYPE

  #create GH repo

  gh --version
  if [ $? -eq "0" ]; then
    echo "Create GitHub repository?"
    prompt

    select_option "${YN_OPTIONS[@]}"
    REPO_INDEX=$?
    REPO="${YN_OPTIONS[$REPO_INDEX]}"
    echo $REPO

    if [ "$REPO" = "yes" ]; then

      if [ -z "$GH_USERNAME" ]; then
        read -p "GitHub user name(cannot be empty!): " GH_USERNAME
        echo "GH_USERNAME: ${GH_USERNAME}"
      fi
      REPO_PRIVACY=("private" "public")

      echo "Public or private?"
      prompt

      select_option "${REPO_PRIVACY[@]}"
      PRIVACY_CHOICE_INDEX=$?
      PRIVACY_CHOICE="--${REPO_PRIVACY[$PRIVACY_CHOICE_INDEX]}"
      echo PRIVACY_CHOICE
    fi

  fi

  #choose development branch

  echo "Select development branch name"
  prompt

  DEV_BRANCHES=("develop" "development" "devel" "dev" "no development branch")

  select_option "${DEV_BRANCHES[@]}"
  DEV_BRANCH_INDEX=$?
  DEV_BRANCH="${DEV_BRANCHES[$DEV_BRANCH_INDEX]}"
  echo $DEV_BRANCH

  function create_devbranch {
    if [ "$DEV_BRANCH" != "no development branch" ]; then
      git checkout -b "$DEV_BRANCH"
    fi
  }

  function devbranch {
    cd "$PROJECT_NAME_KEBABCASE"
    create_devbranch
  }

  function create_gh_repo {
    cd "$PROJECT_NAME_KEBABCASE"
    if [ "$REPO" == "yes" ] && [ -n "$GH_USERNAME" ]; then
      GITHUB_PATH="git@github.com:${GH_USERNAME}/${PROJECT_NAME_KEBABCASE}.git"
      gh repo create "$PROJECT_NAME_KEBABCASE" "$PRIVACY_CHOICE"
      git remote add origin "$GITHUB_PATH"
      git branch -M main
    fi
    git add .
    git commit -m "Initial commit"
    if [ "$REPO" == "yes" ] && [ -n "$GH_USERNAME" ]; then
      git push -u origin main
    fi
    cd ..

  }

  function create_git_repo {
    cd "$PROJECT_NAME_KEBABCASE"
    git init -b main
    cd ..
  }

  function create_readme {
    cd "$PROJECT_NAME_KEBABCASE"
    echo "# $PROJECT_NAME" >./README.md
    cd ..
  }

  #create folder structure

  mkdir "$PROJECT_NAME_UPPER"
  cd "$PROJECT_NAME_UPPER"
  mkdir project-assets
  case $PROJECT_TYPE in

  "Empty JS Project")
    mkdir "$PROJECT_NAME_KEBABCASE"
    cd "$PROJECT_NAME_KEBABCASE"
    npm init -y
    cd ..
    create_git_repo
    create_readme
    create_gh_repo
    devbranch
    ;;

  "Vite")
    npm create vite@latest "$PROJECT_NAME_KEBABCASE"
    create_git_repo
    create_gh_repo
    devbranch
    ;;

  "Next.js")
    npx create-next-app@latest "$PROJECT_NAME_KEBABCASE"
    create_gh_repo
    devbranch
    ;;

  "Create React App")
    npx create-react-app "$PROJECT_NAME_KEBABCASE"
    cd "$PROJECT_NAME_KEBABCASE"
    git branch -m master main
    cd ..
    create_gh_repo
    devbranch
    ;;
  esac
}
function welcome_prompt {
  read -p "Project name (cannot be empty!): " PROJECT_NAME
}

welcome_prompt
if [ -n "$PROJECT_NAME" ]; then
  create_project
else
  echo "Project name is empty...please try again"
  welcome_prompt
  if [ -n "$PROJECT_NAME" ]; then
    create_project
  else
    echo "Are you moron or something? Set the damn project name!"
    welcome_prompt
    if [ -n "$PROJECT_NAME" ]; then
      create_project
    else
      echo "I'm done with you...bye!"
    fi
  fi
fi
