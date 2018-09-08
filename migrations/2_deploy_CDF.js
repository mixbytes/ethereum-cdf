'use strict';

const CDF = artifacts.require('CDF.sol');


module.exports = function(deployer, network) {
    deployer.deploy(CDF);
};
