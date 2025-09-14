// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract KipuBank {
    
    uint256 public immutable MaxBankCap;
    uint256 public immutable LimitMaxPerWithdraw;
    address private immutable ownerBank;
    
    uint256 private KipuBankBalance;

    mapping(address => uint256) private _balances;
    
    constructor(uint256 _MaxBankCap, uint256 _LimitMaxPerWithdraw) {
        MaxBankCap = _MaxBankCap;
        LimitMaxPerWithdraw = _LimitMaxPerWithdraw;
        ownerBank = msg.sender;
  
    }

    function deposit() external payable {
        _balances[msg.sender] += msg.value;
        KipuBankBalance += msg.value;
    }

    function withdraw() external payable {
        _balances[msg.sender] -= msg.value;
        KipuBankBalance -= msg.value;
    }

    function currentBalance() external view returns (uint256 current) {
        return KipuBankBalance;
    }

    function getBalance(address account) external view  returns (uint256) {
        return _balances[account];
    }

}