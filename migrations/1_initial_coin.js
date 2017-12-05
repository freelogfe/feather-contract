'use strict'

const Coin = artifacts.require("./Coin.sol");

module.exports = function (deployer) {

    deployer.deploy(Coin, 100000000000000, 'feather', 'f', '0xfdbedb44bdf81491f82ac0ff4c873e21e077818d');
};
