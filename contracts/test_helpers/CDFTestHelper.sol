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

    function load_slot(uint position) public view returns (uint slot) {
        return CDF.load_slot(position);
    }
}
