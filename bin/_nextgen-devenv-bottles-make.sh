#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
if [[ -z $1 ]]; then
    echo "Usage $0 <FORMULA_NAME>"
    exit 1;
fi
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=0
brew tap digitalspacestdio/nextgen-devenv

FORMULAS_MD5=${FORMULAS_MD5:-$(echo "$@" | md5sum | awk '{ print $1 }')}

if ! [[ -f "/tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp" ]]; then
    echo '' > /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp
fi

for ARG in "$@"
do
    FORMULAS=$(brew search digitalspacestdio/nextgen-devenv | grep "\($ARG\|$ARG@[0-9]\+\)\$" | awk -F'/' '{ print $3 }' | sort)

    echo "==> Next formulas found:"
    echo -e "\033[33m==> The following formulas are matched:\033[0m"
    echo "$FORMULAS"

    for FORMULA in $FORMULAS; do
        echo -e "\033[33m==> Installing dependencies:\033[0m"
        echo "$FORMULA"
        for DEP in $(brew deps --full --direct $FORMULA | grep 'digitalspacestdio/nextgen-devenv'); do
            if ! grep "$DEP$" /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp; then
                ${DIR}/_nextgen-devenv-bottles-make.sh $
                echo $DEP >> /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp
            fi
        done
    done
    
    sleep 5
    for FORMULA in $FORMULAS; do
        if ! grep "$FORMULA$" /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp; then
            echo -e "\033[33m==> Creating bottles for $FORMULA ...\033[0m"
            rm -rf ${HOME}/.bottles/$FORMULA.bottle
            mkdir -p ${HOME}/.bottles/$FORMULA.bottle
            cd ${HOME}/.bottles/$FORMULA.bottle

            if brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$" > /dev/null; then
                DEPS=$(brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$")
                echo -e "\033[33m==> Installing dependencies ($DEPS) for $FORMULA ..."
                echo -e "\033[0m"
                brew install --quiet $DEPS
                # if brew deps $(brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$") | grep -v $FORMULA"$" > /dev/null; then
                #     DEPS=$(brew deps $(brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$") | grep -v $FORMULA"$")
                #     echo -e "\033[33m==> Installing dependencies ($DEPS) for $FORMULA ..."
                #     echo -e "\033[0m"
                #     brew install -s --quiet $DEPS
                # fi
            fi

            echo "==> Building bottles for $FORMULA ..."
            [[ "true" == $(brew info  --json=v1 $FORMULA | jq '.[0].installed[0].built_as_bottle') ]] || {
                echo "==> Removing previously installed formula $FORMULA ..."
                sleep 3
                brew uninstall --force --ignore-dependencies $FORMULA
            }

            brew install --quiet --build-bottle $FORMULA 2>&1
            brew bottle --skip-relocation --no-rebuild --root-url 'https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/'$FORMULA --json $FORMULA
            ls | grep $FORMULA'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            ls | grep $FORMULA'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            cd $(brew tap-info --json digitalspacestdio/nextgen-devenv | jq -r '.[].path')

            echo $FORMULA >> /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp
        fi
    done
done

