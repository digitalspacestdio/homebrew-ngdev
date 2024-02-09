#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

FORMULAS=$(brew search digitalspacestdio/nextgen-devenv | grep "$1\|$1@[0-9]\+" | awk -F'/' '{ print $3 }' | sort)

./_nextgen-devenv-bottles-make.sh $FORMULAS && {
    if [[ -z $NO_UPLOAD ]];  then
        ./_nextgen-devenv-bottles-upload.sh $FORMULAS
    fi
}