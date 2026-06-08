// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.33;

// 题目#1
// 编写一个 Bank 合约，实现功能：

// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户


/**
 * @title 冒泡排序版本
 * @author 
 * @notice 
 */

contract TokenBank { 
    mapping(address => uint256) public balances;

    address public owner;

    address[] public userList;
    mapping(address => bool) public isInList;

    address[3] public topThree;

    constructor() {
        owner = msg.sender;
    }

    modifier  greaterZero() {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
        _;
    }
    receive() external payable greaterZero {
        _handleDeposit(msg.sender,msg.value);
    }

    function deposit() public payable greaterZero{
        _handleDeposit(msg.sender,msg.value);
    }

    function _handleDeposit(address user,uint256 amount) internal {
        balances[user] += amount;
        if (!isInList[user]) {
            isInList[user] = true;
            userList.push(user);
        }

        // 刷新前三名榜单
        _sortAndUpdateTopThree();
    } 

    function _sortAndUpdateTopThree() internal {
        uint256 len = userList.length;
        address[] memory sortArr = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            sortArr[i] = userList[i];
        }

        for (uint256 i = 0; i < userList.length; i++) {
            for (uint j = i+1; j < userList.length; j++) {
                address a = sortArr[i];
                address b = sortArr[j];
                if(balances[a] > balances[b]){
                     (sortArr[i], sortArr[j]) = (sortArr[j], sortArr[i]);
                }
            }
        }

        for (uint idx = 0; idx < 3; idx++) {
            if(idx < userList.length){
                topThree[idx] = sortArr[idx];
            }else{
                topThree[idx] = address(0);
            }
        }
    }

    //合约拥有者提现
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
       (bool sussess,) = payable(msg.sender).call{value: address(this).balance}("");
       require(sussess, "Failed to withdraw");
    }

    //查询前三名余额
    function getTopThreeAmounts() external view returns (uint256[3] memory) {
        uint256[3] memory res;
        for (uint i = 0; i < topThree.length; i++) {
            res[i] = balances[topThree[i]];
        }
        return res;
    }
}