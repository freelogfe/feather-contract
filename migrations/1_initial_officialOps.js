'use strict'

const OfficialOps = artifacts.require("./OfficialOps.sol");

module.exports = function (deployer) {

    deployer.deploy(OfficialOps);
};
