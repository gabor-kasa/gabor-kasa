#!/bin/bash

own_list () {
  pushd "$WORKSPACE" >/dev/null

  ls -1 | while read D; do
    if [[ -r $D/.github/CODEOWNERS ]]; then
      pushd $D >/dev/null

      OWNER=$(grep -c "iot\|external\|kontrol\|hospitality" .github/CODEOWNERS)

      if (( $OWNER > 0 )); then
        echo $D
      fi

      popd >/dev/null
    fi
  done

  popd >/dev/null
}

ownrepo () {
  pushd "$WORKSPACE" >/dev/null

  own_list | while read REPO ;
  do
    echo "========================================"
    echo -e "‣ \033[32m$REPO\e[0m"

    cd $REPO

    bash -c $@

    cd ..

    echo -e ""
  done

  popd >/dev/null
}

owntest () {
  pushd "$WORKSPACE" >/dev/null

  own_list | while read REPO ;
  do
    cd $REPO

    bash -c $@ > /dev/null 2>&1

    if [ $? -eq 0 ]; then
      echo $REPO
    fi

    cd ..
  done

  popd >/dev/null
}

own_pull () {
  pushd "$WORKSPACE" >/dev/null

  own_list | while read REPO ;
  do
    echo "========================================"
    echo -e "Checking \033[32m$REPO\e[0m"

    cd $REPO
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "⌥ $BRANCH"

    if [[ "$BRANCH" == "master" ]] || [[ "$BRANCH" == "dev" ]]; then
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
    echo -e "\n\n\n"
  done

  popd >/dev/null
}
