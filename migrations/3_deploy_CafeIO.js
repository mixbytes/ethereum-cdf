'use strict';

const CafeIO = artifacts.require("CafeIO.sol");


module.exports = function(deployer, network) {
    deployer.deploy(CafeIO);
};
