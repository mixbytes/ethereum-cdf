pragma solidity ^0.4.24;

import '../CDF.sol';


contract CDFTestHelper {

    function chunkNumber(uint itemId, uint itemsPerChunkInBits) public pure returns (uint) {
        return CDF.chunkNumber(itemId, itemsPerChunkInBits);
    }

    function itemNumberInChunk(uint itemId, uint itemsPerChunkInBits) public pure returns (uint) {
        return CDF.itemNumberInChunk(itemId, itemsPerChunkInBits);
    }


    function unpackWriterState(uint state) public pure returns (uint32 nextId, uint16[] currentChunkLengths) {
        return CDF.unpackWriterState(state);
    }

    function packWriterState(uint32 nextId, uint16[] currentChunkLengths) public pure returns (uint state) {
        return CDF.packWriterState(nextId, currentChunkLengths);
    }


    function writeChunkBytes(uint chunkDataPosition_, uint chunkDataOffset, bytes buffer) public {
        CDF.writeChunkBytes(chunkDataPosition_, chunkDataOffset, buffer);
    }

    function readChunkBytes(uint chunkDataPosition_, uint chunkDataOffset, uint chunkDataLength) public view
            returns (bytes result)
    {
        return CDF.readChunkBytes(chunkDataPosition_, chunkDataOffset, chunkDataLength);
    }

    function load_slot(uint position) public view returns (uint slot) {
        return CDF.load_slot(position);
    }


    function writeUint32(uint32 data) public pure returns (bytes converted) {
        return CDF.writeUint32(data);
    }

    function readUint32(uint chunkDataPosition_, uint chunkDataOffset) public view
            returns (uint32 result, uint newChunkDataOffset) {
        return CDF.readUint32(chunkDataPosition_, chunkDataOffset);
    }
}
