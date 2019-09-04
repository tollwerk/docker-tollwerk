#!/bin/bash

FIXTURE_DIR=/fixture
PROJECT_DIR=/www
PUBLIC_DIR=$PROJECT_DIR/public
EXTENSION_SOURCE_DIR=/extension
EXTENSION_TARGET_DIR="$PUBLIC_DIR/typo3conf/ext/$PROJECT_EXTENSION"
EXTENSION_SPLIT=(${PROJECT_EXTENSION//_/ })

# Recursively create a directory
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

# Substitute makers in a file
substituteMarkers() {
  sed -i'' \
    -e "s|YEAR|$(date +%Y)|g" \
    -e "s|TYPO3_VERSION_REQ|$TYPO3_VERSION|g" \
    -e "s|TYPO3_VERSION_TAG|$TYPO3_VERSION_TAG|g" \
    -e "s|AUTHOR_NAME|$AUTHOR_NAME|g" \
    -e "s|AUTHOR_EMAIL|$AUTHOR_EMAIL|g" \
    -e "s|AUTHOR_FULL|$AUTHOR_NAME <$AUTHOR_EMAIL>|g" \
    -e "s|PROJECT_NAME|$PROJECT_NAME|g" \
    -e "s|PROJECT_URL|$PROJECT_URL|g" \
    -e "s|EXTENSION_KEY_SC|$PROJECT_EXTENSION|g" \
    -e "s|EXTENSION_KEY_DASHED|${PROJECT_EXTENSION/_/-}|g" \
    -e "s|EXTENSION_KEY_CMP|tx_${PROJECT_EXTENSION/_/}|g" \
    -e "s|EXTENSION_KEY_UCC|$(printf %s "${EXTENSION_SPLIT[@]^}")|g" \
    $1
}

# Recursively copy the contents of a directory to a target directory (no overwrites)
installRecursive() {
  local SRC="$1"
  local TGT="$2"
  local SUBST="$3"
  makeDirectory $TGT
  if [ "$?" -eq "0" ]; then
    cd $SRC || return $?
    find -type f | while read F; do
      local TF="$TGT/$F"
      local TD=$(dirname $TF)
      makeDirectory $TD
      if [ "$?" -gt 0 ]; then
        return $?
      fi
      cp "$F" "$TF"
      if [ "$SUBST" == "1" ] && [[ $TF =~ .*\.(php|json|yaml|html|xml|xlf|md|js|css|typoscript|tsconfig) ]]; then
        substituteMarkers $TF
      fi
    done
    return 0
  fi
  return $?
}

# Create the public webroot if necessary
makeDirectory "$PROJECT_DIR"

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

# Determine the current TYPO3 version
TYPO3_VERSION_TAG=$(/www/vendor/bin/typo3 -V | cut -d ' ' -f 3)

# Recursively install the toolchain resources
installRecursive "$FIXTURE_DIR" "$PROJECT_DIR" 0

# Recursively install the provider extension templates (with marker substitution)
installRecursive "$EXTENSION_SOURCE_DIR" "$EXTENSION_TARGET_DIR" 1

#fluidtypo3/flux

#env

exec "$@"
