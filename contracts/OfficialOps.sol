pragma solidity ^0.4.18;


import './TokenManagement.sol';
import './Coin.sol';


contract CoinOptions is Managed {

    Coin internal feather;


    modifier initial_coin_address ()  {
        //require(feather);
        _;
    }

    //官方调用交易
    function officialTransfer(address _from, address _to, uint256 _value, bytes _data) official_only initial_coin_address public {
        feather.officialTransfer(_from, _to, _value, _data);
    }

    //官方冻结or解冻账号
    function officialFreezeAccount(address target, bool freeze) official_only initial_coin_address public {
        feather.freezeAccount(target, freeze);
    }

    //增发货币
    function mintToken(uint256 mintedAmount) official_only initial_coin_address public {
        require(mintedAmount > 0);
        feather.mintToken(mintedAmount);
    }
}


contract OfficialOps is Managed, CoinOptions {


    address public coinAddress;


    function OfficialOps() public {
        //coinAddress cant be initialized, but set by administrator later on
        coinAddress = 0x0;
        //feather contract address
    }

    //annonymous function to receive fund, just like required in erc223 standard
    function() public {
        //throw;
    }


    //超管设置被管理的货币地址
    function setCoinAddress(address _newCoinAddress) administrator_only public {
        require(isContract(_newCoinAddress));
        feather = Coin(_newCoinAddress);
        coinAddress = _newCoinAddress;
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
