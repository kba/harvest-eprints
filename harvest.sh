#!/bin/bash

# set -e
# set -x

# Folder structure
# ./harvest.sh
# ./README.md
# ./site                   # $BASE_DIR
# └── <baseurl>/           # $SITE_DIR
#     ├── xquery/
#     ├── records/         # $HARVEST_DIR
#     ├── identifiers.lst  # $IDENTIFIER_LIST
#     └── identifiers.time # $TIMESTAMP_FILE

EXAMPLE_URLS="
  * epub.uni-bayreuth.de
  * kups.ub.uni-koeln.de
  * oops.uni-oldenburg.de
  * ub-madoc.bib.uni-mannheim.de
  * edoc.ub.uni-muenchen.de
  * epub.uni-regensburg.de
  * archiv.ub.uni-heidelberg.de/volltextserver"

COMMANDS=(
    'debug'
    'identifiers'
    'harvest'
    'xquery'
    )


# coloring method $(C)
source ~/.shcolor.sh 2>/dev/null || source <(wget -qO- https://raw.githubusercontent.com/kba/shcolor/master/shcolor.sh|tee ~/.shcolor.sh)

usage() {
    echo "Usage: $(C 4)$0$(C) <$(C 2)${COMMANDS[*]}$(C)> <$(C 3)baseurl$(C)>"
        [[ ! -z "$1" ]] && { echo -e "\n$(C 1)$1$(C)"; }
    exit "$2"
}


timestamp() {
    date +"%Y-%m-%dT%H:%M:%SZ"
}

setup_vars() {
    BASE_DIR=${BASE_DIR:-./site}
    if [[ -z "$BASEURL" ]];then
        # shellcheck disable=SC2012
        usage "$(C 8)ERROR$(C): Must specify baseurl.
Existing:
$(ls "$BASE_DIR"|sed 's/^/  * /g')
Examples: $EXAMPLE_URLS
" 1;
    fi
    SITE_DIR="$BASE_DIR/$BASEURL"
    HARVEST_DIR="$SITE_DIR/records"
    BASEX_DBPATH="$SITE_DIR/BaseXData"
    DEFAULT_TIMESTAMP="2000-01-01T00:00:00Z"
    IDENTIFIER_LIST="$SITE_DIR/identifiers.lst"
    TIMESTAMP_FILE="$SITE_DIR/identifiers.time"
}

setup_sitedir() {
    mkdir -pv "$SITE_DIR"
    mkdir -pv "$HARVEST_DIR"
    mkdir -pv "$BASEX_DBPATH"
    if [[ ! -e "$TIMESTAMP_FILE" ]];then
        echo "$DEFAULT_TIMESTAMP" > "$TIMESTAMP_FILE"
    fi
    TIMESTAMP="$(tail -n1 "$TIMESTAMP_FILE")"
    IDENTIFIER_URL="http://$BASEURL/cgi/oai2?verb=ListIdentifiers&metadataPrefix=oai_dc&from=$TIMESTAMP"
}

debug() {
    echo "ACTION            '$(C 11)$ACTION$(C)'"
    echo "BASEURL           '$(C 11)$BASEURL$(C)'"
    echo "BASE_DIR          '$(C 11)$BASE_DIR$(C)'"
    echo "SITE_DIR          '$(C 11)$SITE_DIR$(C)'"
    echo "HARVEST_DIR       '$(C 11)$HARVEST_DIR$(C)'"
    echo "DEFAULT_TIMESTAMP '$(C 11)$DEFAULT_TIMESTAMP$(C)'"
    echo "IDENTIFIER_LIST   '$(C 11)$IDENTIFIER_LIST$(C)'"
    echo "TIMESTAMP         '$(C 11)$TIMESTAMP$(C)'"
    echo "IDENTIFIER_URL    '$(C 11)$IDENTIFIER_URL$(C)'"
}

identifiers() {
    url="$IDENTIFIER_URL"
    if [[ -n "$1" ]];then
        url="${url}&resumptionToken=$1"
    fi
    echo "Retrieving '${url}'"
    response="$(curl -s "$url")"
    echo "$response" | xmlstarlet sel -t -v '//*[local-name()="header"][not(@status)]/*[local-name()="identifier"]' >> "$IDENTIFIER_LIST"
    echo >> "$IDENTIFIER_LIST"
    resumptionToken=$(echo "$response" | xmlstarlet sel -t -v '//*[local-name()="resumptionToken"]')
    if [[ ! -z "$resumptionToken" ]];then
        sleep 1
        identifiers "$resumptionToken"
    else
        echo "Finished yay!"
        echo >> "$TIMESTAMP_FILE"
        timestamp >> "$TIMESTAMP_FILE"
    fi
}

harvest() {
    while read id;do
        # shellcheck disable=SC2001
        id=$(echo "$id"|sed 's/.*://')
        url="http://$BASEURL/cgi/export/eprint/${id}/XML/${id}.xml"
        outfile="$HARVEST_DIR/${id}.xml"
        if [[ -e "$outfile" ]];then
            echo "$(C 1)Already loaded: '$url' -> '$outfile'$(C)"
            continue
        else
            echo -n "$(C 3)Downloading: '$url' $(C)"
            curl -s -o "$outfile" "$url"
            echo " $(C 2)DONE$(C)"
            sleep 1;
        fi
    done < "$IDENTIFIER_LIST"
}

xquery() {
    export JAVA_ARGS="-Dorg.basex.DBPATH='$BASEX_DBPATH'"
    # ... TODO
}

#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------

ACTION="$1"

which curl >/dev/null \
    || { usage "$(C 8)ERROR$(C): Requires curl (sudo apt-get install curl)" 1; }
which xmlstarlet >/dev/null \
    || { usage "$(C 8)ERROR$(C): Requires curl (sudo apt-get install xmlstarlet)" 1; }
which basex >/dev/null \
    || { usage "$(C 8)ERROR$(C): Requires curl (sudo apt-get install basex)" 1; }
[[ -z "$ACTION"  ]]\
    && { usage "$(C 8)ERROR$(C): Must specify action" 1; }

# setup variables

case "$ACTION" in
    debug)
        BASEURL="$2"
        if [[ -z "$BASEURL" ]];then
            BASEURL="not-specified"
        fi
        setup_vars
        ;;
    identifiers|harvest|xquery)
        BASEURL="$2"
        setup_vars
        setup_sitedir
        ;;
     *)
         usage "$(C 8)ERROR$(C): Invalid action '$ACTION'" 1
         ;;
esac

$ACTION
