#!/usr/bin/env bash
VERSION=2

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR"


# folder to backup
FOLDER=${FOLDER:-"$(basename $(pwd))"}

# folder to put backups
mkdir -p "_backups"


TIMESTAMP=$(date +%s)
FILEDATETIME=$(date +%Y-%m-%d_%H-%M-%S)

FILENAME_BACKUP="$FOLDER-$FILEDATETIME"


if git log -1 --pretty=%B; then
	# has a git message in repo
	git_last_commit_message_sanitized="$(git log -1 --pretty=%B | head -n1 | sed -E 's/[^a-zA-Z0-9_-]+/_/g; s/_+/_/g; s/_-_/_/g; s/^-|-$//g' | tr '[:upper:]' '[:lower:]' | cut -c1-128)"
	FILENAME_BACKUP="$FOLDER-$FILEDATETIME-$git_last_commit_message_sanitized"
else
	# no message
	FILENAME_BACKUP="$FOLDER-$FILEDATETIME"
fi


#tar --exclude="./backups/*.gz" -zcvf "./backups/$FILENAME_BACKUP.tar.gz" "../$FOLDER"
tar --exclude="*.bak.tar.gz" -zcvf "./_backups/$FILENAME_BACKUP.bak.tar.gz" "../$FOLDER"



popd

# EXTRACT WHILE PRESERVING SYMLINKS
# tar -xhzvf ARCHIVE.tar.gz








