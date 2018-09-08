'use strict';

const CafeIO = artifacts.require("CafeIO.sol");


contract('CafeIO', function(accounts) {
    it("test instantiation", async function() {
        const instance = await CafeIO.new();
    });
});
