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
            state |= uint(currentChunkLengths[i]) << bitOffset;
            bitOffset += 16;
        }
    }


    /**
     * @dev writes sequential portion of a chunk
     * @param chunkDataPosition_ storage pointer to the beginning of a chunk
     * @param chunkDataOffset offset in bytes(!) from the beginning of a chunk
     * @param buffer to write
     *
     * Encoding bytes into slots is little-endian.
     */
    function writeChunkBytes(uint chunkDataPosition_, uint chunkDataOffset, bytes buffer) internal {
        uint bufferOffset;

        uint currentSlotPosition = chunkDataPosition_ + chunkDataOffset / 32;
        uint slotOffset = chunkDataOffset % 32;
        uint slot;
        if (0 != slotOffset) {
            slot = load_slot(currentSlotPosition);
        }

        while (bufferOffset != buffer.length) {
            assert(slotOffset < 32);
            slot |= uint(0xFF & uint(buffer[bufferOffset++])) << (slotOffset++ * 8);
            if (32 == slotOffset) {
                // slot filled - writing back
                if (slot != 0) {    // yep, we're append-only for now
                    assembly {
                        sstore(currentSlotPosition, slot)
                    }
                }
                currentSlotPosition++;
                slot = 0;
                slotOffset = 0;
            }
        }

        if (slot != 0) {
            assembly {
                sstore(currentSlotPosition, slot)
            }
        }
    }

    function load_slot(uint position) internal view returns (uint slot) {
        assembly {
            slot := sload(position)
        }
    }


    function min(uint x, uint y) private pure returns (uint) {
        return x < y ? x : y;
    }


    uint public constant MAX_FIELDS = 6;

// not implemented in solidity yet
//    ColumnMeta private constant ADDRESS_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant STRING_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant SMALL_UINT_META = ColumnMeta({itemsPerChunkInBits: 7});
}
