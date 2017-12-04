pragma solidity ^0.4.18;


//import './OfficialOps.sol';

contract Administrated {

    address public managingContract;

    address public heirManagingContract;

    //初始化时设定好管理合同地址
    function Administrated(address _managingContract) public {
        managingContract = _managingContract;

        //能否直接创建一个OfficialOps作为官方操作合同
        //暂时放弃此想法,限制了后期OfficialOps的可能的变动
        //managingContract = new OfficialOps(this);
    }

    //更新管理合同地址,主要是managingContract发布新版本时,address会产生变动
    //考虑到公平,原则上是managingContract不允许改变.后面待讨论
    function changeManagingContract(address _newManagingContract) sudo public {
        heirManagingContract = _newManagingContract;
    }

    //新管理合同确认接管旧合同
    function succeed() public {
        require(heirManagingContract == msg.sender);
        managingContract = heirManagingContract;
        heirManagingContract = 0;
    }

    //是否是管理合同
    modifier sudo() {
        require(msg.sender == managingContract);
        _;
    }
}