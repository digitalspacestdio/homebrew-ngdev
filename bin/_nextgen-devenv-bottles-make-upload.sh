#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

FORMULAS=$(brew search digitalspacestdio/nextgen-devenv | grep "$1\|$1@[0-9]\+" | awk -F'/' '{ print $3 }' | sort)

for FORMULA in $FORMULAS; do
    echo "---> Starting $FORMULA"
    ./_nextgen-devenv-bottles-make.sh $FORMULA && {
        if [[ -z $NO_UPLOAD ]];  then
            ./_nextgen-devenv-bottles-upload.sh $FORMULA || echo "Failed to upload bottles for $FORMULA"
        fi
    } || echo "Failed to build bottles for $FORMULA"
    echo "---> Finished $FORMULA"
done