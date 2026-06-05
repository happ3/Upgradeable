// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

/**
 * @title TokenFaucetProxyAdmin
 * @dev 代理管理员合约，用于管理透明代理合约的升级
 * 这个合约继承了 OpenZeppelin 的 ProxyAdmin
 */
contract TokenFaucetProxyAdmin is ProxyAdmin {
    constructor() ProxyAdmin(msg.sender) {}
}