#!/usr/bin/env bash

if [[ $# -eq 0 ]]
then
  echo 'USAGE: version.sh <kubernetes-version>'
  exit 1
fi

VERSION=$(git \
    -c 'versionsort.suffix=-' \
    ls-remote \
    --exit-code \
    --tags \
    --sort='v:refname' \
    git@github.com:kubernetes/autoscaler.git \
    "refs/tags/cluster-autoscaler-$1*" \
  | tail -n 1 \
  | cut -d '/' -f 3 \
  | cut -d '-' -f 3)

jq -n --arg version "$VERSION" '{"version":$version}'

