# Ethereum CDF

Ethereum Columnar Data Storage Format. [Slides here](https://docs.google.com/presentation/d/1cRsVw74asH5TrlTbs77IekTY5InHDH-8cgg6g8cowCY/edit?usp=sharing).

At the moment is append-only.


## Use cases

- optimizing storage usage for structured data


## Further work

- search by hash
- optional fields
- unlimited fields
- fields which are not known beforehand
- caching data in memory and performing better packing (dict-based, etc)
- marking deletion of entries using packed ints
- secondary indexes
