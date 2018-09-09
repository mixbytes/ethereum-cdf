pragma solidity ^0.4.24;

import "./ValidatorMetadataIO.sol";


contract Comparison is ValidatorMetadataIO {

    function columnarTest(uint entries) public {
        for (uint32 i = 0; i < entries; i++)
            write("John", "Smith", "58675926856262", "30 West 46th Street New York City", "10036");
    }

    function simpleTest(uint entries) public {
        for (uint32 i = 0; i < entries; i++)
            writeSimple("John", "Smith", "58675926856262", "30 West 46th Street New York City", "10036");
    }


    function writeSimple(string firstName, string lastName, string licenseId, string fullAddress, string zipcode) public {
        simpleStorge.push(ValidatorMetadata(firstName, lastName, licenseId, fullAddress, zipcode));
    }

    ValidatorMetadata[] private simpleStorge;
}
