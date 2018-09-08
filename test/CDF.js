'use strict';

const CDF = artifacts.require("CDF.sol");

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
});
