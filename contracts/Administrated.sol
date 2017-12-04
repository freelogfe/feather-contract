pragma solidity ^0.4.18;


contract Administrated {
    address public managingContract;

    modifier sudo() {
        require(msg.sender == managingContract);
        _;
    }
}