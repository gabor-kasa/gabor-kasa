#!/bin/bash

own_list () {
  pushd "$WORKSPACE" >/dev/null
  multi @kasadev/iot 2>/dev/null | grep -B 3 kasadev/iot | grep -v "====" | grep -v "^--" | grep -v .github/CODEOWNERS
  popd >/dev/null
}

ownrepo () {
  own_list | while read REPO ;
  do
    echo "========================================"
    echo Checking $REPO

    cd $REPO

    bash -c $@

    cd ..
  done
}

own_pull () {
  pushd "$WORKSPACE" >/dev/null

  own_list | while read REPO ;
  do
    echo "========================================"
    echo Checking $REPO

    cd $REPO
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "⌥ $BRANCH"

    if [[ "$BRANCH" == "master" ]]; then
      if [ -z "$(git status --porcelain)" ]; then
        echo "✅ Working directory clean"
      else
        echo "⚠️  uncommitted changes"
        git status
      fi

      git fetch --prune
      git pull
    else
      echo "⚠️  not on master"
    fi

    cd ..

    echo "========================================"
    echo -e "\n\n"
  done

  popd >/dev/null
}