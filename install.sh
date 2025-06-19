#!/usr/bin/env bash
VERSION=3
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Change to that directory
cd "$SCRIPT_DIR"

DIST=$SCRIPT_DIR/dist
mkdir -p "$DIST"


source compile.env 2>/dev/null
FOLDER="$(basename $(pwd))"
APP_NAME="${APP_NAME:-$FOLDER}"

FILEPATH_APP="$DIST/$APP_NAME-linux-x86_64"
#~/.local/bin
FOLDER_INSTALL="/usr/local/bin"
FILEPATH_APP_INSTALL=$FOLDER_INSTALL/$APP_NAME
echo "[?] will install:  $FILEPATH_APP --> $FILEPATH_APP_INSTALL"
echo "[?] Need sudo to install"
sudo echo "[?] got sudo"
set -x
mkdir -p "$FOLDER_INSTALL"
sudo cp "$FILEPATH_APP" "$FILEPATH_APP_INSTALL"


