#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

SSH_HOSTS=${SSH_HOSTS:-'macos-sonoma-amd64 macos-sonoma-arm64 linux-amd64'}
TAP=${TAP:-'digitalspacestdio/nextgen-devenv'}
TAP_ETC_PREFIX=${TAP_ETC_PREFIX:-'digitalspace-'}


if [ -z $1 ]; then
    FORMULAS=$(brew search ${TAP} | awk -F'/' '{ print $3 }' | sort)
else
    FORMULAS=$(brew search ${TAP} | grep "$1\|$1@[0-9]\+" | awk -F'/' '{ print $3 }' | sort)
fi

export FORMULAS_MD5=${FORMULAS_MD5:-$(echo "$FORMULAS" | md5sum | awk '{ print $1 }')}
if [[ -f "/tmp/.nextgen-devenv_bottles_build_${FORMULAS_MD5}.tmp" ]] && [[ $(cat /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp) -eq 0 ]]; then
    read -r -p "A previous incomplete run was found, do you want to continue it? [Y/n] " response
    if [[ "$response" =~ ^(no|n)$ ]]; then
        echo -n '1' > /tmp/.nextgen-devenv_bottles_build_${FORMULAS_MD5}.tmp
    fi
else 
    echo -n '1' > /tmp/.nextgen-devenv_bottles_build_${FORMULAS_MD5}.tmp
fi

if [[ $(cat /tmp/.nextgen-devenv_bottles_created_${FORMULAS_MD5}.tmp) -eq 1 ]]; then
    cd ${TAP_PREFIX};
    for FORMULA in $FORMULAS; do
        REVISION=$(brew info --json ${FORMULA} | jq -r '.[].revision' | awk '{ print $1+=1 }')
        SOURCE_PATH=$(brew info --json ${FORMULA} | jq -r '.[].ruby_source_path')
        TAP_PREFIX=$(brew tap-info --json ${TAP} | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
        uname -a | grep -i darwin && {
            # macos
            sed -i '' "s/revision.*[0-9]\{1,\}/revision ${REVISION}/" "${TAP_PREFIX}/${SOURCE_PATH}"
        } || {
            # linux
            sed "s/revision.*[0-9]\{1,\}/revision ${REVISION}/" "${TAP_PREFIX}/${SOURCE_PATH}"
        }
        git add ${SOURCE_PATH};
    done
    git commit -m "new revision"
    cd -
fi

for SSH_HOST in $SSH_HOSTS; do
    echo -e "\033[33m==> Checking connection to:\033[0m ${SSH_HOST} \033[0m"
    ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} exit && {
        echo -e "\033[32m==> Connection established successfully \033[0m"
    } || {
        echo -e "\033[31m==> Connection failed \033[0m"
        exit 1
    }
done

for SSH_HOST in $SSH_HOSTS; do
    echo -e "\033[90m==> Resolving brew prefix on:\033[37m ${SSH_HOST} \033[0m"
    BREW_PREFIX=$(ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew --prefix'")
    echo -e "\033[90m--> Brew prefix is\033[37m ${BREW_PREFIX} \033[0m"
    [[ -z $BREW_PREFIX ]] && exit 1

    echo -e "\033[90m==> Tapping:\033[37m ${TAP} \033[0m"
    ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew tap ${TAP}'"

    echo -e "\033[90m==> Resolving tap prefix for:\033[37m ${TAP}\033[0m"
    TAP_PREFIX=$(ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew tap-info --json ${TAP}'" | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
    echo -e "\033[90m--> Tap prefix is\033[37m ${TAP_PREFIX} \033[0m"

    echo -e "\033[90m==> Pushing git changes to:\033[37m ${SSH_HOST} \033[0m"
    git push ssh://${SSH_HOST}${TAP_PREFIX} $(git rev-parse --abbrev-ref HEAD)

    echo -e "\033[90m==> Remove installed\033[0m"
    ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew uninstall --ignore-dependencies -f ${FORMULAS}'"

    echo -e "\033[90m==> Remove configs\033[0m"
    ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'rm -rf ${BREW_PREFIX}/etc/${TAP_ETC_PREFIX}*'"

    echo -e "\033[90m==> Building bottles\033[0m"
    ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'NO_PUSH=1 ${TAP_PREFIX}/bin/_nextgen-devenv-bottles-make-upload.sh ${FORMULAS}'"
    
    echo -e "\033[90m==> Pulling git changes\033[0m"
    git pull --rebase ssh://${SSH_HOST}${TAP_PREFIX} $(git rev-parse --abbrev-ref HEAD)
done

echo -e "\033[90m==> Pushing git changes\033[0m"
sleep 1;
rm /tmp/.nextgen-devenv_bottles_build_${FORMULAS_MD5}.tmp