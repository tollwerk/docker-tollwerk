#!/bin/bash

FIXTURE_DIR=/fixture
PROJECT_DIR=/www
PUBLIC_DIR=$PROJECT_DIR/public
EXTENSION_SOURCE_DIR=/extension
EXTENSION_TARGET_DIR="$PUBLIC_DIR/typo3conf/ext/$TYPO3_PROJECT_EXTENSION"
EXTENSION_SPLIT=(${TYPO3_PROJECT_EXTENSION//_/ })
EXTENSION_KEY_UCC=$(printf %s "${EXTENSION_SPLIT[@]^}")
FRACTAL_MODULES=

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

# Substitute markers in a file
substituteMarkers() {
    sed -i'' \
        -e "s|YEAR|$(date +%Y)|g" \
        -e "s|TYPO3_VERSION_REQ|$TYPO3_VERSION|g" \
        -e "s|TYPO3_VERSION_TAG|$TYPO3_VERSION_TAG|g" \
        -e "s|AUTHOR_NAME|$AUTHOR_NAME|g" \
        -e "s|AUTHOR_EMAIL|$AUTHOR_EMAIL|g" \
        -e "s|AUTHOR_FULL|$AUTHOR_NAME <$AUTHOR_EMAIL>|g" \
        -e "s|PROJECT_KEY|$PROJECT_KEY|g" \
        -e "s|PROJECT_NAME|$PROJECT_NAME|g" \
        -e "s|PROJECT_DESCRIPTION|$PROJECT_DESCRIPTION|g" \
        -e "s|PROJECT_URL|$PROJECT_URL|g" \
        -e "s|EXTENSION_KEY_SC|$TYPO3_PROJECT_EXTENSION|g" \
        -e "s|EXTENSION_KEY_DASHED|${TYPO3_PROJECT_EXTENSION/_/-}|g" \
        -e "s|EXTENSION_KEY_CMP|tx_${TYPO3_PROJECT_EXTENSION/_/}|g" \
        -e "s|EXTENSION_KEY_UCC|$EXTENSION_KEY_UCC|g" \
        -e "s|FRACTAL_MODULES|$FRACTAL_MODULES|g" \
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
if [[ ! -f "/www/composer.json" ]]; then
    cd "/www" || exit 1
    cp "/scripts/composer.json" "/www/composer.json" || exit 2
    substituteMarkers "/www/composer.json" || exit 3
    composer require typo3/minimal "${TYPO3_VERSION}" \
        typo3/cms-belog \
        typo3/cms-beuser \
        typo3/cms-filemetadata \
        typo3/cms-fluid-styled-content \
        typo3/cms-form \
        typo3/cms-linkvalidator \
        typo3/cms-lowlevel \
        typo3/cms-reports \
        typo3/cms-rte-ckeditor \
        typo3/cms-scheduler \
        typo3/cms-setup \
        typo3/cms-t3editor \
        typo3/cms-tstemplate \
        typo3/cms-viewpage \
        typo3/cms-lang \
        helhum/typo3-console \
        fluidtypo3/vhs \
        tollwerk/tw-base || exit 4

    # Install the component library (if requested)
    if [[ "${FRACTAL}" == "1" ]]; then
        composer require tollwerk/tw-componentlibrary
    fi
fi

# Setup TYPO3
if [[ ! -f "/www/public/typo3conf/PackageStates.php" ]]; then
    cd "/www" || exit 1
    php vendor/bin/typo3cms install:setup --no-interaction --use-existing-database --database-driver=mysqli \
        --web-server-config=apache --site-setup-type=site
fi

# Determine the installed TYPO3 version
TYPO3_VERSION_TAG=$(/www/vendor/bin/typo3 -V | cut -d ' ' -f 3)

# Recursively install the toolchain resources
if [[ ! -e "/www/package.json" ]]; then
    cd "/www" || exit 1

    # Install fixture
    installRecursive "$FIXTURE_DIR" "$PROJECT_DIR" 0 || exit 5

    # Define Fractal Node modules
    if [[ "${FRACTAL}" == "1" ]]; then
        FRACTAL_MODULES="@frctl/fractal fancy-log fractal-typo3"

        # Add Fractal Tenon plugin
        if [[ "${FRACTAL_TENON_API_KEY}" != "" ]] && [[ "${FRACTAL_TENON_PUBLIC_URL}" != "" ]]; then
            FRACTAL_MODULES="$FRACTAL_MODULES fractal-tenon"
        fi
    fi

    # Substitute markers in package.json
    substituteMarkers "/www/package.json" || exit 6
fi

# Recursively install the provider extension templates (with marker substitution)
if [[ "${TYPO3_PROJECT_EXTENSION}" != "" ]] && [[ ! -e "$EXTENSION_TARGET_DIR" ]]; then
    cd "/www" || exit 1
    installRecursive "$EXTENSION_SOURCE_DIR" "$EXTENSION_TARGET_DIR" 1 || exit 7
    cd "/www" || exit 1
    php /scripts/configure-autoload-psr4.php --add "Tollwerk/$EXTENSION_KEY_UCC" "Classes"
    php /scripts/configure-autoload-psr4.php --add --dev "Tollwerk/$EXTENSION_KEY_UCC/Tests" "Tests"
    php /scripts/configure-autoload-psr4.php --add --dev "Tollwerk/$EXTENSION_KEY_UCC/Component" "Components"
    composer dump-autoload -o || exit 8
    php vendor/bin/typo3 extension:activate "${TYPO3_PROJECT_EXTENSION}"
fi

exec "$@"
