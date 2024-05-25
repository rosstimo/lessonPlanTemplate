#!/bin/sh

# This script uses my existing LaTeX template to start a new LaTeX project.
# if any steps fail exit with exit code

# variables here
TEMPLATE_REPO_URL='https://github.com/rosstimo/lessonPlanTemplate.git'
REPO_NAME=""
REMOTE_URL=""
CURRENT_BRANCH=""
PROJECT_NAME=""
PROJECT_PATH=""
REPO_ROOT=""




# function to Check it the current directory is a git repository if it is store the repo name, remote url, and current branch Name
# run git remote get-url origin to determine if the current directory is a git repository

isGitRepo() {
  # Check if the directory two levels above the current directory is a git repository
  # cd ../..
  # if git remote get-url origin returns URL then the current directory is a git repository
  if REMOTE_URL=$(git remote get-url origin); then
    # get the repo name from the remote url
    REPO_NAME=$(basename $REMOTE_URL .git)
    # get the current branch name
    CURRENT_BRANCH=$(git branch --show-current)
    # get the root directory of the repository
    REPO_ROOT=$(git rev-parse --show-toplevel)

  else
    # if git remote get-url origin fails then the current directory is not a git repository
    echo "Current directory is not a git repository"
    exit 1
  fi

  # echo repo name, branch and remote url on seperate lines human readable
  echo "Repo Name: $REPO_NAME"
  echo "Remote URL: $REMOTE_URL"
  echo "Current Branch: $CURRENT_BRANCH"

}

newProject() {
  # Create a new directory for the project with the provided name. If the directory already exists or there is an error, exit the script with an error message.
  mkdir "$REPO_NAME" || { echo "Error: Failed to create directory '$REPO_NAME'."; exit 1; }
  # Change into the new directory. Exit if Error
  cd "$REPO_NAME" || { echo "Error: Failed to change into directory '$REPO_NAME'."; exit 1; }
  # Initialize the new directory as a Git repository. Exit if Error
  git init
  initiateTemplateSubmodule
  git add .
  git commit -m "Initial commit"
  git branch -M main
    # Print a success message with the project name. and provide instructions to set the origin remote and push the initial commit.
  echo "Success! Created '$PROJECT_NAME' from template."
  echo "To complete setup, run the following commands:"
  echo "cd $PROJECT_NAME"
  echo "git remote add origin <remote-repository-url>"
  echo "git push -u origin main"
  echo "enjoy!"

}

initiateTemplateSubmodule() {
  isGitRepo
  # Add the template repository as a Git submodule within the project repository.
  git submodule add $TEMPLATE_REPO_URL .template
  git submodule update --init --recursive
  # link common files and ignore to avoid rogue copies
  echo "#### Ignore LaTeX template files ####" >> $REPO_ROOT/.gitignore
  echo ".template" >> $REPO_ROOT/.gitignore
  ln -s .template/common common
  echo "common" >> $REPO_ROOT/.gitignore
  ln -s .template/scripts/useTemplate.sh useTemplate.sh
  echo "useTemplate.sh" >> $REPO_ROOT/.gitignore
  ln -s .template/scripts/texcompile.sh texcompile.sh
  echo "texcompile.sh" >> $REPO_ROOT/.gitignore
  cp -rnv .template/images images 
}

existingProject() {
  # if path is not provided then use the current directory
  # if the current directory is a git repository then initiateTemplateSubmodule
  # if the current directory is not a git repository then exit with message
  # if path provided is a directory cd into it and check if it is a git repository.
  # if it is a git repository then initiateTemplateSubmodule
  # if it is not a git repository then exit with message
  if [ -z "$1" ]; then
    PROJECT_PATH=$(pwd)
    # isGitRepo
    initiateTemplateSubmodule
  else
    if [ -d "$1" ]; then
      cd $1
      # isGitRepo
      initiateTemplateSubmodule
    else
      echo "Error: Failed to change into directory '$1'."
      exit 1
    fi
  fi
}

checkStatus() {
  # Check the status of the project and template repositories.
  # If the project repository is not a git repository, exit with an error message.
  # If the template repository is not a git repository, exit with an error message.
  # If the project repository is not up-to-date with the template repository, exit with an error message.
  # If the project repository is up-to-date with the template repository, print a success message.
  isGitRepo
  git status
  # if the file .gitmodules then read the file cd into the submodule and git status. if no .gitmodules then exit with message
  if [ -f .gitmodules ]; then
    while read line; do
      if [[ $line == "path"* ]]; then
        path=$(echo $line | cut -d'=' -f2)
        cd $path
        echo "Checking status of submodule: $path"
        isGitRepo
        git status
        cd ..
      fi
    done < .gitmodules
  else
    echo "No submodules found"
  fi
}

# options flags for the script -h, --help for help , -n create new project and remote repository, any combination of the following will implement each: -a for article, -p lesson plan, -l lab, -b for beamer presentation
usage () {
  echo "Usage: $0 [-h|--help] [-n <name>] [-e <path>] [-a] [-p] [-l] [-b] [-c] [-u <url>]"
  echo 
  echo "  -h|--help   Display help"
  echo "  -n <name>   Create new project and remote repository. Name required"
  echo "  -e <path>   Use the template for the existing project. If path is not provided, the current directory is used"
  echo "  -a          Use article template"
  echo "  -p          Use lesson plan template"
  echo "  -l          Use lab template"
  echo "  -b          Use beamer template"
  echo "  -u <url>    Associate the current project with a remote repository. URL required. Remote repository must exist"
  echo "  -c          Check status of project and template repositories"
  echo 
  echo " example: $0 -n MyProject -a -p -l -b New project with article, lesson plan, lab, and beamer templates"
  echo " example: $0 -e /path/to/existing/project -alb Use the template for the existing project with article, lesson plan, and lab templates"
  echo " example: $0 -e -a Use the template for the existing project with article template"
  exit 1
}

getOptions() {
  # if no options are provided display usage
  if [ $# -eq 0 ]; then
    usage
  fi

  # get options
  while getopts ":hn:e:aplbu:c" opt; do #
    case $opt in
      h)
        usage
        ;;
      n)
        echo "Creating new project"
        REPO_NAME=$OPTARG
        newProject
        ;;
      e)
        echo "Using existing project"
        existingProject $OPTARG
        ;;
      a)
        echo "Using article template"
        cp -rnv .template/article/ .
        ;;
      p)
        echo "Using lesson plan template"
        cp -rnv .template/lessonPlan/ .
        ;;
      l)
        echo "Using lab template"
        cp -rnv .template/lab/ .
        ;;
      b)
        echo "Using beamer template"
        cp -rnv .template/presentation/ .
        ;;
      u)
        echo "Associating current project with remote repository"
        REMOTE_URL=$OPTARG
        git remote add origin $REMOTE_URL
        ;;
      c)
        echo "Checking status of project and template repositories"
        checkStatus
        ;;
      \?)
        echo "Invalid option: $OPTARG" 1>&2
        usage
        ;;
      :)
        echo "Option -$OPTARG requires an argument." 1>&2
        usage
        ;;
    esac
  done
}


# main function
main() {
  # get options
  getOptions $@

  # check if the current directory is a git repository
  # isGitRepo
}

# call main function
main $@
