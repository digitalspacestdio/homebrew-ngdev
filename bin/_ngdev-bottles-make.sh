#!/bin/bash
set -e
export DEBUG=${DEBUG:-''}
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null

TAP_NAME=${TAP_NAME:-"digitalspacestdio/ngdev"}
TAP_SUBDIR=$(echo $TAP_NAME | awk -F/ '{ print $2 }')
BASE_ROOT_URL="https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/${TAP_SUBDIR}"

brew tap "${TAP_NAME}"

ARGS=${@:-$(brew search "${TAP_NAME}" | grep "${TAP_NAME}")}
REBUILD=${REBUILD:-''}

export FORMULAS_MD5=${FORMULAS_MD5:-$(echo "$ARGS" | md5sum | awk '{ print $1 }')}

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=0

if [[ -n $REBUILD ]] || ! [[ -f "/tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp" ]]; then
    echo -n '' > /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
fi

for ARG in $ARGS
do
    FORMULAS=$(brew search "${TAP_NAME}" | grep "${TAP_NAME}" | grep "\($ARG\|$ARG@[0-9]\+\)\$" | sort)
    if [[ -n "$FORMULAS" ]]; then
        for FORMULA in $FORMULAS; do
            if [[ -n $REBUILD ]]; then
                brew uninstall --force --ignore-dependencies $FORMULA $(brew deps --full --direct $FORMULA | grep "${TAP_NAME}")
                rm -rf ${HOME}/.bottles/$FORMULA.bottle
            fi
            for DEP in $(brew deps --full --direct $FORMULA | grep "${TAP_NAME}"); do
                if ! grep "$DEP$" /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp > /dev/null; then
                    echo -n -e "\033[33m==> Building dependency bottle \033[0m"
                    echo -e "$DEP \033[33mfor\033[0m $FORMULA"
                    $0 $DEP
                fi
            done
        done
    fi
    
    for FORMULA in $FORMULAS; do
        if ! [[ -d ${HOME}/.bottles/${FORMULA//"$TAP_NAME/"/}.bottle ]] || ! grep "$FORMULA$" /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp; then
            echo -e "\033[33m==> Creating bottles for $FORMULA ...\033[0m"
            rm -rf ${HOME}/.bottles/${FORMULA//"$TAP_NAME/"/}.bottle
            mkdir -p ${HOME}/.bottles/${FORMULA//"$TAP_NAME/"/}.bottle
            cd ${HOME}/.bottles/${FORMULA//"$TAP_NAME/"/}.bottle

            if brew deps --full --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$" > /dev/null; then
                DEPS=$(brew deps --full --direct $FORMULA | grep $FORMULA | grep -v $FORMULA"$")
                echo -e "\033[33m==> Installing dependencies ($DEPS) for $FORMULA ..."
                echo -e "\033[0m"
                for DEP in $DEPS; do
                    if echo $DEP | grep "${TAP_NAME}"; then
                        brew install -s --quiet $DEP
                    else
                        brew install --quiet $DEP
                    fi
                done
                
            fi

            echo "==> Building bottles for $FORMULA ..."
            [[ "true" == $(brew info --json=v1 $FORMULA | jq '.[0].installed[0].built_as_bottle') ]] || {
                echo "==> Removing previously installed formula $FORMULA ..."
                brew uninstall --force --ignore-dependencies $FORMULA
            }

            brew install --quiet --build-bottle $FORMULA 2>&1
            brew bottle --skip-relocation --no-rebuild --root-url $BASE_ROOT_URL'/'${FORMULA//"$TAP_NAME/"/} --json $FORMULA
            ls | grep ${FORMULA//"$TAP_NAME/"/}'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            ls | grep ${FORMULA//"$TAP_NAME/"/}'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
            cd $(brew tap-info --json "${TAP_NAME}" | jq -r '.[].path')

            echo $FORMULA >> /tmp/.${TAP_SUBDIR}_bottles_created_${FORMULAS_MD5}.tmp
        fi
    done
done

