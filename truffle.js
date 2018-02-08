'use strict'

module.exports = {
    networks: {
        // development: {
        //     host: "localhost",
        //     port: 8545,
        //     network_id: "*", // Match any network id
        //     gas: 4600000,
        //     //gasPrice:20000000000
        // },
        aliyunTestRpc: {
            host: "39.108.77.211",
            port: 8546,
            network_id: "*" // Match any network id
        }
    }
};

//truffle migrate --network aliyunTestRpc --reset
