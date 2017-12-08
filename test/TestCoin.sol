pragma solidity ^0.4.6;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Coin.sol";
import "../contracts/OfficialOps.sol";


contract TestCoin {
    function testInitialDeployedContract() public {

        //OfficialOps officialOpsContract = OfficialOps(DeployedAddresses.OfficialOps());

        uint expected = 1;

        Assert.equal(i, 1, "Owner should have 10000 MetaCoin initially");
    }
}



