pragma solidity ^0.4.18;


/**
** 合同对象继位标准 所以需要做合同对象变更的合约均需要实现此标准
**/
contract ContractSucceed {

    function succeed() public returns (bool);
}