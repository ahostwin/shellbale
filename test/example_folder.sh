#!/bin/sh
# built using shellbale version v1.0.0

cat << \__TREE > /dev/null
example_folder/
    ├── 1/
    │   └── 2/
    │       └── 3/
    │           └── 4/
    │               └── 5/
    │                   └── 6/
    │                       └── 7/
    │                           └── 8/
    │                               └── 9/
    │                                   └── ok.txt
    ├── emoji😀/
    │   ├── emptyfolder/
    │   ├── file.sh
    │   ├── red_dot.png
    │   └── touch.txt
    ├── images/
    │   └── red_dot.png
    ├── notes/
    │   └── README.md
    ├── prompts/
    │   └── chats/
    │       └── create.md
    └── scripts/
        └── commit.sh

16 directories, 8 files
__TREE


mkdir -p "1"
mkdir -p "1/2"
mkdir -p "1/2/3"
mkdir -p "1/2/3/4"
mkdir -p "1/2/3/4/5"
mkdir -p "1/2/3/4/5/6"
mkdir -p "1/2/3/4/5/6/7"
mkdir -p "1/2/3/4/5/6/7/8"
mkdir -p "1/2/3/4/5/6/7/8/9"

FILEPATH="1/2/3/4/5/6/7/8/9/ok.txt"
touch "$FILEPATH"
chmod 777 "$FILEPATH"

mkdir -p "emoji😀"
mkdir -p "emoji😀/emptyfolder"

FILEPATH="emoji😀/file.sh"
touch "$FILEPATH"
cat <<\__EOF_SH_1745286416 > "$FILEPATH"
test utf-8
__EOF_SH_1745286416


FILEPATH="emoji😀/red_dot.png"
touch "$FILEPATH"
EXPECTED_HASH=b5516feae67e8baa9c94c9b3390c86538795d8b9a69d6cdddeedec1f88c6b33b
cat <<\__EOF_PNG_1745286243 | base64 -d > "$FILEPATH"
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKBAMAAAB/HNKOAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAD1BMVEUAAAD/AAD/AAD/AAD////UIhd9AAAAA3RSTlMACI2hprFLAAAAAWJLR0QEj2jZUQAAAAd0SU1FB+kEFRcUI/p48lUAAAAdSURBVAjXY2DABIzKikCSydgISDIbG8PZEHEEAAAuxwHCIy5TFgAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyNS0wNC0yMVQyMzoyMDozNSswMDowMAxWpGAAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjUtMDQtMjFUMjM6MjA6MzUrMDA6MDB9CxzcAAAAAElFTkSuQmCC
__EOF_PNG_1745286243
COMPUTED_HASH=$(sha256sum "$FILEPATH" | cut -d' ' -f1)
if [ "$COMPUTED_HASH" != "$EXPECTED_HASH" ]; then
    echo "Hash does not match for $FILEPATH!"
fi


FILEPATH="emoji😀/touch.txt"
touch "$FILEPATH"

mkdir -p "images"

FILEPATH="images/red_dot.png"
touch "$FILEPATH"
EXPECTED_HASH=b5516feae67e8baa9c94c9b3390c86538795d8b9a69d6cdddeedec1f88c6b33b
cat <<\__EOF_PNG_1745286112 | base64 -d > "$FILEPATH"
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKBAMAAAB/HNKOAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAD1BMVEUAAAD/AAD/AAD/AAD////UIhd9AAAAA3RSTlMACI2hprFLAAAAAWJLR0QEj2jZUQAAAAd0SU1FB+kEFRcUI/p48lUAAAAdSURBVAjXY2DABIzKikCSydgISDIbG8PZEHEEAAAuxwHCIy5TFgAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyNS0wNC0yMVQyMzoyMDozNSswMDowMAxWpGAAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjUtMDQtMjFUMjM6MjA6MzUrMDA6MDB9CxzcAAAAAElFTkSuQmCC
__EOF_PNG_1745286112
COMPUTED_HASH=$(sha256sum "$FILEPATH" | cut -d' ' -f1)
if [ "$COMPUTED_HASH" != "$EXPECTED_HASH" ]; then
    echo "Hash does not match for $FILEPATH!"
fi

mkdir -p "notes"

FILEPATH="notes/README.md"
touch "$FILEPATH"
cat <<\__EOF_MD_1745289616 > "$FILEPATH"
Example file
__EOF_MD_1745289616

mkdir -p "prompts"
mkdir -p "prompts/chats"

FILEPATH="prompts/chats/create.md"
touch "$FILEPATH"

mkdir -p "scripts"

FILEPATH="scripts/commit.sh"
touch "$FILEPATH"
chmod 755 "$FILEPATH"
cat <<\__EOF_SH_1745289636 > "$FILEPATH"
#!/usr/bin/env bash
VERSION=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"


echo "read COMMIT_MSG"
read COMMIT_MSG

git add .
git commit -m "$COMMIT_MSG"
__EOF_SH_1745289636
