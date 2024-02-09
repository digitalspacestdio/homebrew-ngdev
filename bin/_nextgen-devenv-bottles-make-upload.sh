#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

if [ -z $1 ]; then
    FORMULAS=$(brew search digitalspacestdio/nextgen-devenv | awk -F'/' '{ print $3 }' | sort)
else
    FORMULAS=$(brew search digitalspacestdio/nextgen-devenv | grep "$1\|$1@[0-9]\+" | awk -F'/' '{ print $3 }' | sort)
fi

./_nextgen-devenv-bottles-make.sh $FORMULAS && {
    if [[ -z $NO_UPLOAD ]];  then
        ./_nextgen-devenv-bottles-upload.sh $FORMULAS
    fi
}