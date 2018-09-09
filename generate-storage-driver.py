#!/usr/bin/env python3

import sys
import re


def main():
    struct_def, struct_name, struct_fields = parse_definition()

    args_string = ', '.join('{} {}'.format(t, n) for (t, n) in struct_fields)

    print("""pragma solidity ^0.4.24;

import "./CDF.sol";


contract {}IO {{

    {}

""".format(struct_name, struct_def))

    print("""    function write({}) public returns (uint id) {{
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
""".format(args_string))

    for (field_type, field_name) in struct_fields:
        print("""        // {field_name}
        chunkNumber = CDF.chunkNumber(thisId, {field_name}_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(thisId, {field_name}_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("{field_name}", chunkNumber);

        if (0 == itemNumberInChunk) {{
            // starting new chunk
            currentChunkLengths[fieldNumber] = uint16(0);
        }}
        currentChunkLength = currentChunkLengths[fieldNumber];

        packed = CDF.{write_method}({field_name});
        CDF.writeChunkBytes(chunkDataPosition, currentChunkLength, packed);

        require(packed.length < 0xFFFF && currentChunkLength + uint16(packed.length) > currentChunkLength);
        currentChunkLengths[fieldNumber] = currentChunkLength + uint16(packed.length);

        fieldNumber++;
        """.format(field_name=field_name, write_method='write' + field_type.capitalize()))

    print("""        // finalization
        writerState = CDF.packWriterState(nextId, currentChunkLengths);

        return thisId;
    }""")

    print("""    function read(uint id) public view returns ({}) {{
        // init
        uint chunkNumber;
        uint itemNumberInChunk;
        uint chunkDataPosition;
        uint i;
        uint chunkDataOffset;
        """.format(args_string))

    for (field_type, field_name) in struct_fields:
        print("""        // {field_name}
        chunkNumber = CDF.chunkNumber(id, {field_name}_meta.itemsPerChunkInBits);
        itemNumberInChunk = CDF.itemNumberInChunk(id, {field_name}_meta.itemsPerChunkInBits);
        chunkDataPosition = CDF.chunkDataPosition("{field_name}", chunkNumber);

        chunkDataOffset = 0;
        for (i = 0; i <= itemNumberInChunk; i++) {{
            ({field_name}, chunkDataOffset) = CDF.{read_method}(chunkDataPosition, chunkDataOffset);
        }}
        """.format(field_name=field_name, read_method='read' + field_type.capitalize()))

    print("""    }

""")

    meta_by_type = {
        'string': 'CDF.ColumnMeta({itemsPerChunkInBits: 5})',
        'address': 'CDF.ColumnMeta({itemsPerChunkInBits: 5})',
        'uint32': 'CDF.ColumnMeta({itemsPerChunkInBits: 7})'
    }
    for (field_type, field_name) in struct_fields:
        print('    CDF.ColumnMeta {}_meta = {};\n'.format(field_name, meta_by_type[field_type]))

    print("""
    uint private writerState;
}
""")


def parse_definition():
    if len(sys.argv) < 2:
        raise RuntimeError('usage: {} <struct definition file>'.format(sys.argv[0]))

    with open(sys.argv[1], 'r') as fh:
        struct_def = fh.read()

    match = re.match(r'^\s*struct\s+(\w+)\s*{((?:\s*\w+\s+\w+\s*;)+)\s*}\s*$', struct_def, re.I)
    if not match:
        raise RuntimeError('Struct definition is not understood. Please specify only struct, not entire contract.')

    struct_name, struct_rest = match.groups()
    struct_fields = list()
    for pair in struct_rest.split(';')[:-1]:
        field_type, field_name = re.match(r'\s*(\w+)\s+(\w+)\s*', pair).groups()
        if field_type not in ('string', 'address', 'uint32'):
            raise RuntimeError('field {}: type {} is not supported yet'.format(field_name, field_type))
        struct_fields.append((field_type, field_name))

    return struct_def, struct_name, struct_fields


if __name__ == '__main__':
    main()
