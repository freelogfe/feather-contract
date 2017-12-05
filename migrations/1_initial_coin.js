'use strict'


const OfficialOps = artifacts.require("./OfficialOps.sol");
const Coin = artifacts.require("./Coin.sol");

module.exports = function (deployer) {
    deployer.deploy(OfficialOps).then(() => {
        deployer.deploy(Coin, 10000000, 'feather', 'f', OfficialOps.address)
    })
};
