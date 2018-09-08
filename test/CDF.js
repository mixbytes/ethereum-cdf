'use strict';

const CDF = artifacts.require("CDFTestHelper.sol");

const l = console.log;


contract('CDF', function(accounts) {
    it("test instantiation", async function() {
        const instance = await CDF.new();
    });

    it("test chunkNumber", async function() {
        const instance = await CDF.deployed();

        assert.equal(await instance.chunkNumber(0, 4), 0);
        assert.equal(await instance.chunkNumber(1, 4), 0);
        assert.equal(await instance.chunkNumber(15, 4), 0);

        assert.equal(await instance.chunkNumber(16, 4), 1);
        assert.equal(await instance.chunkNumber(17, 4), 1);

        assert.equal(await instance.chunkNumber(100, 4), 6);
    });

    it("test itemNumberInChunk", async function() {
        const instance = await CDF.deployed();

        assert.equal(await instance.itemNumberInChunk(0, 4), 0);
        assert.equal(await instance.itemNumberInChunk(1, 4), 1);
        assert.equal(await instance.itemNumberInChunk(15, 4), 15);

        assert.equal(await instance.itemNumberInChunk(16, 4), 0);
        assert.equal(await instance.itemNumberInChunk(17, 4), 1);

        assert.equal(await instance.itemNumberInChunk(100, 4), 4);
    });

    it("test unpackWriterState", async function() {
        const instance = await CDF.deployed();

        let result = await instance.unpackWriterState(0);
        assert.equal(result[0], 0);
        assert.equal(result[1][0], 0);
        assert.equal(result[1][1], 0);

        result = await instance.unpackWriterState(0x0008000100000001);
        assert.equal(result[0], 1);
        assert.equal(result[1][0], 1);
        assert.equal(result[1][1], 8);
    });

    it("test packWriterState", async function() {
        const instance = await CDF.deployed();

        assert.equal(await instance.packWriterState(0, [0, 0, 0, 0, 0, 0]), 0);
        assert((await instance.packWriterState(1, [1, 8, 0, 0, 0, 0])).eq(
            new web3.BigNumber(0x00080001).mul(0x100000000).add(1)));
    });


    // writeChunkBytes(uint chunkDataPosition, uint chunkDataOffset, bytes buffer)

    it("test writeChunkBytes from scratch", async function() {
        const instance = await CDF.deployed();

        await instance.writeChunkBytes(200000, 0, '0x00');
        assert((await instance.load_slot(200000)).eq(new web3.BigNumber('0x0')));

        await instance.writeChunkBytes(300000, 0, '0x01');
        assert((await instance.load_slot(300000)).eq(new web3.BigNumber('0x01')));

        await instance.writeChunkBytes(400000, 0, '0x0109');
        assert((await instance.load_slot(400000)).eq(new web3.BigNumber('0x0901')));
    });

    it("test writeChunkBytes append in the same slot", async function() {
        const instance = await CDF.deployed();

        await instance.writeChunkBytes(500000, 0, '0x010203040506');
        await instance.writeChunkBytes(500000, 6, '0x07');
        assert((await instance.load_slot(500000)).eq(new web3.BigNumber('0x07060504030201')));

        await instance.writeChunkBytes(600000, 0, '0x010203040506');
        await instance.writeChunkBytes(600000, 6, '0x0708');
        assert((await instance.load_slot(600000)).eq(new web3.BigNumber('0x0807060504030201')));
    });

    it("test writeChunkBytes append which fills slot", async function() {
        const instance = await CDF.deployed();

        await instance.writeChunkBytes(700000, 0, '0x010203040506');
        await instance.writeChunkBytes(700000, 6, '0xffffffffffffffffffffffffffffffffffffffffffffffffffff');
        assert((await instance.load_slot(700000)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffff060504030201')));
        assert((await instance.load_slot(700001)).eq(new web3.BigNumber('0x0')));
    });

    it("test writeChunkBytes overflows to the next slot", async function() {
        const instance = await CDF.deployed();

        await instance.writeChunkBytes(800000, 0, '0x01020304050607');
        await instance.writeChunkBytes(800000, 7, '0xffffffffffffffffffffffffffffffffffffffffffffffffffff');
        assert((await instance.load_slot(800000)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffff07060504030201')));
        assert((await instance.load_slot(800001)).eq(new web3.BigNumber('0xff')));
    });

    it("test writeChunkBytes append which fills many slots", async function() {
        const instance = await CDF.deployed();

        await instance.writeChunkBytes(900000, 0, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
        assert((await instance.load_slot(900000)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')));
        assert((await instance.load_slot(900001)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')));
        assert((await instance.load_slot(900002)).eq(new web3.BigNumber('0x0')));

        await instance.writeChunkBytes(1000000, 0, '0x010203040506');
        await instance.writeChunkBytes(1000000, 6, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
        assert((await instance.load_slot(1000000)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffff060504030201')));
        assert((await instance.load_slot(1000001)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')));
        assert((await instance.load_slot(1000002)).eq(new web3.BigNumber('0x0')));
    });

    it("test writeChunkBytes append which fills many slots and overflows", async function() {
        const instance = await CDF.deployed();

        await instance.writeChunkBytes(1100000, 0, '0x010203040506');
        await instance.writeChunkBytes(1100000, 6, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffabaa');
        assert((await instance.load_slot(1100000)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffff060504030201')));
        assert((await instance.load_slot(1100001)).eq(new web3.BigNumber('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')));
        assert((await instance.load_slot(1100002)).eq(new web3.BigNumber('0xaaab')));
    });


    // readChunkBytes(uint chunkDataPosition_, uint chunkDataOffset, uint chunkDataLength)

    async function checkRW(instance, position, offset, data) {
        const dataLength = (data.length - 2) / 2;
        await instance.writeChunkBytes(position, offset, data);
        assert.equal(await instance.readChunkBytes(position, offset, dataLength), data);
    }

    it("test readChunkBytes from scratch", async function() {
        const instance = await CDF.deployed();

        await checkRW(instance, 200000, 0, '0x00');
        await checkRW(instance, 300000, 0, '0x01');
        await checkRW(instance, 400000, 0, '0x0109');
    });

    it("test readChunkBytes append in the same slot", async function() {
        const instance = await CDF.deployed();

        await checkRW(instance, 500000, 0, '0x010203040506');
        await checkRW(instance, 500000, 6, '0x07');

        await checkRW(instance, 600000, 0, '0x010203040506');
        await checkRW(instance, 600000, 6, '0x0708');
    });

    it("test readChunkBytes append which fills slot", async function() {
        const instance = await CDF.deployed();

        await checkRW(instance, 700000, 0, '0x010203040506');
        await checkRW(instance, 700000, 6, '0xffffffffffffffffffffffffffffffffffffffffffffffffffff');
    });

    it("test readChunkBytes overflows to the next slot", async function() {
        const instance = await CDF.deployed();

        await checkRW(instance, 800000, 0, '0x01020304050607');
        await checkRW(instance, 800000, 7, '0xffffffffffffffffffffffffffffffffffffffffffffffffffff');
    });

    it("test readChunkBytes append which fills many slots", async function() {
        const instance = await CDF.deployed();

        await checkRW(instance, 900000, 0, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');

        await checkRW(instance, 1000000, 0, '0x010203040506');
        await checkRW(instance, 1000000, 6, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
    });

    it("test readChunkBytes append which fills many slots and overflows", async function() {
        const instance = await CDF.deployed();

        await checkRW(instance, 1100000, 0, '0x010203040506');
        await checkRW(instance, 1100000, 6, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffabaa');
    });


    it("test writeUint32", async function() {
        const instance = await CDF.deployed();

        assert.equal(await instance.writeUint32(120000000), '0x000e2707');
    });
});
