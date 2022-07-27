#!/bin/bash

own_list () {
  pushd "$WORKSPACE" >/dev/null
  REPOS=$(multi @kasadev/iot 2>/dev/null | grep -v cli.sh | grep -B 3 kasadev/iot | grep -v "====" | grep -v "^--" | grep -v .github/CODEOWNERS)

  if [ -z "$OWN_IGNORE" ]; then
    echo $REPOS
  else
    delete=($(echo $OWN_IGNORE | tr ' ' '\n'))
    for del in ${delete[@]}
    do
     REPOS=("${REPOS[@]/$del}")
    done
    echo $REPOS | grep "\S"
  fi

  popd >/dev/null
}

ownrepo () {
  pushd "$WORKSPACE" >/dev/null

  own_list | while read REPO ;
  do
    echo "========================================"
    echo Checking $REPO

    cd $REPO

    bash -c $@

    cd ..
  done

  popd >/dev/null
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
