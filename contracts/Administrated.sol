pragma solidity ^0.4.18;


contract Administrated {

    address public managingContract;

    //是否是管理合同
    modifier sudo() {
        require(msg.sender == managingContract);
        _;
    }

    //初始化时设定好管理合同地址
    function Administrated(address _managingContract) public {
        managingContract = _managingContract;
    }

    //变更管理合同
    function changeManagingContract(address _newManagingContract) sudo public {
        require(managingContract != _newManagingContract);
        require(isContract(_newManagingContract));
        managingContract = _newManagingContract;
    }

    function isContract(address _contractAddress) internal constant returns (bool) {
        uint length;
        assembly {
        //检索目标地址上的代码大小，这需要汇编
        length := extcodesize(_contractAddress)
        }
        return (length > 0);
    }
}