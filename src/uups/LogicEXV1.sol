// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// ==========================================
// 1. 合约 A (Logic V1) - 有 Bug 的旧版本
// ==========================================
contract LogicEXV1 is Initializable, OwnableUpgradeable,UUPSUpgradeable{
    uint256 public score;

    uint256 public balance;
    using SafeCast for int256;

    constructor(){
        _disableInitializers();
    }

    // 3. 用 initialize 替代 constructor
    // initializer 修饰符保证这个函数只能被调用一次
    function initialize(uint256 _balance,    address initialOwner) public initializer {
        // 必须使用 Upgradeable 版本的初始化函数
        __Ownable_init(initialOwner);
        
        balance = _balance;
    }
    function updateScore(int256 _change) virtual public {
        require(_change >= 0, "V1 Bug: Cannot handle negative numbers (deduction)");
        score += (_change).toUint256();
        balance = 1000;
    }

     // UUPS 必须实现此函数来控制升级权限
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    // 预留存储槽，防止未来升级时发生存储冲突
    uint256[50] private _gap; 
}
