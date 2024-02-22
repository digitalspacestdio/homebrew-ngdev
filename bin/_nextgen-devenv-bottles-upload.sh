#!/bin/bash
set -e
if [[ ! -z $DEBUG ]]; then set -x; fi
pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null
if [[ -z $1 ]]; then
    exit 1;
fi
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
brew tap digitalspacestdio/nextgen-devenv
brew tap digitalspacestdio/nextgen-devenv
cd $(brew tap-info --json digitalspacestdio/nextgen-devenv | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
git stash
git pull

for ARG in "$@"
do
    FORMULAS=$(brew search digitalspacestdio/nextgen-devenv | grep "\($ARG\|$ARG@[0-9]\+\)\$" | awk -F'/' '{ print $3 }' | sort)
    for FORMULA in $FORMULAS; do
        echo "Uploading bottle for $FORMULA ..."
        s3cmd info "s3://homebrew-bottles" > /dev/null
        cd ${HOME}/.bottles/$FORMULA.bottle
        ls | grep $FORMULA'.*--.*.gz$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
        ls | grep $FORMULA'.*--.*.json$' | awk -F'--' '{ print $0 " " $1 "-" $2 }' | xargs $(if [[ "$OSTYPE" != "darwin"* ]]; then printf -- '--no-run-if-empty'; fi;) -I{} bash -c 'mv {}'
        for jsonfile in ./*.json; do
            jsonfile=$(basename $jsonfile)
            JSON_FORMULA_NAME=$(jq -r '.[].formula.name' "$jsonfile" | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
            if ! [[ -z $JSON_FORMULA_NAME ]]; then
                mergedfile=$(jq -r '.["digitalspacestdio/nextgen-devenv/'$JSON_FORMULA_NAME'"].formula.name + "-" + ."digitalspacestdio/nextgen-devenv/'$JSON_FORMULA_NAME'".formula.pkg_version + ".json"' "$jsonfile" | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
                set -x
                while read tgzName; do
                    if [[ -f "$tgzName" ]]; then
                        s3cmd info "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$tgzName" >/dev/null 2>&1 && {
                            s3cmd del "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$tgzName"
                        } || /usr/bin/true
                        s3cmd put "$tgzName" "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$tgzName"
                    fi
                done < <(jq -r '."digitalspacestdio/nextgen-devenv/'$JSON_FORMULA_NAME'".bottle.tags[].filename' "$jsonfile" | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
                set +x
                s3cmd info "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$mergedfile" >/dev/null && {
                    s3cmd get "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$mergedfile" "$mergedfile".src
                    if [[ "object" != $(cat "$mergedfile".src| jq -r type | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;') ]]; then
                        cp "$jsonfile" "$mergedfile".src
                    fi
                    jq -s  '.[1]."digitalspacestdio/nextgen-devenv/'$JSON_FORMULA_NAME'".bottle.tags = .[0]."digitalspacestdio/nextgen-devenv/'$JSON_FORMULA_NAME'".bottle.tags * .[1]."digitalspacestdio/nextgen-devenv/'$JSON_FORMULA_NAME'".bottle.tags | .[1]' "$mergedfile".src "$jsonfile" > "$mergedfile"
                    s3cmd del "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$mergedfile"
                    s3cmd put "$mergedfile" "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$mergedfile"
                    brew bottle --skip-relocation --no-rebuild --merge --write --no-commit --json "$mergedfile"
                    rm "$mergedfile" "$mergedfile".src
                } || {
                    s3cmd put "$jsonfile" "s3://homebrew-bottles/nextgen-devenv/$FORMULA/$mergedfile"
                    brew bottle --skip-relocation --no-rebuild --merge --write --no-commit --json "$jsonfile"
                } || exit 1
            fi
        done
    done
done

cd $(brew tap-info --json digitalspacestdio/nextgen-devenv | jq -r '.[].path' | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;')
git add .
git commit -m "bottles update"
git pull --rebase
git push
cd -
