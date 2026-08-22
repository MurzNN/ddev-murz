#!/usr/bin/env sh

# List of directories to check and create if missing
DIRS="
.ssh
.local
.local/bin
.cache
.local/share/pnpm
.config/gh
.config/pnpm
.bashrc.d
"

# List of files to check and create if missing
FILES="
.bashrc.d/murz.local.sh
"

# Check/create directories
for dir in $DIRS; do
    if [ ! -d "$HOME/$dir" ]; then
        mkdir -p "$HOME/$dir"
        echo "Created directory: $HOME/$dir"
    fi
done

# Check/create files
for file in $FILES; do
    filepath="$HOME/$file"
    if [ ! -f "$filepath" ]; then
        # Ensure parent directory exists
        mkdir -p "$(dirname "$filepath")"
        touch "$filepath"
        echo "Created empty file: $filepath"
    fi
done

