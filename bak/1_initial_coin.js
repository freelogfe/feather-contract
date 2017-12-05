'use strict'

const Coin = artifacts.require("./Coin.sol");

module.exports = function (deployer) {

    deployer.deploy(Coin, 0x100000000000000, 'feather', 'FE');
};
