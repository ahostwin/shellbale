#!/usr/bin/env bash
_VERSION=4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Change to that directory
cd "$SCRIPT_DIR"

DIST=$SCRIPT_DIR/dist
mkdir -p "$DIST"


VERSION=$(git describe --tags 2>/dev/null || echo "dev")


source compile.env 2>/dev/null
FOLDER="$(basename $(pwd))"
APP_NAME="${APP_NAME:-$FOLDER}"

cd "src"

cat <<\__heredoc >> /dev/null
# Initialize Go module
go mod init "$APP_NAME"

# Get dependencies
#go get <any>

#go clean -modcache
go mod download

go mod vendor
__heredoc


# Build for different platforms
echo "[Build] Linux (x86_64)"
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-extldflags '-static' -X main.Version=$VERSION" -o "$DIST/$APP_NAME-linux-x86_64" main.go

#cat <<\__heredoc >> /dev/null
echo "[Build] Linux (ARM)"
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -ldflags "-extldflags '-static' -X main.Version=$VERSION" -o "$DIST/$APP_NAME-linux-arm64" main.go

echo "[Build] Windows (x86_64)"
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-extldflags '-static' -X main.Version=$VERSION" -o "$DIST/$APP_NAME-win-x86_64.exe" main.go

echo "[Build] Mac (ARM)"
GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 go build -ldflags "-extldflags '-static' -X main.Version=$VERSION" -o "$DIST/$APP_NAME-mac-arm64" main.go

echo "[Build] Mac (x86_64)"
GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-extldflags '-static' -X main.Version=$VERSION" -o "$DIST/$APP_NAME-mac-x86_64" main.go


#__heredoc





