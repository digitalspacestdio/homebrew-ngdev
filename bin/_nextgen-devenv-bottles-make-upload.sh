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

export FORMULAS_MD5=${FORMULAS_MD5:-$(echo "$FORMULAS" | md5sum | awk '{ print $1 }')}

if [[ -f "/tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp" ]]; then
    read -r -p "A previous incomplete run was found, do you want to continue it? [Y/n] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(no|n)$ ]]; then
        echo '' > /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp
    fi
else 
    echo '' > /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp
fi

for FORMULA in $FORMULAS; do
    ./_nextgen-devenv-bottles-make.sh $FORMULA
done


if [[ -z $NO_UPLOAD ]];  then
    ./_nextgen-devenv-bottles-upload.sh $(cat /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp)
fi

rm /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp
