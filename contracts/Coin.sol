pragma solidity ^0.4.18;


import './ERC223Token.sol';
import './Administrated.sol';
import './ERC223RecevingContract.sol';


contract Coin is Administrated, ERC223Token {
    string public name;

    string public symbol;

    uint8 public decimals = 18;

    uint256 public totalSupply;

    mapping (address => uint) public balanceOf;

    mapping (address => mapping (address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value, bytes _data);

    event Burn(address indexed from, uint256 value);

    function Coin(uint256 initialSupply, string coinName, string coinSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        name = coinName;
        symbol = coinSymbol;
    }

    //internal utility functions
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_to] + balanceOf[_from];
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        assert(balanceOf[_to] + balanceOf[_from] == previousBalances);

        uint codeLength;
        assembly {
        codeLength := extcodesize(_to)
        }

        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, '');
        }
    }

    //public functions
    function transfer(address _to, uint256 _value, bytes _data) public {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
    }

    function burn(uint _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    //functions below are administrator_only
    function mintToken(uint256 mintedAmount) sudo public {
        balanceOf[msg.sender] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount, 'mint');
        Transfer(this, msg.sender, mintedAmount, 'new supply');
    }

    function officialTransfer(address _from, address _to, uint256 _value, bytes _data) sudo public {
        _transfer(_from, _to, _value);
        Transfer(_from, _to, _value, _data);
    }
}
