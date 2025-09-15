# <img src="./images/icons_bank.png" alt="Bank Icon" width="50" /> KipuBank Smart Contract ! <img src="./images/icons_bank.png" alt="Bank Icon" width="50" />

## Description

**KipuBank** is a Solidity smart contract that allows managing Ether deposits and withdrawals for multiple users in a secure and controlled manner. It includes:

* User deposits with a maximum bank fund limit.
* Withdrawals with a maximum limit per transaction.
* Tracking the number of deposits and withdrawals.
* Security against unauthorized calls and transfer failures (Ether sent using `call`).
* Functions to view individual and total bank balances, restricted to the owner or account holders.

---

## Main Features

* **Deposits**: Users can deposit Ether up to the bank's maximum capacity.
* **Withdrawals**: Users can withdraw Ether within their balance and the per-transaction limit.
* **Balance Viewing**:

  * Bank owner: can view all balances and transaction history.
  * Users: can view their own balance.
* **Security**: Protection against reentrancy, invalid values, and unauthorized access.

---

## Deploying on Remix

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create a new file named `KipuBank.sol` and paste the contract code.

<img src="./images/create_file.png" alt="Create File" width="500"/>

3. In the **Solidity Compiler** tab, select version `0.8.20`.
4. Click **Compile KipuBank.sol**.

<img src="./images/compile.png" alt="Compile" width="500"/>

5. Go to the **Deploy & Run Transactions** tab.
6. Select the Ethereum account to act as the bank owner.
7. Enter constructor parameters:

   * `MaxBankCap`: maximum Ether the bank can hold (in wei).
   * `LimitMaxPerWithdraw`: maximum withdrawal per transaction (in wei).

   <img src="./images/constructor.png" alt="Constructor Parameters" width="500"/>

8. Click **Transact**.


---

## Contract in Etherscan

### 1. Contract created on etherscan

 <img src="./images/smartContract_Etherscan.png" alt="Etherscan" width="500"/>

### 2. Necessary to verify and publish the contract

* Enter the contract details.

<img src="./images/contract_details.png" alt="Contract Details" width="500"/>

* Past the complete code and click verify.

<img src="./images/verify_publish.png" alt="Verify & Publish" width="500"/>

---

## Interacting with the Contract via Remix

### 1. Deposit Ether

* Select the `deposit()` function.
* Enter the amount in the **Value** field (in Ether).
* Click **Deposit**.

<img src="./images/confirm_deposit.png" alt="Confirmation Deposit" width="500"/>

* The user balance is updated and the `SuccessfulDeposit` event is emitted.

<img src="./images/event_deposit.png" alt="Event Deposit" width="500"/>

---

### 2. Withdraw Ether

* Select the `withdraw(uint256 amount)` function.
* Enter the amount you want to withdraw.
* Click **Withdraw**.
<img src="./images/confirm_withdraw.png" alt="Confirmation Withdraw" width="500"/>

* The user balance decreases, and the `SuccessfulWithdrawal` event is emitted.

<img src="./images/event_withdraw.png" alt="Event Withdraw" width="500"/>

---

### 3. Check Balances

* **Bank Owner**:

  * `currentBalance()`: returns the total bank balance.

<img src="./images/current_balance.png" alt="Current Balance" width="500"/>

  * `currentBalances()`: returns all user balances.

<img src="./images/current_balances.png" alt="Current Balances" width="500"/>


* **Regular User**:

  * `getBalance(address account)`: returns their own balance.

<img src="./images/account_balance.png" alt="Account Balance" width="500"/>


---

### 4. Transaction History

* **Bank Owner**:

  * `getDeposits()`: total number of deposits.

  <img src="./images/count_deposits.png" alt="Count Deposits" width="500"/>

  * `getWithdrawals()`: total number of withdrawals.

  <img src="./images/count_withdrawals.png" alt="Count Withdrawals" width="500"/>

---

## Notes

* The contract follows the **Checks-Effects-Interactions** pattern to prevent reentrancy attacks.
* Only the bank owner can access aggregated balances and transaction history.
* Each user can only access their own balance.
