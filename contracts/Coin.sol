pragma solidity ^0.4.18;


import './Administrated.sol';
import './ERC223RecevingContract.sol';

contract Coin is Administrated {
    string public name;

    string public symbol;

    uint8 public decimals = 3;

    uint256 public totalSupply = 0x0;

    //是否开放 eth购买feather 后续提供给管理合同操作此变量
    bool isOpenBuy = true;

    //1barb(纤)对应的的wei交易比例
    uint public price = 1000000000000;

    mapping (address => uint) public balanceOf;

    mapping (address => mapping (address => uint)) public allowance;

    //冻结账号
    mapping (address => bool) public frozenAccount;

    //交易事件
    event Transfer(address indexed from, address indexed to, uint256 value, bytes _data);

    event Burn(address indexed from, uint256 value);

    //冻结or解冻账号事件
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
            receiver.tokenFallback(msg.sender, _value, '');
        }
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, '');
    }

    function transfer(address _to, uint256 _value, bytes _data) public {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
    }

    //摧毁货币
    function burn(uint _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    //购买feather
    function buyFeather() public payable returns (uint) {
        require(msg.value >= price);

        //计算剩余的以太(位)
        uint surplus = msg.value % price;

        uint transferBarb = (msg.value - surplus) / price;

        _transfer(managingContract, msg.sender, transferBarb);
        Transfer(managingContract, msg.sender, transferBarb, 'buyFixedFeather');

        //剩余的以太暂存起来,用户可以提取
        if (surplus > 0) {
            msg.sender.transfer(surplus);
        }

        return transferBarb;
    }

    //购买固定数量的Feather
    function buyFixedFeather(uint _expectedBarb) public payable returns (uint) {
        require(msg.value >= price);

        //计算剩余的以太(位)
        uint surplus = msg.value % price;

        uint transferBarb = (msg.value - surplus) / price;

        //如果实际购买数量少于期望的数量,则返回,交易失败
        require(transferBarb >= _expectedBarb);

        _transfer(managingContract, msg.sender, transferBarb);
        Transfer(managingContract, msg.sender, transferBarb, 'buyFixedFeather');

        if (surplus > 0) {
            msg.sender.transfer(surplus);
        }

        return transferBarb;
    }

    //官方提现
    function officialWithdrawals(address _address, uint _amount) sudo public {
        require(_address != address(0));
        require(!isContract(_address));
        require(this.balance >= _amount);
        _address.transfer(_amount);
    }

    // 增发货币
    //functions below are administrator_only
    function mintToken(uint256 _mintedAmount) sudo public {
        balanceOf[managingContract] += _mintedAmount;
        totalSupply += _mintedAmount;
        Transfer(0, managingContract, _mintedAmount, 'mint');
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

    //官方设置交易价格
    function officialSetPrice(uint _price) sudo public {
        require(_price > 0);
        price = _price;
    }

    //冻结or解冻账号
    function freezeAccount(address target, bool freeze) sudo public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
}
