#!/usr/bin/env bash
VERSION=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"

../dist/shellbale-linux-x86_64 -i example_folder -t -o example_folder.sh



# idempotent
# tar --sort=name --owner=root:0 --group=root:0 --mtime='UTC 1980-02-01' ... | gzip -n


