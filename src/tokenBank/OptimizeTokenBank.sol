// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

// 题目#1
// 编写一个 Bank 合约，实现功能：
// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

/**
 * 轻量化排序版本
 */
contract OptimizeTokenBank { 
    mapping(address => uint256) public balances;
    address public owner;
    address[3] public topThree;

    constructor() {
        owner = msg.sender;
    }

    // 管理员校验修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier greaterZero() {
        require(msg.value > 0, "Amount must be greater than 0");
        _;
    }

    // 钱包直接转账存款
    receive() external payable greaterZero {
        _handleDeposit(msg.sender, msg.value);
    }

    // 主动调用存款
    function deposit() public payable greaterZero {
        _handleDeposit(msg.sender, msg.value);
    }

    function _handleDeposit(address user, uint256 amount) internal {
        balances[user] += amount;
        _sortAndUpdateTopThree(user);
    }

    function _sortAndUpdateTopThree(address user) internal { 
        uint256 currentBalance = balances[user];
        uint256 index = 3;
        address[3] memory tempRank = topThree;

        while (index > 0 && balances[tempRank[index - 1]] < currentBalance) {
            // 只有下标0/1/2才执行移位赋值，规避tempRank[3]越界
            if (index < 3) {
                tempRank[index] = tempRank[index - 1];
            }
            // 无论是否赋值，下标必须每次减一，防止死循环
            index--;
        }

        if (index < 3) {
            tempRank[index] = user;
        }

        topThree = tempRank;
    }

    // 仅管理员提取全部余额
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No balance to withdraw");
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // 辅助查询前三名余额
    function getTopThreeBalances() external view returns(address[3] memory, uint[3] memory) {
        uint[3] memory amounts;
        for (uint8 i = 0; i < topThree.length; i++) {
            amounts[i] = balances[topThree[i]];
        }
        return (topThree, amounts);
    }
}