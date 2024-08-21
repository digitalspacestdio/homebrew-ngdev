#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null

TAP_NAME=${TAP_NAME:-"digitalspacestdio/ngdev"}
TAP_SUBDIR=$(echo $TAP_NAME | awk -F/ '{ print $2 }')
BASE_ROOT_URL="https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/${TAP_SUBDIR}"
ARGS=${@:-$(brew search "${TAP_NAME}")}

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=0
brew tap "${TAP_NAME}"

FORMULAS_MD5=${FORMULAS_MD5:-$(echo "$ARGS" | md5sum | awk '{ print $1 }')}

if [[ -n $REBUILD ]] || ! [[ -f "/tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp" ]]; then
    echo -n '' > /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
fi

for ARG in "$ARGS"
do
    FORMULAS=$(brew search "${TAP_NAME}" | grep "($ARG\|$ARG@[0-9]\+)\$" | sort)
    if [[ -n "$FORMULAS" ]]; then
        for FORMULA in $FORMULAS; do
            if [[ -n $REBUILD ]]; then
                brew uninstall --force $FORMULA
            fi
            for DEP in $(brew deps --full --direct $FORMULA | grep "${TAP_NAME}"); do
                if ! grep "$DEP$" /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp > /dev/null; then
                    echo -n -e "\033[33m==> Installing dependency \033[0m"
                    echo -e "$DEP \033[33mfor\033[0m $FORMULA"
                    ${DIR}/_${TAP_SUBDIR}-bottles-make.sh $DEP
                    echo $DEP >> /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
                fi
            done
        done
    fi
    
    sleep 1
    for FORMULA in $FORMULAS; do
        if ! grep "$FORMULA$" /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp; then
            echo -e "\033[33m==> Creating bottles for $FORMULA ...\033[0m"
            rm -rf ${HOME}/.bottles/$FORMULA.bottle
            mkdir -p ${HOME}/.bottles/$FORMULA.bottle
            cd ${HOME}/.bottles/$FORMULA.bottle

            if brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$" > /dev/null; then
                DEPS=$(brew deps --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$")
                echo -e "\033[33m==> Installing dependencies ($DEPS) for $FORMULA ..."
                echo -e "\033[0m"
                if echo $DEPS | grep "${TAP_NAME}"; then
                    brew install -s --quiet $DEPS
                else
                    brew install --quiet $DEPS
                fi
            fi

            echo "==> Building bottles for $FORMULA ..."
            [[ "true" == $(brew info  --json=v1 $FORMULA | jq '.[0].installed[0].built_as_bottle') ]] || {
                echo "==> Removing previously installed formula $FORMULA ..."
                sleep 3
                brew uninstall --force --ignore-dependencies $FORMULA
            }

            brew install --quiet --build-bottle $FORMULA 2>&1
            brew bottle --skip-relocation --no-rebuild --root-url $BASE_ROOT_URL'/'$FORMULA --json $FORMULA
            ls | grep $FORMULA'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            ls | grep $FORMULA'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            cd $(brew tap-info --json "${TAP_NAME}" | jq -r '.[].path')

            echo $FORMULA >> /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
        fi
    done
done
