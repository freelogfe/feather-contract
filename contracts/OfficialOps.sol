pragma solidity ^0.4.18;


import './TokenManagement.sol';
import './Coin.sol';


contract OfficialOps is Managed {

    address public coinAddress;

    function OfficialOps() public {
        //coinAddress cant be initialized, but set by administrator later on
        coinAddress = 0x0;
        //feather contract address
    }

    //annonymous function to receive fund, just like required in erc223 standard
    function() public {
        //todo
    }

    //超管设置被管理的货币地址
    function setCoinAddress(address _newCoinAddress) administrator_only public {
        require(isContract(_newCoinAddress));
        coinAddress = _newCoinAddress;
    }


    //官方调用交易
    function officialTransfer() official_only public constant {
        require(coinAddress != 0x0);
        Coin feather = Coin(coinAddress);
        feather.officialTransfer();
        //todo;
    }

    //地址是否是以太坊合约
    function isContract(address _contractAddress) private constant returns (bool) {
        uint length;
        assembly {
        //检索目标地址上的代码大小，这需要汇编
        length := extcodesize(_contractAddress)
        }
        return (length > 0);
    }
}
