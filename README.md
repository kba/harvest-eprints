harvest-eprints
===============

* [Installation](#installation)
* [Usage](#usage)
  * [`identifiers`](#identifiers)
  * [`harvest`](#harvest)
* [License](#license)

## Installation

Requires
* curl
* xmlstarlet

```
sudo apt-get install curl xmlstarlet
```

## Usage

```
./harvest.sh <identifiers|harvest> <baseurl>
```

`baseurl` must be the base URL of an ePrints repository.

Creates a folder site that contains harvested data in a subfolder per basurl

### identifiers

Harvests the identifiers of a all non-deleted records that were added or
modified since the last time `harvest.sh identifiers` was run on this site (or
all records if it has never been run).

### harvest

Harvests all the records in the EPrints internal format using the URI
`{baseurl}/cgi/export/eprint/{id}/XML/{id}.xml` to the folder `records`.

### Folder structure

```
./harvest.sh
./README.md
./site                   # $BASE_DIR
└── <baseurl>/           # $SITE_DIR
    ├── xquery/
    ├── records/         # $HARVEST_DIR
    ├── identifiers.lst  # $IDENTIFIER_LIST
    └── identifiers.time # $TIMESTAMP_FILE
```



## License

May be used under the terms of the MIT License.

(c) 2016 Konstantin Baierer
