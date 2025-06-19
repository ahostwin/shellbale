#!/usr/bin/env bash
VERSION=3

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"


cat << \__HEREDOC
This file is handwritten to generate a test directory that to be re-created in detail with a generated script.
current problems to test:
- symlinks
- order of applying permissions, read write lock out for recursive directories

__HEREDOC




mkdir -p example_folder/1/2/3/4/5/6/7/8/9
FILEPATH="example_folder/1/2/3/4/5/6/7/8/9/ok.txt"
touch "$FILEPATH"
chmod 640 "$FILEPATH"


mkdir -p example_folder/formats
touch "example_folder/formats/dashed-filename"




mkdir -p example_folder/notes
FILEPATH="example_folder/notes/README.md"
touch "$FILEPATH"
cat <<\__MD > "$FILEPATH" 
Example file
__MD

mkdir -p example_folder/prompts/chats
touch example_folder/prompts/chats/create.md

mkdir -p example_folder/scripts

FILEPATH="example_folder/scripts/commit.sh"
touch "$FILEPATH"
chmod +x "$FILEPATH"
cat <<\__SH > "$FILEPATH" 
#!/usr/bin/env bash
VERSION=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"


echo "read COMMIT_MSG"
read COMMIT_MSG

git add .
git commit -m "$COMMIT_MSG"
__SH

mkdir -p "example_folder/images"
EXPECTED_HASH=b5516feae67e8baa9c94c9b3390c86538795d8b9a69d6cdddeedec1f88c6b33b
FILEPATH="example_folder/images/red_dot.png"
touch "$FILEPATH"
cat <<\__PNG | base64 -d > "$FILEPATH" 
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKBAMAAAB/HNKOAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAD1BMVEUAAAD/AAD/AAD/AAD////UIhd9AAAAA3RSTlMACI2hprFLAAAAAWJLR0QEj2jZUQAAAAd0SU1FB+kEFRcUI/p48lUAAAAdSURBVAjXY2DABIzKikCSydgISDIbG8PZEHEEAAAuxwHCIy5TFgAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyNS0wNC0yMVQyMzoyMDozNSswMDowMAxWpGAAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjUtMDQtMjFUMjM6MjA6MzUrMDA6MDB9CxzcAAAAAElFTkSuQmCC
__PNG

COMPUTED_HASH=$(sha256sum "$FILEPATH" | cut -d' ' -f1)
if [ "$COMPUTED_HASH" != "$EXPECTED_HASH" ]; then
    echo "Hash does not match! $FILE"s
    echo "Expected: $EXPECTED_HASH"
    echo "Got: $COMPUTED_HASH"
    exit 1
fi


# https://en.wikipedia.org/wiki/List_of_file_signatures
FOLDER_MAGIC="example_folder/bin/magic"
mkdir -p "$FOLDER_MAGIC"

FILEPATH="$FOLDER_MAGIC/magic.png"
touch "$FILEPATH"
printf "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic.webp"
touch "$FILEPATH"
printf "\x52\x49\x46\x46\x00\x00\x00\x00\x57\x45\x42\x50" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-8.txt"
touch "$FILEPATH"
printf "\xEF\xBB\xBF" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-16LE.txt"
touch "$FILEPATH"
printf "\xFF\xFE" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-16BE.txt"
touch "$FILEPATH"
printf "\xFE\xFF" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-32LE.txt"
touch "$FILEPATH"
printf "\xFF\xFE\x00\x00" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-32BE.txt"
touch "$FILEPATH"
printf "\x00\x00\xFE\xFF " |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-7.txt"
touch "$FILEPATH"
printf "\x2B\x2F\x76\x2F" |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_SCSU.txt"
touch "$FILEPATH"
printf "\x0E\xFE\xFF " |tee "$FILEPATH" | hexdump -C

FILEPATH="$FOLDER_MAGIC/magic_UTF-EBCDIC.txt"
touch "$FILEPATH"
printf "\xDD\x73\x66\x73" |tee "$FILEPATH" | hexdump -C





# test soft links


# test hardlinks


# test junctions

# test dev files

# test dev unions







