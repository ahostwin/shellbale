#!/usr/bin/env bash
VERSION=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"


echo "read COMMIT_MSG"
read COMMIT_MSG

git add .
git commit -m "$COMMIT_MSG"

cat <<\NOTES>/dev/null
ver=0.0.0
git tag -a v$ver -m "Release version $ver"
git push origin v$ver
NOTES
