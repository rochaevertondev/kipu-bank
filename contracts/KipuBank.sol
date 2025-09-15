// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @title KipuBank
/// @author Everton Rocha
/// @notice A smart contract to manage Ether deposits and withdrawals for multiple users.
/// @dev This contract implements a simple banking system, secured against reentrancy.

contract KipuBank {
    /// @dev The maximum amount of funds the bank can hold.
    uint256 public immutable MaxBankCap;
    /// @dev The maximum amount of Ether that can be withdrawn in a single transaction.
    uint256 public immutable LimitMaxPerWithdraw;
    
    /// @dev The address of the contract's owner, set upon deployment.
    address private immutable _ownerBank;
    /// @dev The total amount of Ether held by the contract.
    uint256 private _kipuBankBalance;
    /// @dev The total count of deposits made.
    uint256 private _countDeposits;
    /// @dev The total count of withdrawals made.
    uint256 private _countWithdrawals;

    /// @dev A mapping of addresses to their individual balances.
    mapping(address => uint256) private _balances;
    /// @dev An array of addresses that hold a balance in the bank.
    address[] private _accounts;

    /// @notice Error returned when a function is called by an address that is not the bank owner.
    /// @param caller The address that attempted the call.
    error NotOwnerBank(address caller);
    /// @notice Error returned when a function accessing an account is called by an unauthorized address.
    /// @param caller The address that attempted the call.
    error NotAccountOwner(address caller);
    /// @notice Error returned for invalid transaction values.
    /// @param value The invalid value passed in the transaction.
    error InvalidValue(uint256 value);
    /// @notice Error returned when the maximum fund limit of the bank is reached.
    /// @param value The amount of funds that exceeds the cap.
    error MaxBankCapReached(uint256 value);
    /// @notice Error returned when a user's balance is insufficient for a withdrawal.
    /// @param value The available balance in the account.
    error InsufficientBalance(uint256 value);
    /// @notice Error returned when an Ether or token transfer fails.
    error TransferFailed();

    /// @notice Emitted when a user makes a successful deposit.
    /// @param account The address of the account that made the deposit.
    /// @param amount The amount of Ether deposited.
    event SuccessfulDeposit(address indexed account, uint256 amount);

    /// @notice Emitted when a user makes a successful withdrawal.
    /// @param account The address of the account that made the withdrawal.
    /// @param amount The amount of Ether withdrawn.
    event SuccessfulWithdrawal(address indexed account, uint256 amount);

    /// @dev The contract constructor. Sets the deployment parameters and the owner.
    /// @param _MaxBankCap The maximum fund limit for the bank.
    /// @param _LimitMaxPerWithdraw The maximum withdrawal limit per transaction.
    constructor(uint256 _MaxBankCap, uint256 _LimitMaxPerWithdraw) {
        MaxBankCap = _MaxBankCap;
        LimitMaxPerWithdraw = _LimitMaxPerWithdraw;
        _ownerBank = msg.sender;
    }

    /// @notice Allows a user to deposit Ether into the bank.
    /// @dev The deposit is added to the user's balance and the bank's total balance.
    function deposit() external payable {
        if (msg.value <= 0) {
            revert InvalidValue(msg.value);
        }
        if (_kipuBankBalance + msg.value > MaxBankCap) {
            revert MaxBankCapReached(MaxBankCap - _kipuBankBalance);
        }
        if (_balances[msg.sender] == 0) {
            _accounts.push(msg.sender);
        }
        _balances[msg.sender] += msg.value;
        _kipuBankBalance += msg.value;
        _countDeposits ++;

        emit SuccessfulDeposit(msg.sender, msg.value);
    }

    /// @notice Allows a user to withdraw an amount of Ether from their account.
    /// @dev The function follows the Checks-Effects-Interactions pattern to prevent reentrancy.
    /// @param amount The amount of Ether to be withdrawn.
    function withdraw(uint256 amount) external payable{
        if (amount <= 0 || amount > LimitMaxPerWithdraw) {
            revert InvalidValue(LimitMaxPerWithdraw); 
        }
        if (amount > _balances[msg.sender]) {
            revert InsufficientBalance(_balances[msg.sender]);
        }
        _balances[msg.sender] -= amount;
        _kipuBankBalance -= amount;
        _countWithdrawals ++;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }

        emit SuccessfulWithdrawal(msg.sender, amount);
    }

    /// @dev A modifier that restricts a function's execution to the contract owner.
    modifier onlyOwnerBank() {
        if (msg.sender != _ownerBank) {
            revert NotOwnerBank(msg.sender);
        }
        _;
    }

    /// @notice Returns the total Ether balance of the bank.
    /// @dev This function can only be called by the bank's owner.
    /// @return current The total Ether balance.
    function currentBalance() external view onlyOwnerBank returns (uint256 current) {
        return _kipuBankBalance;
    }

    /// @dev An internal function that returns all account addresses and their balances.
    /// @return address[] memory An array of account addresses.
    /// @return uint256[] memory An array of corresponding balances.
    function allBalances() private view returns (address[] memory, uint256[] memory) {
        uint256[] memory balances = new uint256[](_accounts.length);
        for (uint256 i = 0; i < _accounts.length; i++) {
            balances[i] = _balances[_accounts[i]];
        }
        return (_accounts, balances);
    }

    /// @notice Returns all account addresses and their balances.
    /// @dev This function can only be called by the bank's owner.
    /// @return address[] memory An array of account addresses.
    /// @return uint256[] memory An array of corresponding balances.
    function currentBalances() external view onlyOwnerBank returns (address[] memory, uint256[] memory) {
    return allBalances();
}

    /// @notice Returns the total count of deposits made.
    /// @dev This function can only be called by the bank's owner.
    /// @return current The total count of deposits.
    function getDeposits() external view onlyOwnerBank returns (uint256 current) {
        return _countDeposits;
    }

    /// @notice Returns the total count of withdrawals made.
    /// @dev This function can only be called by the bank's owner.
    /// @return current The total count of withdrawals.
    function getWithdrawals() external view onlyOwnerBank returns (uint256 current) {
        return _countWithdrawals;
    }

    /// @dev A modifier that restricts a function's execution to the account's owner or bank's owner.
    modifier onlyAccountOwner(address account) {
        if (msg.sender != account && msg.sender != _ownerBank) {
            revert NotAccountOwner(msg.sender);
        }
        _;
    }

    /// @notice Returns the balance of a specific account.
    /// @dev The function can only be called by the account owner.
    /// @return The balance of the account.
    function getBalance(address account) external view onlyAccountOwner(account) returns (uint256) {
        return _balances[account];
    }
}