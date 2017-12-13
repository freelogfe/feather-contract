'use strict'


const Coin = artifacts.require("./Coin.sol");

module.exports = async function (deployer) {
    await deployer.deploy(Coin, 'feather', 'ʄ', '0xe041340b3338e1f220c10e9971aa4edf9bfd776e').then(() => {
        console.log(Coin.address)
    })
};

//sudo solc --abi --overwrite  -o ~/工作/freelog-pay-service/eth-contract-abi/ ./contracts/OfficialOps.sol
