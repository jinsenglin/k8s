#!/bin/bash

set -e

source rc
bash remote-runner.sh $FIPC kubectl $@
