#!/usr/bin/env bash
export PATH="$PATH:/tools"

args="$@"

exec scl enable rh-python36 "pipenv run $args"
