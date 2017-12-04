pragma solidity ^0.4.18;


import './TokenManagement.sol';


contract OfficialOps is Managed {

    address public coinAddress;

    function OfficialOps() public {
        //coinAddress cant be initialized, but set by administrator later on
        coinAddress = 0x0;
    }

    //annonymous function to receive fund, just like required in erc223 standard
    function() public {
        //todo
    }

    function setCoinAddress(address _coin) administrator_only public {
        coinAddress = _coin;
    }

    function officialTransfer() official_only public constant {
        //todo;
    }
}
