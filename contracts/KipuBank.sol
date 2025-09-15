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
    address[] private _accounts;

    error NotOwnerBank(address caller);
    error NotAccountOwner(address caller);
    error InvalidValue(uint256 value);
    error MaxBankCapReached(uint256 value);
    error InsufficientBalance(uint256 value);
    error TransferFailed();

    /// @notice Emitted when a user makes a successful deposit
    event SuccessfulDeposit(address indexed account, uint256 amount);

    /// @notice Emitted when a user makes a successful withdrawal
    event SuccessfulWithdrawal(address indexed account, uint256 amount);

    constructor(uint256 _MaxBankCap, uint256 _LimitMaxPerWithdraw) {
        MaxBankCap = _MaxBankCap;
        LimitMaxPerWithdraw = _LimitMaxPerWithdraw;
        ownerBank = msg.sender;
    }

    function deposit() external payable {
        if (msg.value <= 0 || msg.value > LimitMaxPerWithdraw) {
            revert InvalidValue(LimitMaxPerWithdraw);
        }
        if (KipuBankBalance + msg.value > MaxBankCap) {
            revert MaxBankCapReached(MaxBankCap - KipuBankBalance);
        }
        if (_balances[msg.sender] == 0) {
            _accounts.push(msg.sender);
        }
        _balances[msg.sender] += msg.value;
        KipuBankBalance += msg.value;
        countDeposits ++;

        emit SuccessfulDeposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external payable {
        if (amount <= 0 || amount > _balances[msg.sender]) {
            revert InsufficientBalance(_balances[msg.sender]);
        }
        _balances[msg.sender] -= amount;
        KipuBankBalance -= amount;
        countWithdrawals ++;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }

        emit SuccessfulWithdrawal(msg.sender, amount);
    }

    modifier onlyOwnerBank() {
        if (msg.sender != ownerBank) {
            revert NotOwnerBank(msg.sender);
        }
        _;
    }

    function currentBalance() external view onlyOwnerBank returns (uint256 current) {
        return KipuBankBalance;
    }

    function allBalances() private view returns (address[] memory, uint256[] memory) {
        uint256[] memory balances = new uint256[](_accounts.length);
        for (uint256 i = 0; i < _accounts.length; i++) {
            balances[i] = _balances[_accounts[i]];
        }
        return (_accounts, balances);
    }

    function currentBalances() external view onlyOwnerBank returns (address[] memory, uint256[] memory) {
    return allBalances();
}

    function getDeposits() external view onlyOwnerBank returns (uint256 current) {
        return countDeposits;
    }

    function getWithdrawals() external view onlyOwnerBank returns (uint256 current) {
        return countWithdrawals;
    }

    modifier onlyAccountOwner(address account) {
        if (msg.sender != account && msg.sender != ownerBank) {
            revert NotAccountOwner(msg.sender);
        }
        _;
    }

    function getBalance(
        address account
    ) external view onlyAccountOwner(account) returns (uint256) {
        return _balances[account];
    }
}
