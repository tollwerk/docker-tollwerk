#!/bin/bash

PROJECT_DIR=/www
PUBLIC_DIR=$PROJECT_DIR/public

# Recursively create a directory (if it doesn't exist yet)
makeDirectory() {
    if [[ ! -e "$1" ]]; then
        mkdir -p "$1"
        return $?
    elif [[ ! -d "$1" ]]; then
        echo "$1 already exists but is not a directory" 1>&2
        return 1
    fi
    return 0
}

# Create the public webroot if necessary
makeDirectory "$PUBLIC_DIR"

exec "$@"
