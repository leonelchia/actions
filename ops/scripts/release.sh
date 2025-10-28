#!/bin/bash

# Define variables
DEVELOP_BRANCH="develop"
STAGE_BRANCH="stage"

# Check if the script is already executable
if [ ! -x "$0" ]; then
    echo "Making the script executable..."
    chmod +x "$0"
fi

# Check if a commit hash is provided as an argument
if [ -z "$1" ]; then
    echo "Error: No commit hash provided."
    echo "Usage: $0 <commit-hash>"
    exit 1
fi

RELEASE_COMMIT_HASH="$1"

# Fetch the latest changes
git fetch --all
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch updates from remote repositories."
    exit 1
fi

# Check out the develop branch and pull the latest changes
git checkout "$DEVELOP_BRANCH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to check out $DEVELOP_BRANCH branch."
    exit 1
fi
git pull origin "$DEVELOP_BRANCH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to pull updates for $DEVELOP_BRANCH branch."
    exit 1
fi

# Check out the stage branch and reset it to the specific commit
git checkout "$STAGE_BRANCH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to check out $STAGE_BRANCH branch."
    exit 1
fi
git fetch origin "$STAGE_BRANCH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch updates for $STAGE_BRANCH branch."
    exit 1
fi
git reset --hard "$RELEASE_COMMIT_HASH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to reset $STAGE_BRANCH branch to commit $RELEASE_COMMIT_HASH."
    exit 1
fi

# Force push the stage branch to update the remote
git push origin "$STAGE_BRANCH" --force
if [ $? -ne 0 ]; then
    echo "Error: Failed to force push updates to the $STAGE_BRANCH branch."
    exit 1
fi

echo "Release from $DEVELOP_BRANCH to $STAGE_BRANCH with hard reset to $RELEASE_COMMIT_HASH complete."