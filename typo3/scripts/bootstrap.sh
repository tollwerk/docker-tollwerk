#!/bin/bash

FIXTURE_DIR=/fixture
PROJECT_DIR=/www
PUBLIC_DIR=$PROJECT_DIR/public

# Create the public webroot if necessary
if [[ ! -e $PUBLIC_DIR ]]; then
  mkdir -p $PUBLIC_DIR
elif [[ ! -d $PUBLIC_DIR ]]; then
  echo "$PUBLIC_DIR already exists but is not a directory" 1>&2
fi

# Install TYPO3
#if [[ ! -f "/www/composer.json" ]]; then
#  cd "/www" || exit 1
#  composer require typo3/minimal "${TYPO3_VERSION}" \
#    typo3/cms-belog \
#    typo3/cms-beuser \
#    typo3/cms-filemetadata \
#    typo3/cms-fluid-styled-content \
#    typo3/cms-form \
#    typo3/cms-linkvalidator \
#    typo3/cms-lowlevel \
#    typo3/cms-reports \
#    typo3/cms-rte-ckeditor \
#    typo3/cms-scheduler \
#    typo3/cms-setup \
#    typo3/cms-t3editor \
#    typo3/cms-tstemplate \
#    typo3/cms-viewpage ||
#    exit 2
#  #    fluidtypo3/vhs
#  #    tollwerk/tw-base \
#
#  # Install Fractal
#  #  if [[ "${FRACTAL}" == "1" ]]; then
#  #    composer require tollwerk/tw-componentlibrary
#  #  fi
#  touch public/FIRST_INSTALL
#fi

find $FIXTURE_DIR -type f | while read F; do
  TF="$PROJECT_DIR/$(basename $F)"
  if [[ ! -f "$TF" ]]; then
    cp "$F" "$TF"
  fi
done

AUTHOR_NAME
AUTHOR_EMAIL
AUTHOR_FULL
EXTENSION_KEY_SC
EXTENSION_KEY_UCC
EXTENSION_KEY_CMP
EXTENSION_KEY_DASHED
PROJECT_NAME
PROJECT_URL
YEAR
TYPO3_VERSION_REQ
TYPO3_VERSION_TAG

#fluidtypo3/flux

#env

exec "$@"
