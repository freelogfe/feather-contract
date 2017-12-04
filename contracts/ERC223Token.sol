pragma solidity ^0.4.18;


contract ERC223Token {
    uint public totalSupply;

    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value) public;

    function transfer(address to, uint value, bytes data) public;

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
