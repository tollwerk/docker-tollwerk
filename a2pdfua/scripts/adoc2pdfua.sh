#!/usr/bin/env bash

# Base parameters
version="v2.0";
help="Usage";

# Command line arguments
CWD=$(pwd);
REAL=$(realpath "$0");
BASE=$(dirname "$REAL");
ASCIIDOC=;
THEME="";
KEEP=0;
OUTFILE="";
FOPCONFIG="$BASE/fop/fop.xml";
VERBOSE=0;
TIMESTAMP=$(date +%s);
TITLE="AsciiDoc to PDF/UA converter $version";
SEP="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ARGSTR="[-t|--theme theme] [-o|--out outfile] [-k|--keep] [-v|--verbose] source-file";

# Read command line arguments
while [[ "$#" -gt 0 ]]; do case $1 in
  -t|--theme) THEME="$2"; shift;;
  -o|--out) OUTFILE="/project/$2"; shift;;
  -h|--help) echo -e $help; exit 0;;
  -k|--keep) KEEP=1;;
  -v|--verbose) VERBOSE=1;;
  -*) echo >&2 "$TITLE";
      echo >&2 "$SEP";
      echo "Please use one of the following styles:
    $0 -h
    $0 $ARGSTR"; exit 1;;
  *) ASCIIDOC=$(realpath "$1"); shift; break;;
esac; shift; done

# Functions
######################################################################
function rmfile {
    file="$1";
    if [ -f "$file" ]; then
        rm "$file";
        if [ ! $? -eq 0 ]; then
            echo >&2 "$TITLE";
            echo >&2 "$SEP";
            # eend $? "A file named $file already exists and cannot be deleted";
            exit 2;
        fi;
    fi;
}
######################################################################

# If no AsciiDoc source file was given
if [ "$ASCIIDOC" = "" ]; then
    echo >&2 "$TITLE";
    echo >&2 "$SEP";
    echo "Please use one of the following styles:
    $0 -h
    $0 $ARGSTR"; exit 3;
fi;

# If the source file doesn't exist
if [ ! -f "$ASCIIDOC" ]; then
    echo >&2 "$TITLE";
    echo >&2 "$SEP";
    echo "Unknown source file: $ASCIIDOC";
    exit 4;
fi;

# If a custom theme has been chosen
if [ "$THEME" = "" ]; then
    XSL="$BASE/xsl/default.xsl";
else
    XSL="$BASE/theme/$THEME.xsl";
    if [ ! -f "$XSL" ]; then
        echo >&2 "$TITLE";
        echo >&2 "$SEP";
        echo "Unknown theme: $THEME";
        exit 5;
    fi;
    if [ -f "$BASE/theme/fop.xml" ]; then
        FOPCONFIG="$BASE/theme/fop.xml";
    fi;
fi;

# Determine source base name
SOURCEDIRNAME=$(dirname -- "$ASCIIDOC");
SOURCEFILENAME=$(basename -- "$ASCIIDOC");
SOURCEBASENAME=${SOURCEFILENAME%.*};
THEMEBASE=$(dirname "$XSL");

# If no explicit outfile was given
if [ "$OUTFILE" = "" ]; then
    OUTFILE="/project/$SOURCEBASENAME.pdf";
fi;

# Determine XML & FO target files
XMLFILE="$SOURCEDIRNAME/$SOURCEBASENAME.$TIMESTAMP.xml";
FOFILE="$SOURCEDIRNAME/$SOURCEBASENAME.$TIMESTAMP.fo";
PDFFILE="$SOURCEDIRNAME/$SOURCEBASENAME.$TIMESTAMP.pdf";

# Use theme specific FOP configuration if available
if [ -f "$BASE/theme/$THEME.fop.xml" ]; then
    FOPCONFIG="$BASE/theme/$THEME.fop.xml";
fi;

# Remove existing files
rmfile "$OUTFILE";
rmfile "$XMLFILE";
rmfile "$FOFILE";

# Change to source file directory
cd "$SOURCEDIRNAME";

# AsciiDoc conversion
echo "Converting AsciiDoc to DocBook v4.5 XML";
if [ $VERBOSE -eq 1 ]; then
        asciidoc --backend docbook --verbose -f "$BASE/asciidoc/docbook45.conf" --out-file "$XMLFILE" "$ASCIIDOC";
else
        asciidoc --backend docbook -f "$BASE/asciidoc/docbook45.conf" --out-file "$XMLFILE" "$ASCIIDOC";
fi;
if [ $? -ne 0 ]; then
        # eend $? "AsciiDoc conversion failed";
        exit 6;
fi;

# Lint XML
echo "Linting DocBook v4.5 XML";
xmllint --nonet --noout --valid "$XMLFILE";
if [ $? -ne 0 ]; then
        # eend $? "DocBook v4.5 XML is invalid";
        exit 7;
fi;

# Transform DocBook v4.5 XML to XSL-FO
echo "Transforming DocBook v4.5 XML to XSL-FO";
if [ $VERBOSE -eq 1 ]; then
        xsltproc --verbose --stringparam theme.base "$THEMEBASE" --output "$FOFILE" "$XSL" "$XMLFILE";
#        xsltproc --verbose --stringparam callout.graphics 0 --stringparam navig.graphics 0 --stringparam admon.textlabel 1 \
#        --stringparam admon.graphics 0 --stringparam admon.graphics 0 --output "$FOFILE" "$XSL" "$XMLFILE";
else
        xsltproc --stringparam theme.base "$THEMEBASE" --output "$FOFILE" "$XSL" "$XMLFILE" > /dev/null 2>&1;
#        xsltproc --stringparam callout.graphics 0 --stringparam navig.graphics 0 --stringparam admon.textlabel 1 \
#        --stringparam admon.graphics 0 --output "$FOFILE" "$XSL" "$XMLFILE" > /dev/null 2>&1;
fi;
if [ $? -ne 0 ]; then
        # eend $? "DocBook v4.5 XML transformation failed";
        exit 8;
fi;

# Creating PDF from XSL-FO
echo "Processing XSL-FO to PDF/UA";
if [ $VERBOSE -eq 1 ]; then
        /fop/fop -v -c "$FOPCONFIG" -fo "$FOFILE" -pdf "$PDFFILE";
else
        /fop/fop -c "$FOPCONFIG" -fo "$FOFILE" -pdf "$PDFFILE" > /dev/null 2>&1;
fi;
if [ $? -ne 0 ]; then
        # eend $? "PDF/UA generation failed";
        exit 9;
fi;

# Move the PDF to its final destination
mv "$PDFFILE" "$OUTFILE";

# Delete temporary files if not requested
if [ $KEEP -eq 0 ]; then
    rm "$XMLFILE";
    rm "$FOFILE";
else
    xmltargetfile="$(dirname -- "$OUTFILE")/$SOURCEBASENAME.xml";
    fotargetfile="$(dirname -- "$OUTFILE")/$SOURCEBASENAME.fo";
    rmfile "$xmltargetfile";
    rmfile "$fotargetfile";
    mv "$XMLFILE" "$xmltargetfile";
    mv "$FOFILE" "$fotargetfile";
fi;
