'use strict';

const ValidatorMetadataIO = artifacts.require('ValidatorMetadataIO.sol');


module.exports = function(deployer, network) {
    deployer.deploy(ValidatorMetadataIO);
};
