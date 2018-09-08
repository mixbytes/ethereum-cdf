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
        uint32 nextId;
        uint16[] memory currentChunkLengths;
        (nextId, currentChunkLengths) = CDF.unpackWriterState(writerState);

        uint thisId = nextId++;

        uint fieldNumber = 0;
        uint chunkNumber;
        uint itemNumberInChunk;
        uint chunkDataPosition;

        // name
        chunkNumber = CDF.chunkNumber(thisId, name_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, name_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("name", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        uint16 currentChunkLength = currentChunkLengths[fieldNumber];


        fieldNumber++;


        writerState = CDF.packWriterState(nextId, currentChunkLengths);

        return thisId;
    }


    function read(uint id) public view returns (string name, uint32 latitude, uint32 longitude, address owner) {

    }


    CDF.ColumnMeta name_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});
    CDF.ColumnMeta latitude_meta = CDF.ColumnMeta({itemsPerChunkInBits: 7});
    CDF.ColumnMeta longitude_meta = CDF.ColumnMeta({itemsPerChunkInBits: 7});
    CDF.ColumnMeta owner_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});


    uint private writerState;
}
