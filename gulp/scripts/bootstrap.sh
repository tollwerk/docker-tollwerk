#!/bin/bash

PROJECT_DIR=/project

# Create the public webroot if necessary
if [[ ! -e $PROJECT_DIR ]]; then
  mkdir $PROJECT_DIR
elif [[ ! -d $PROJECT_DIR ]]; then
  echo "$PROJECT_DIR already exists but is not a directory" 1>&2
fi

# Install TYPO3
if [[ ! -f "${PROJECT_DIR}/package-lock.json" ]]; then
  echo "Bootstrapping ..."
  cd "${PROJECT_DIR}" || exit 1
  npm install || exit 2
fi

# Install default Fractal configuration
if [[ ! -f "${PROJECT_DIR}/fractal.js" ]]; then
  echo "Installing default Fractal configuration ..."
  cp /fractal/fractal.dist.js "${PROJECT_DIR}/fractal.js" || exit 3
fi

# Install default Gulp configuration
if [[ ! -f "${PROJECT_DIR}/gulfpile.js" ]]; then
  echo "Installing default Gulp configuration ..."
  cp /fractal/gulpfile.dist.js "${PROJECT_DIR}/gulpfile.js" || exit 3
fi

exec "$@"
