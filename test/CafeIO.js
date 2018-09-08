'use strict';

const CafeIO = artifacts.require("CafeIO.sol");

const l = console.log;


contract('CafeIO', function(accounts) {
    it("test instantiation", async function() {
        const instance = await CafeIO.new();
    });

    it("test RW simple", async function() {
        const instance = await CafeIO.new();

        await instance.write("Sixties", 120000000, 500000000, accounts[0]);

        const read = await instance.read(0);
        assert.equal(read[0], "Sixties");
        assert(read[1].eq(120000000));
        assert(read[2].eq(500000000));
        assert.equal(read[3], accounts[0]);
    });

    it("test RW multiple", async function() {
        const instance = await CafeIO.new();

        await instance.write("Sixties", 120000000, 500000000, '0x0000000000000000000000000000000000000001');
        await instance.write("Gaststatte Sophieneck", 130000000, 510000000, '0x0000000000000000000000000000000000000002');
        await instance.write("Curry 61", 140000000, 520000000, '0x0000000000000000000000000000000000000003');

        let read = await instance.read(0);
        assert.equal(read[0], "Sixties");
        assert(read[1].eq(120000000));
        assert(read[2].eq(500000000));
        assert.equal(read[3], '0x0000000000000000000000000000000000000001');

        read = await instance.read(1);
        assert.equal(read[0], "Gaststatte Sophieneck");
        assert(read[1].eq(130000000));
        assert(read[2].eq(510000000));
        assert.equal(read[3], '0x0000000000000000000000000000000000000002');

        read = await instance.read(2);
        assert.equal(read[0], "Curry 61");
        assert(read[1].eq(140000000));
        assert(read[2].eq(520000000));
        assert.equal(read[3], '0x0000000000000000000000000000000000000003');
    });
});
