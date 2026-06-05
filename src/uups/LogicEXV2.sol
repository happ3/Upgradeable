// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LogicEXV1} from "./LogicEXV1.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract LogicEXV2 is LogicEXV1{
    using SafeCast for int256;

 // V2 的初始化函数，版本号必须递增
    function initializeV2() public reinitializer(2) {
        // 绝对不能再次调用 __Ownable_init！
        // 如果需要修改 Owner，请使用 transferOwnership(newOwner);
        
        // 可以在这里初始化 V2 新增的状态变量
    }


    // 修复了 V1 不支持负数扣分的 Bug
    function updateScore(int256 _change) public override {
        if (_change > 0) {
            score += _change.toUint256();
        } else if (_change < 0) {
            uint256 decrease = (-_change).toUint256();
            // 防止下溢：如果扣减数大于当前分数，则直接归零
            if (decrease > score) {
                score = 0;
            } else {
                score -= decrease;
            }
        }
        balance = 1000;
    }
    // 【关键】必须显式重写 _authorizeUpgrade，确保升级权限控制
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // V2 不需要重新声明 _gap，除非你新增了状态变量
    // 如果新增了 1 个状态变量，应改为：uint256[49] private _gap;
}