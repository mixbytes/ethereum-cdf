pragma solidity ^0.4.24;


library CDF {

    struct ColumnMeta {
        uint itemsPerChunkInBits;
    }


    function chunkNumber(uint item_id, uint itemsPerChunkInBits) internal pure returns (uint) {
        return item_id >> itemsPerChunkInBits;
    }


// not implemented yet
//    ColumnMeta private constant ADDRESS_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant STRING_META = ColumnMeta({itemsPerChunkInBits: 5});
//    ColumnMeta private constant SMALL_UINT_META = ColumnMeta({itemsPerChunkInBits: 7});
}
