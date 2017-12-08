pragma solidity ^0.4.18;


import './Administrated.sol';
import './ERC223RecevingContract.sol';


contract Coin is Administrated {
    string public name;

    string public symbol;

    uint256 public totalSupply = 0x0;

    mapping (address => uint) public balanceOf;

    mapping (address => mapping (address => uint)) public allowance;

    //冻结账号
    mapping (address => bool) public frozenAccount;

    //交易事件
    event Transfer(address indexed from, address indexed to, uint256 value, bytes _data);

    event Burn(address indexed from, uint256 value);

    //冻结账号事件
    event FrozenFunds(address target, bool frozen);

    function Coin(string coinName, string coinSymbol, address _managingContract)
    Administrated(_managingContract) public {
        name = coinName;
        symbol = coinSymbol;
    }


    //internal utility functions
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);

        uint previousBalances = balanceOf[_to] + balanceOf[_from];
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        assert(balanceOf[_to] + balanceOf[_from] == previousBalances);

        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, new bytes(0));
        }
    }

    //public functions
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, new bytes(0));
    }

    //public functions
    function transfer(address _to, uint256 _value, bytes _data) public {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
    }

    //摧毁货币
    function burn(uint _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    // 增发货币
    //functions below are administrator_only
    function mintToken(uint256 mintedAmount) sudo public {
        balanceOf[managingContract] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, managingContract, mintedAmount, 'mint');
        //Transfer(this, msg.sender, mintedAmount, 'new supply');
    }

    //官方操作
    function officialTransfer(address _from, address _to, uint256 _value, bytes _data) sudo public {
        _transfer(_from, _to, _value);
        Transfer(_from, _to, _value, _data);
    }

    //转移管理合同的资金到新的管理合同
    function officialTransferFunds(address _newManagingContract) sudo public {
        require(isContract(_newManagingContract));
        uint previousBalances = balanceOf[managingContract];
        balanceOf[managingContract] = 0;
        balanceOf[_newManagingContract] += previousBalances;
        Transfer(managingContract, _newManagingContract, previousBalances, 'manager change');
    }

    //冻结or解冻账号
    function freezeAccount(address target, bool freeze) sudo public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
}
