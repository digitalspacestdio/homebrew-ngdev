#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
cd "${DIR}"

SSH_HOSTS=${SSH_HOSTS:-'macos-sonoma-amd64 macos-sonoma-arm64 macos-sonoma-arm64'}
TAP=${TAP:-'digitalspacestdio/nextgen-devenv'}

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
    BRE_PREFIX=$(ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew --prefix'")
    echo -e "\033[90m--> Brew prefix is\033[37m ${BRE_PREFIX} \033[0m"

    echo -e "\033[90m==> Tapping:\033[37m ${TAP} \033[0m"
    ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew tap ${TAP}'"

    echo -e "\033[90m==> Resolving tap prefix for:\033[37m ${TAP}\033[0m"
    TAP_PREFIX=$(ssh $(if [[ ! -z $DEBUG ]]; then echo "-v"; else echo "-q"; fi) ${SSH_HOST} "bash --login -c 'brew tap-info --json ${TAP}'" | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
    echo -e "\033[90m--> Tap prefix is\033[37m ${TAP_PREFIX} \033[0m"

    echo -e "\033[90m==> Building bittles\033[0m"
    sleep 1;
    echo -e "\033[90m==> Pulling git changes\033[0m"
    git pull --rebase git://${SSH_HOST}${TAP_PREFIX}
done

echo -e "\033[90m==> Pushing git changes\033[0m"
sleep 1;