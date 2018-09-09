# Ethereum CDF

Ethereum Columnar Data Storage Format. 

[Slides here](https://docs.google.com/presentation/d/1cRsVw74asH5TrlTbs77IekTY5InHDH-8cgg6g8cowCY/edit?usp=sharing).

Team members: Alexey.


## Use cases

Optimizing smart contract storage usage for structured data.


## Usage

### Requirements

NodeJS 8+, npm, Python 3.

### (optional) Build and test

```bash
npm i

# if not started:
./node_modules/.bin/ganache-cli -l 10000000 >&/tmp/ganache.log &

./node_modules/.bin/truffle compile && ./node_modules/.bin/truffle test
```

### Generate I/O driver contract for your data structure

Write your solidity struct to a file, i. e. `my_struct.sol`:

```solidity
struct ValidatorMetadata {
    string firstName;
    string lastName;
    string licenseId;
    string fullAddress;
    string zipcode;
}
```

Generate contract and write it to a file:

```bash
./generate-storage-driver.py my_struct.sol > contracts/MyStructureIO.sol
```

Use generated contract as a base contract.


## Current limitations and downsides

- maximum 6 fields
- supported field types: string, address, uint32
- append-only
- in some cases higher gas usage during write
- higher read overhead


## Further work

- search by hash
- optional fields
- unlimited fields
- fields which are not known beforehand
- caching data in memory and performing better packing (dict-based, etc)
- marking deletion of entries using packed ints
- secondary indexes
