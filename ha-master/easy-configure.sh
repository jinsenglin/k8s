#!/bin/bash

set -e

git add -A
git commit -m "update config script"
git push

bash remote-runner-wrapper.sh git_pull
bash remote-runner-wrapper.sh configure
