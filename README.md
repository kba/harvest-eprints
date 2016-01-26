harvest-eprints
===============

* [Installation](#installation)
* [Usage](#usage)
  * [`identifiers`](#identifiers)
  * [`harvest`](#harvest)
  * [`xquery`](#xquery)
* [License](#license)

## Installation

Requires
* curl
* xmlstarlet
* basex

```
sudo apt-get install curl xmlstarlet basex
```

## Usage

```
./harvest.sh <debug identifiers harvest xquery> <baseurl> [xquery bindings]

```

* `baseurl` must be the base URL of an ePrints repository.
* `xquery` and `bindings` are for the [xquery](#xquery) command

Creates a folder `site` that contains harvested data in a subfolder per base URL.

### identifiers

Harvests the identifiers of a all non-deleted records that were added or
modified since the last time `harvest.sh identifiers` was run on this site (or
all records if it has never been run).

Example:

```
./harvest.sh identifiers epub.my-university.edu
```

### harvest

Harvests all the records in the EPrints internal format using the URI
`{baseurl}/cgi/export/eprint/{id}/XML/{id}.xml` to the folder `records`.

Example:

```
./harvest.sh harvest epub.my-university.edu
```

### xquery

Will create one [BaseX XML database](http://basex.org) per site for the
harvested XML in the folder `./BaseXData`. It then runs the XQuery script
`xquery` given as the third parameter, optionally with the `bindings` given as
the fourth parameter to the script.

Example:

```
./harvest.sh xquery epub.my-university.edu /path/to/my-script.xq "SOMEVAR=somevalue,anotherVar=ANOTHER VALUE"
```

### Folder structure

```
./harvest.sh
./site                   # $BASE_DIR
└── <baseurl>/           # $SITE_DIR
    ├── records/         # $HARVEST_DIR
    ├── identifiers.lst  # $IDENTIFIER_LIST
    └── identifiers.time # $TIMESTAMP_FILE
```

## License

May be used under the terms of the MIT License.

(c) 2016 Konstantin Baierer
