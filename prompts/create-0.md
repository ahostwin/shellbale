Code:

Guidelines:
Create a low dependency golang program. (src/main.go)
Define a version variable Go code and set it during the build process using linker flags.
Commandline interface - should provide man page, a help option with usage examples, use std input/output and/or to/from filepath options. Default to stdout if no output file is specified
Create a manpage in "src"
Create a README.md file
Update documentation as features are added

Project:
APP_NAME=shellbale
A "bourne shell" script generator capable of re-creating a folder and all the files and other folders within it
the resulting .sh script will be as human readable as possible, only binary files will difficult to read.
- use as few utilities as possible as they are additional dependencies
- folders are created before a file is recreated
- files are touched before applying file permissions, if the files are empty the will only be touched
- files that are text will be written using escaped heredoc strings
- files that are binary in nature will be hashed, written as base64 escaped heredoc strings and deccoded to a resulting file and the resulting file hash checked
- escaped heredoc strings (according to heredoc documentation using \HEREDOC will escape the contents), the heredoc delimiter name should have a "__" prefix, be capitalized and reflect the extension or the filename, or a unixtime. This is to avoid collisions if there are multiple layers of heredocs in the text files. The closing heredoc delimiter should always be on it's own line.


shellbale -i ./example_folder -o example_folder.sh



Example script that is generated (example_folder.sh), use this as a guide, make note of any improvements and apply them to your approach:
```
#!/usr/bin/sh
# built using shellbale version 1

mkdir -p example_folder/notes
FILEPATH="example_folder/notes/README.md"
touch "$FILEPATH"
chmod +x "$FILEPATH"
cat <<\__MD > "$FILEPATH" 
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
if [ "$COMPUTED_HASH" = "$EXPECTED_HASH" ]; then
    exit 0
else
    echo "Hash does not match! $FILE"
    echo "Expected: $EXPECTED_HASH"
    echo "Got: $COMPUTED_HASH"
    exit 1
fi
```





