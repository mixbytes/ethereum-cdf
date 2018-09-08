'use strict';

const CDF = artifacts.require('CDFTestHelper.sol');


module.exports = function(deployer, network) {
    deployer.deploy(CDF);
};
