'use strict';

const Comparison = artifacts.require("Comparison.sol");

const l = console.log;


contract('Comparison', function(accounts) {
    it("compare", async function() {
        for (const objectsNumber of [1, 2, 5, 10, 15, 20, 30]) {
            const instanceColumnar = await Comparison.new();
            const instanceSimple = await Comparison.new();
            l('objects', objectsNumber, 'simple', (await instanceSimple.simpleTest(objectsNumber)).receipt.gasUsed,
                'columnar', (await instanceColumnar.columnarTest(objectsNumber)).receipt.gasUsed);
        }
    });
});
