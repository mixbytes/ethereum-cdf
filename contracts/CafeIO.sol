pragma solidity ^0.4.24;

import "./CDF.sol";


contract CafeIO {

    struct Cafe {
        string name;
        uint32 latitude;
        uint32 longitude;
        address owner;
    }


    function write(string name, uint32 latitude, uint32 longitude, address owner) public returns (uint id) {
        // init
        uint32 nextId;
        uint16[] memory currentChunkLengths;
        (nextId, currentChunkLengths) = CDF.unpackWriterState(writerState);

        uint thisId = nextId++;

        uint fieldNumber = 0;
        uint chunkNumber;
        uint itemNumberInChunk;
        uint chunkDataPosition;

        // TODO code generation

        // name
        chunkNumber = CDF.chunkNumber(thisId, name_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, name_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("name", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        uint16 currentChunkLength = currentChunkLengths[fieldNumber];

        bytes memory packed = CDF.writeString(name);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;

        // latitude
        chunkNumber = CDF.chunkNumber(thisId, latitude_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, latitude_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("latitude", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeUint32(latitude);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;

        // longitude
        chunkNumber = CDF.chunkNumber(thisId, longitude_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, longitude_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("longitude", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeUint32(longitude);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;

        // owner
        chunkNumber = CDF.chunkNumber(thisId, owner_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, owner_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("owner", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeAddress(owner);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;

        // finalization
        writerState = CDF.packWriterState(nextId, currentChunkLengths);

        return thisId;
    }


    function read(uint id) public view returns (string name, uint32 latitude, uint32 longitude, address owner) {
        // init
        uint chunkNumber;
        uint itemNumberInChunk;
        uint chunkDataPosition;
        uint i;
        uint chunkDataOffset;

        // TODO code generation

        // name
        chunkNumber = CDF.chunkNumber(id, name_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, name_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("name", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (name, chunkDataOffset) = CDF.readString(chunkDataPosition, chunkDataOffset);
        }

        // latitude
        chunkNumber = CDF.chunkNumber(id, latitude_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, latitude_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("latitude", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (latitude, chunkDataOffset) = CDF.readUint32(chunkDataPosition, chunkDataOffset);
        }

        // longitude
        chunkNumber = CDF.chunkNumber(id, longitude_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, longitude_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("longitude", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (longitude, chunkDataOffset) = CDF.readUint32(chunkDataPosition, chunkDataOffset);
        }

        // owner
        chunkNumber = CDF.chunkNumber(id, owner_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, owner_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("owner", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (owner, chunkDataOffset) = CDF.readAddress(chunkDataPosition, chunkDataOffset);
        }
    }


    CDF.ColumnMeta name_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});
    CDF.ColumnMeta latitude_meta = CDF.ColumnMeta({itemsPerChunkInBits: 7});
    CDF.ColumnMeta longitude_meta = CDF.ColumnMeta({itemsPerChunkInBits: 7});
    CDF.ColumnMeta owner_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});


    uint private writerState;
}
