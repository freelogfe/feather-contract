pragma solidity ^0.4.18;


import './TokenManagement.sol';
import './Coin.sol';


contract CoinOperation is Managed {

    Coin internal feather;

    mapping (address => bool) public tapRecord;

    event ReservationProportion(uint totalSupply, uint balanceOf);

    //官方调用交易
    function officialTransfer(address _from, address _to, uint256 _value, bytes _data) official_only public {
        feather.officialTransfer(_from, _to, _value, _data);
    }

    //官方账户给其他账号初始化金额
    function tap(address _to, uint _value) official_only public {
        require(!tapRecord[_to]);

        uint balanceOf = feather.balanceOf(this);
        uint totalSupply = feather.totalSupply();

        feather.officialTransfer(this, _to, _value, 'tap');

        if (balanceOf < totalSupply / 5) {
            ReservationProportion(totalSupply, balanceOf);
        }
    }

    //官方冻结or解冻账号
    function officialFreezeAccount(address target, bool freeze) official_only public {
        feather.freezeAccount(target, freeze);
    }

    //增发货币
    function mintToken(uint256 mintedAmount) official_only public {
        require(mintedAmount > 0);
        feather.mintToken(mintedAmount);
    }

    //官方销毁自己的货币
    function burn(uint _value) official_only public {
        feather.burn(_value);
    }

    //官方更换货币的管理权
    function officialChangeManagingContract(address _newManagingContract) official_only public {
        feather.changeManagingContract(_newManagingContract);
    }

    //确认接受货币管理权(更新货币合同测试使用)
    function officialSucceed() official_only public {
        feather.succeed();
    }
}


contract OfficialOps is Managed, CoinOperation {


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
