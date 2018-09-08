pragma solidity ^0.4.24;

import "./CDF.sol";


contract CafeIO {

    struct Cafe {
        string name;
        uint32 latitude;
        uint32 longitude;
        address owner;
    }


    constructor() public {
    }


    function write(string name, uint32 latitude, uint32 longitude, address owner) public returns (uint id) {
        uint this_id = next_id++;

        uint name_chunk_no = CDF.chunkNumber(this_id, name_meta.itemsPerChunkInBits);

        return this_id;
    }


    function read(uint id) public view returns (string name, uint32 latitude, uint32 longitude, address owner) {

    }


    CDF.ColumnMeta name_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});
    CDF.ColumnMeta latitude_meta = CDF.ColumnMeta({itemsPerChunkInBits: 7});
    CDF.ColumnMeta longitude_meta = CDF.ColumnMeta({itemsPerChunkInBits: 7});
    CDF.ColumnMeta owner_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});


    uint private next_id;
}
