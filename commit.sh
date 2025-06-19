#!/usr/bin/env bash
VERSION=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"


echo "read COMMIT_MSG"
read COMMIT_MSG

git add .
git commit -m "$COMMIT_MSG"

cat <<\NOTES>/dev/null
tag=
git add . && git commit -m "Release v$tag" && git tag "v$tag"
#git push origin "v$tag"
NOTES
