pragma solidity ^0.4.24;

import "./CDF.sol";


contract ValidatorMetadataIO {

    struct ValidatorMetadata {
    string firstName;
    string lastName;
    string licenseId;
    string fullAddress;
    string zipcode;
}



    function write(string firstName, string lastName, string licenseId, string fullAddress, string zipcode) public returns (uint id) {
        // init
        uint32 nextId;
        uint16[] memory currentChunkLengths;
        (nextId, currentChunkLengths) = CDF.unpackWriterState(writerState);

        uint thisId = nextId++;

        uint fieldNumber = 0;
        uint chunkNumber;
        uint itemNumberInChunk;
        uint chunkDataPosition;
        
        uint16 currentChunkLength;
        bytes memory packed;

        // firstName
        chunkNumber = CDF.chunkNumber(thisId, firstName_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, firstName_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("firstName", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeString(firstName);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;
        
        // lastName
        chunkNumber = CDF.chunkNumber(thisId, lastName_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, lastName_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("lastName", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeString(lastName);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;
        
        // licenseId
        chunkNumber = CDF.chunkNumber(thisId, licenseId_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, licenseId_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("licenseId", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeString(licenseId);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;
        
        // fullAddress
        chunkNumber = CDF.chunkNumber(thisId, fullAddress_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, fullAddress_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("fullAddress", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeString(fullAddress);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;
        
        // zipcode
        chunkNumber = CDF.chunkNumber(thisId, zipcode_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, zipcode_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("zipcode", chunkNumber);

        if (0 == itemNumberInChunk) {
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.writeString(zipcode);
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;
        
        // finalization
        writerState = CDF.packWriterState(nextId, currentChunkLengths);

        return thisId;
    }
    function read(uint id) public view returns (string firstName, string lastName, string licenseId, string fullAddress, string zipcode) {
        // init
        uint chunkNumber;
        uint itemNumberInChunk;
        uint chunkDataPosition;
        uint i;
        uint chunkDataOffset;
        
        // firstName
        chunkNumber = CDF.chunkNumber(id, firstName_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, firstName_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("firstName", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (firstName, chunkDataOffset) = CDF.readString(chunkDataPosition, chunkDataOffset);
        }
        
        // lastName
        chunkNumber = CDF.chunkNumber(id, lastName_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, lastName_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("lastName", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (lastName, chunkDataOffset) = CDF.readString(chunkDataPosition, chunkDataOffset);
        }
        
        // licenseId
        chunkNumber = CDF.chunkNumber(id, licenseId_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, licenseId_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("licenseId", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (licenseId, chunkDataOffset) = CDF.readString(chunkDataPosition, chunkDataOffset);
        }
        
        // fullAddress
        chunkNumber = CDF.chunkNumber(id, fullAddress_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, fullAddress_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("fullAddress", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (fullAddress, chunkDataOffset) = CDF.readString(chunkDataPosition, chunkDataOffset);
        }
        
        // zipcode
        chunkNumber = CDF.chunkNumber(id, zipcode_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, zipcode_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("zipcode", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {
            (zipcode, chunkDataOffset) = CDF.readString(chunkDataPosition, chunkDataOffset);
        }
        
    }


    CDF.ColumnMeta firstName_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});

    CDF.ColumnMeta lastName_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});

    CDF.ColumnMeta licenseId_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});

    CDF.ColumnMeta fullAddress_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});

    CDF.ColumnMeta zipcode_meta = CDF.ColumnMeta({itemsPerChunkInBits: 5});


    uint private writerState;
}

