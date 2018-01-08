pragma solidity ^0.4.18;


import './TokenManagement.sol';
import './Coin.sol';
import './ContractSucceed.sol';


contract OfficialOps is Managed {

    uint public tapBarb = 100000;

    Coin public feather;

    address public heirManagingContract;

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

        tapRecord[_to] = true;

        if ((balanceOf - _value) < totalSupply / 5) {
            ReservationProportion(totalSupply, balanceOf - _value);
        }
    }

    //普通用户自己tap
    function tap() public {
        require(!tapRecord[msg.sender]);

        uint balanceOf = feather.balanceOf(this);
        uint totalSupply = feather.totalSupply();

        feather.officialTransfer(this, msg.sender, tapBarb, 'tap');

        tapRecord[msg.sender] = true;

        if ((balanceOf - tapBarb) < totalSupply / 5) {
            ReservationProportion(totalSupply, balanceOf - tapBarb);
        }
    }

    //官方冻结or解冻账号
    function officialFreezeAccount(address target, bool freeze) official_only public {
        feather.freezeAccount(target, freeze);
    }

    //官方提现
    function officialWithdrawals(address _address, uint _amount) official_only public {
        feather.officialWithdrawals(_address, _amount);
    }

    //官方设置交易价格
    function officialSetPrice(uint price) official_only public {
        require(price > 0);
        feather.officialSetPrice(price);
    }

    //官方设置用户自己tap的数量
    function officialSetTapBarb(uint _tapBarb) official_only public {
        tapBarb = _tapBarb;
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
    function officialChangeManagingContract(address _newManagingContract) administrator_only public {
        require(isContract(_newManagingContract));
        heirManagingContract = _newManagingContract;
    }

    //新管理合同确认接管旧合同
    function succeed() public returns (bool) {
        require(heirManagingContract == msg.sender);

        //把旧管理合同的钱转移给新管理合同
        feather.officialTransferFunds(heirManagingContract);
        //把管理权限移交给新合同
        feather.changeManagingContract(heirManagingContract);

        //清理管理继承人
        heirManagingContract = 0;

        return true;
    }

    //实现合同继位标准
    function confrimSucceed(address oldManagerAddress) administrator_only public {
        require(isContract(oldManagerAddress));
        ContractSucceed oldManager = ContractSucceed(oldManagerAddress);
        oldManager.succeed();
    }

    //地址是否是以太坊合约
    function isContract(address _contractAddress) internal constant returns (bool) {
        uint length;
        assembly {
        //检索目标地址上的代码大小，这需要汇编
        length := extcodesize(_contractAddress)
        }
        return (length > 0);
    }

    //超管设置被管理的货币地址
    function setCoinAddress(Coin _newCoinAddress) administrator_only public {
        require(isContract(_newCoinAddress));
        feather = _newCoinAddress;
    }
}
