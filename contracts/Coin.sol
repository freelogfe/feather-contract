pragma solidity ^0.4.18;


import './Administrated.sol';
import './ERC223RecevingContract.sol';


contract Coin is Administrated {
    string public name;

    string public symbol;

    uint256 public totalSupply = 0x0;

    uint public price = 1000;

    mapping (address => uint) public balanceOf;

    mapping (address => mapping (address => uint)) public allowance;

    //冻结账号
    mapping (address => bool) public frozenAccount;

    //购买feather剩余的ether
    mapping (address => uint) public surplusEther;

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

    //public functions
    function transfer(address _to, uint256 _value, string _unit) public {
        uint _barb = convertFeather(_value, _unit);

        _transfer(msg.sender, _to, _barb);
        Transfer(msg.sender, _to, _barb, '');
    }

    //public functions
    function transfer(address _to, uint256 _value, string _unit, bytes _data) public {
        uint _barb = convertFeather(_value, _unit);

        _transfer(msg.sender, _to, _barb);
        Transfer(msg.sender, _to, _barb, _data);
    }

    //摧毁货币
    function burn(uint _value, string _unit) public returns (bool) {

        uint _barb = convertFeather(_value, _unit);

        require(balanceOf[msg.sender] >= _barb);
        balanceOf[msg.sender] -= _barb;
        totalSupply -= _barb;
        Burn(msg.sender, _barb);
        return true;
    }

    //购买feather
    function buyFeather() public payable returns (uint) {
        //接受的最小以太币是1szabo
        uint barbToEther = 1000000000000;
        require(msg.value >= barbToEther);

        //计算剩余的以太(位)
        uint surplus = msg.value % barbToEther;
        uint transferBarb = convertFeather((msg.value - surplus) / barbToEther / 1000 * price, 'feather');

        _transfer(managingContract, msg.sender, transferBarb);
        Transfer(managingContract, msg.sender, transferBarb, 'buyFixedFeather');

        //剩余的以太暂存起来,用户可以提取
        if (surplus > 0) {
            surplusEther[msg.sender] += surplus;
        }

        return transferBarb;
    }

    //购买固定数量的Feather
    function buyFixedFeather(uint featherCount) public payable returns (uint) {

        //接受的最小以太币是1szabo
        uint barbToEther = 1000000000000;
        require(msg.value >= barbToEther);

        //计算剩余的以太(位)
        uint surplus = msg.value % barbToEther;
        uint transferBarb = convertFeather((msg.value - surplus) / barbToEther / 1000 * price, 'feather');

        //如果实际购买数量与期望的数量不匹配,则返回
        require(transferBarb != featherCount);

        _transfer(managingContract, msg.sender, transferBarb);
        Transfer(managingContract, msg.sender, transferBarb, 'buyFixedFeather');

        //剩余的以太暂存起来,用户可以提取
        if (surplus > 0) {
            surplusEther[msg.sender] += surplus;
        }

        return transferBarb;
    }

    //提现
    function withdrawals(){
        require(surplusEther[msg.sender] > 0);
        msg.sender.send(surplusEther[msg.sender]);
    }

    // 增发货币
    //functions below are administrator_only
    function mintToken(uint256 mintedAmount, string unit) sudo public {
        uint _barb = convertFeather(mintedAmount, unit);

        balanceOf[managingContract] += _barb;
        totalSupply += _barb;
        Transfer(0, managingContract, _barb, 'mint');
        //Transfer(this, msg.sender, _barb, 'new supply');
    }

    //官方操作
    function officialTransfer(address _from, address _to, uint256 _value, string _unit, bytes _data) sudo public {
        uint _barb = convertFeather(_value, _unit);
        _transfer(_from, _to, _barb);
        Transfer(_from, _to, _barb, _data);
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
        price = _price;
    }

    //冻结or解冻账号
    function freezeAccount(address target, bool freeze) sudo public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    //转换feather
    function convertFeather(uint amount, string unit) public pure returns (uint result) {
        require(keccak256(unit) == keccak256('barb') || keccak256(unit) == keccak256('feather') || keccak256(unit) == keccak256(''));
        if (keccak256(unit) == keccak256('barb')) {
            result = amount;
        }
        else {
            result = amount * 1000;
        }
    }
}
