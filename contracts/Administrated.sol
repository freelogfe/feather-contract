pragma solidity ^0.4.18;


import './MessageAgent.sol';


contract Administrated {

    address public managingContract;

    address public heirManagingContract;

    address public objectContractAddress;

    //是否是管理合同
    modifier sudo() {
        require(msg.sender == managingContract);
        _;
    }

    //初始化时设定好管理合同地址
    function Administrated(address _managingContract, address _objectContractAddress) public {
        managingContract = _managingContract;
        objectContractAddress = _objectContractAddress;
    }

    //变更管理合同
    function changeManagingContract(address _newManagingContract) sudo public {
        require(managingContract != _newManagingContract);
        require(isContract(_newManagingContract));
        heirManagingContract = _newManagingContract;
    }

    //新管理合同确认接管旧合同
    function succeed() public {
        require(heirManagingContract == msg.sender);

        address oldManagingContract = managingContract;
        managingContract = heirManagingContract;
        heirManagingContract = 0;

        MessageAgent message = MessageAgent(objectContractAddress);
        message.managingContractMessage('changeManagingContract', oldManagingContract, msg.sender);
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