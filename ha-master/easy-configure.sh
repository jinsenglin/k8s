#!/bin/bash

set -e

has_changes=$(git status | grep "Changes not staged for commit:" | wc -l)
has_untracked=$(git status | grep "Untracked files:" | wc -l)

if [ $has_changes == 1 -o $has_untracked == 1 ]; then
    git add -A
    git commit -m "update config script"
    git push
fi

bash remote-runner-wrapper.sh git_pull
bash remote-runner-wrapper.sh configure
