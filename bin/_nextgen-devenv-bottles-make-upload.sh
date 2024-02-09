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

echo '' > /tmp/.nextgen-devenv_bottles_created_.tmp

for FORMULA in $FORMULAS; do
    for DEP in $(brew deps --full --direct $FORMULA | grep 'digitalspacestdio/nextgen-devenv'); do
        if ! grep "$DEP" /tmp/.nextgen-devenv_bottles_created_.tmp; then
            ./_nextgen-devenv-bottles-make.sh $DEP
            echo $DEP >> /tmp/.nextgen-devenv_bottles_created_.tmp
        fi
    done
done

for FORMULA in $FORMULAS; do
    if ! grep "$FORMULA" /tmp/.nextgen-devenv_bottles_created_.tmp; then
        ./_nextgen-devenv-bottles-make.sh $FORMULA
        echo $DEP >> /tmp/.nextgen-devenv_bottles_created_.tmp
    fi
done


if [[ -z $NO_UPLOAD ]];  then
    echo $(cat /tmp/.nextgen-devenv_bottles_created_.tmp) | xargs ./_nextgen-devenv-bottles-upload.sh
fi

rm /tmp/.nextgen-devenv_bottles_created_.tmp