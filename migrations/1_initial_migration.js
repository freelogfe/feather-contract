'use strict'

const OfficialOps = artifacts.require("./OfficialOps.sol");
const feaCoin = artifacts.require("./Coin.sol");


module.exports = function (deployer) {

    deployer.deploy(OfficialOps);
    deployer.deploy(feaCoin);

};
