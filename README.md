# Ethereum CDF

Ethereum Columnar Data Storage Format.

At the moment is append-only.


## Use cases

- optimizing storage fee for structured data
- optimizing bulk write costs for structured data


## TODO

- report, slides
- search by hash


## Further work

- optional fields
- fields which are not known beforehand
- caching data in memory and performing better packing (dict-based, etc)
- marking deletion of entries using packed ints
- secondary indexes
