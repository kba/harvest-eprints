#!/bin/bash

BASEURL="$1"
BASEURL="${BASEURL:-https://ub-madoc.bib.uni-mannheim.de/cgi/oai2?verb=ListIdentifiers&metadataPrefix=oai_dc}"

current_url="$BASEURL"
harvest() {
    echo "Retrieving $current_url"
    response=$(curl "$current_url")
    echo $response | xmlstarlet sel -t -v '//*[local-name()="identifier"]' >> 0identifiers.lst
    echo >> 0identifiers.lst
    resumptionToken=$(echo $response | xmlstarlet sel -t -v '//*[local-name()="resumptionToken"]')
    if [[ ! -z "$resumptionToken" ]];then
        current_url="$BASEURL&resumptionToken=$resumptionToken"
        sleep 1
        harvest
    fi
}

harvest
