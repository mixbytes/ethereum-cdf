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

    /**
     * @dev reads sequential portion of a chunk
     * @param chunkDataPosition_ storage pointer to the beginning of a chunk
     * @param chunkDataOffset offset in bytes(!) from the beginning of a chunk
     * @param chunkDataLength length in bytes(!) of the fragment to read
     */
    function readChunkBytes(uint chunkDataPosition_, uint chunkDataOffset, uint chunkDataLength) internal view
            returns (bytes result)
    {
        result = new bytes(chunkDataLength);
        uint resultOffset;

        uint currentSlotPosition = chunkDataPosition_ + chunkDataOffset / 32;
        uint slot = load_slot(currentSlotPosition);
        uint slotOffset = chunkDataOffset % 32;

        while (resultOffset != chunkDataLength) {
            assert(slotOffset < 32);
            result[resultOffset++] = byte(0xFF & (slot >> (slotOffset++ * 8)));
            if (32 == slotOffset) {
                currentSlotPosition++;
                slot = load_slot(currentSlotPosition);
                slotOffset = 0;
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


    function writeString(string data) internal pure returns (bytes converted) {
        uint length = bytes(data).length;
        if (length < 255) {
            converted = new bytes(length + 1);
            converted[0] = byte(length);
            for (uint i = 0; i < length; i++)
                converted[i + 1] = bytes(data)[i];
            return converted;
        }
        else {
            converted = new bytes(length + 5);
            converted[0] = byte(255);
            converted[1] = byte(length & 0xFF);
            converted[2] = byte((length >> 8) & 0xFF);
            converted[3] = byte((length >> 16) & 0xFF);
            converted[4] = byte((length >> 24) & 0xFF);
            for (i = 0; i < length; i++)
                converted[i + 5] = bytes(data)[i];
            return converted;
        }
    }

    function readString(uint chunkDataPosition_, uint chunkDataOffset) internal view
            returns (string result, uint newChunkDataOffset)
    {
        bytes memory raw = readChunkBytes(chunkDataPosition_, chunkDataOffset, 1);
        uint bytesRead = 1;
        uint length;
        if  (raw[0] < 255) {
            length = uint(raw[0]);
        }
        else {
            bytes memory rawLength = readChunkBytes(chunkDataPosition_, chunkDataOffset + bytesRead, 4);
            bytesRead += 4;
            length = uint(rawLength[0]) | (uint(rawLength[1]) << 8) | (uint(rawLength[2]) << 16) | (uint(rawLength[3]) << 24);
        }
        result = string(readChunkBytes(chunkDataPosition_, chunkDataOffset + bytesRead, length));
        bytesRead += length;
        newChunkDataOffset = chunkDataOffset + bytesRead;
    }


    function writeUint32(uint32 data) internal pure returns (bytes converted) {
        converted = new bytes(4);
        converted[0] = byte(data & 0xFF);
        converted[1] = byte((data >> 8) & 0xFF);
        converted[2] = byte((data >> 16) & 0xFF);
        converted[3] = byte((data >> 24) & 0xFF);
        return converted;
    }

    function readUint32(uint chunkDataPosition_, uint chunkDataOffset) internal view
            returns (uint32 result, uint newChunkDataOffset)
    {
        bytes memory raw = readChunkBytes(chunkDataPosition_, chunkDataOffset, 4);
        result = uint32(raw[0]) | (uint32(raw[1]) << 8) | (uint32(raw[2]) << 16) | (uint32(raw[3]) << 24);
        newChunkDataOffset = chunkDataOffset + 4;
    }


    function writeAddress(address data) internal pure returns (bytes converted) {
        converted = new bytes(20);
        uint value = uint(data);
        for (uint i = 0; i < 20; i++) {
            converted[i] = byte(value & 0xFF);
            value = value >> 8;
        }
        return converted;
    }

    function readAddress(uint chunkDataPosition_, uint chunkDataOffset) internal view
            returns (address result, uint newChunkDataOffset)
    {
        bytes memory raw = readChunkBytes(chunkDataPosition_, chunkDataOffset, 20);
        uint value;
        for (uint i = 0; i < 20; i++) {
            value = (value << 8) | uint(raw[19 - i]);
        }
        result = address(value);
        newChunkDataOffset = chunkDataOffset + 20;
    }


    uint public constant MAX_FIELDS = 6;

// not implemented in solidity yet
//    ColumnMeta private constant ADDRESS_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant STRING_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant SMALL_UINT_META = ColumnMeta({itemsPerChunkInBits: 7});
}
