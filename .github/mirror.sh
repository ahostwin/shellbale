#!/bin/bash

TD=$(mktemp -d)
pushd $TD
git clone --mirror https://gitpub.ahost.win/ahost/shellbale.git shellbale-mirror
cd shellbale-mirror
git remote set-url --push origin git@github.com:ahostwin/shellbale.git
git push --all
git push --tags
popd
trash $TD

