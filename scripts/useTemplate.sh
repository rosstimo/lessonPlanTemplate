#!/bin/sh

# This script uses my existing LaTeX template to start a new LaTeX project.
# if any steps fail exit with exit code

# Check if a project name argument is provided. If not, exit the script with a usage message.
if [ $# -eq 0 ]; then
  echo "Usage: useTemplate.sh <new-project-name>"
  exit 1
fi

# Set the project name and template repository URL variables.
PROJECT_NAME=$1
TEMPLATE_REPO_URL='https://github.com/rosstimo/lessonPlanTemplate.git'

# Create a new directory for the project with the provided name. If the directory already exists or there is an error, exit the script with an error message.
mkdir "$PROJECT_NAME" || { echo "Error: Failed to create directory '$PROJECT_NAME'."; exit 1; }

# Change into the new directory. Exit if error
cd "$PROJECT_NAME" || { echo "Error: Failed to change into directory '$PROJECT_NAME'."; exit 1; }

# Initialize the new directory as a Git repository. Exit if error
git init

# Add the template repository as a Git submodule within the project repository.
git submodule add $TEMPLATE_REPO_URL .template

# link common files and ignore to avoid rogue copies
# should remove and/or force overwrite here
ln -s .template/common common
cp -rnv .template/.gitignore .
echo "common" >> .gitignore
ln -s .template/scripts/useTemplate.sh useTemplate.sh
echo "useTemplate.sh" >> .gitignore

# copy specific templates for use in current project. don't overwrite
# TODO add use flags to mix and match instead always add all
cp -rnv .template/article/ .
cp -rnv .template/images/ .
cp -rnv .template/lab/ .
cp -rnv .template/lessonPlan/ .
cp -rnv .template/presentation/ .

# Make an initial commit in the project repository.
git add .
git commit -m "Initial commit"
git branch -M main
#git remote add origin "https://github.com/$REMOTE_USER/$PROJECT_NAME.git"

# Print a success message with the project name. and provide instructions to set the origin remote and push the initial commit.
echo "Success! Created '$PROJECT_NAME' from template."
echo "To complete setup, run the following commands:"
echo "cd $PROJECT_NAME"
echo "git remote add origin <remote-repository-url>"
echo "git push -u origin main"
echo "enjoy!"




