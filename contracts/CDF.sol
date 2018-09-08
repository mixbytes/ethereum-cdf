pragma solidity ^0.4.24;


library CDF {

    struct ColumnMeta {
        uint itemsPerChunkInBits;
    }


    function chunkNumber(uint itemId, uint itemsPerChunkInBits) internal pure returns (uint) {
        return itemId >> itemsPerChunkInBits;
    }

    function itemNumberInChunk(uint itemId, uint itemsPerChunkInBits) internal pure returns (uint) {
        return itemId & ((1 << itemsPerChunkInBits) - 1);
    }

    function chunkDataPosition(string fieldName, uint chunkNumber_) internal pure returns (uint) {
        return uint(keccak256(abi.encode("CDF.chunkDataPosition", fieldName, chunkNumber_)));
    }


    function unpackWriterState(uint state) internal pure returns (uint32 nextId, uint16[] currentChunkLengths) {
        nextId = uint32(state & 0xFFFFFFFF);
        state = state >> 32;

        currentChunkLengths = new uint16[](MAX_FIELDS);
        for (uint i = 0; i < MAX_FIELDS; i++) {
            currentChunkLengths[i] = uint16(state & 0xFFFF);
            state = state >> 16;
        }
    }

    function packWriterState(uint32 nextId, uint16[] currentChunkLengths) internal pure returns (uint state) {
        state = nextId;
        uint bitOffset = 32;

        for (uint i = 0; i < MAX_FIELDS; i++) {
            state = state | (currentChunkLengths[i] << bitOffset);
            bitOffset += 16;
        }
    }


    uint public constant MAX_FIELDS = 6;

// not implemented in solidity yet
//    ColumnMeta private constant ADDRESS_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant STRING_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant SMALL_UINT_META = ColumnMeta({itemsPerChunkInBits: 7});
}
