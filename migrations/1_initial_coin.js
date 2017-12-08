'use strict'


const OfficialOps = artifacts.require("./OfficialOps.sol");
const Coin = artifacts.require("./Coin.sol");

module.exports = function (deployer) {
    deployer.deploy(OfficialOps).then(() => {
        console.log('OfficialOps.address:' + OfficialOps.address)
        deployer.deploy(Coin, 'feather', 'f', OfficialOps.address).then(()=>{
            console.log('Coin.address:' + Coin.address)
        })
    })
};

//sudo solc --abi --overwrite  -o ~/工作/freelog-pay-service/eth-contract-abi/ ./contracts/OfficialOps.sol
