#!/bin/bash

# Create the public webroot if necessary
PUBLIC_DIR=/www/public;
if [[ ! -e $PUBLIC_DIR ]]; then
    mkdir $PUBLIC_DIR
elif [[ ! -d $PUBLIC_DIR ]]; then
    echo "$PUBLIC_DIR already exists but is not a directory" 1>&2
fi

env;
echo "<html><head><title>$LABEL_COMPONENTS</title></head><body><h1>$LABEL_COMPONENTS works!</h1></body></html>" > $PUBLIC_DIR/index.html;

exec "$@"
