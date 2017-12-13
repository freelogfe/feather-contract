'use strict'


const OfficialOps = artifacts.require("./OfficialOps.sol");
const Coin = artifacts.require("./Coin.sol");

module.exports = async function (deployer) {
    await deployer.deploy(OfficialOps).then(() => {
        return deployer.deploy(Coin, 'feather', 'ʄ', OfficialOps.address)
    }).then(()=>{
        console.log('OfficialOps.address=' + OfficialOps.address)
        console.log('Coin.address=' + Coin.address)
    })
};

//sudo solc --abi --overwrite  -o ~/工作/freelog-pay-service/eth-contract-abi/ ./contracts/OfficialOps.sol
