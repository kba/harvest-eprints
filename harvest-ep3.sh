#!/bin/bash

mkdir -p harvest

while read id;do
    id=$(echo $id|sed 's/.*://')
    url="http://ub-madoc.bib.uni-mannheim.de/cgi/export/eprint/${id}/XML/madoc-eprint-${id}.xml"
    echo "Harvesting $url"
    curl "$url" > harvest/${id}.xml
    sleep 1;
done < 0identifiers.lst
