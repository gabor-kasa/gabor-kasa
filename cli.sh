#!/bin/bash

ownrepo_list () {
  multi @kasadev/iot 2>/dev/null | grep -B 3 iot | grep -v "====" | grep -v "^--" | grep -v .github/CODEOWNERS
}

ownrepo () {
  ownrepo_list | while read REPO ;
  do
    echo "========================================"
    echo Checking $REPO

    cd $REPO

    bash -c $@

    cd ..
  done
}

