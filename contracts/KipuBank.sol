// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract KipuBank {
    
    uint256 public immutable MaxBankCap;
    uint256 public immutable LimitMaxPerWithdraw;
    address private immutable ownerBank;
    
    uint256 private KipuBankBalance;
    uint256 private countDeposits;
    uint256 private countWithdrawals;

    mapping(address => uint256) private _balances;
    
    error NotOwnerBank(address caller);
    error NotAccountOwner(address caller);
    
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

    modifier onlyOwnerBank(){
        if (msg.sender != ownerBank){
            revert NotOwnerBank(msg.sender);
        }
        _;
    }

    function currentBalance() external view onlyOwnerBank returns (uint256 current) {
        return KipuBankBalance;
    }

    function getDeposits() external view onlyOwnerBank returns (uint256 current) {
        return countDeposits;
    }

    function getWithdrawals() external view onlyOwnerBank returns (uint256 current) {
        return countWithdrawals;
    }

    modifier onlyAccountOwner(address account){
        if (msg.sender != account && msg.sender != ownerBank){
            revert NotAccountOwner(msg.sender);
        }
        _;
    }

    function getBalance(address account) external view onlyAccountOwner(account) returns (uint256) {
        return _balances[account];
    }

}