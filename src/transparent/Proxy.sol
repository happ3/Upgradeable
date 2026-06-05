// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * @title Proxy
 * @dev 透明代理合约，用于代理合约TokenFaucetProxy
 * 这个合约继承了 OpenZeppelin 的 TransparentUpgradeableProxy
 * 添加了公开的 proxyAdmin 函数以便获取管理员地址
 */
contract Proxy is TransparentUpgradeableProxy {
    /**
     * @dev 构造函数
     * @param _logic 初始实现合约地址
     * @param _initialOwner 代理管理员地址
     * @param _data 初始化调用数据
     */
    constructor(
        address _logic,
        address _initialOwner,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, _initialOwner, _data) {}

    /**
     * @dev 返回代理合约的管理员地址
     * @return 管理员地址 (ProxyAdmin 合约地址)
     */
    function proxyAdmin() external view returns (address) {
        return _proxyAdmin();
    }

    /**
     * @dev 接收以太币的函数
     * 当合约接收到没有任何调用数据的以太币转账时被调用
     */
    receive() external payable {}
}