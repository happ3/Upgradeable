// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {LogicEXV1} from "../src/uups/LogicEXV1.sol";
import {TokenFauceProxy} from "../src/uups/TokenFauceProxy.sol";

contract DeployEXV1 is Script {
    function run() external {
        // 读取环境变量私钥
        uint256 deployPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployPrivateKey);

        // 部署者地址 = 私钥对应的钱包，作为合约owner
        address deployer = vm.addr(deployPrivateKey);
        uint256 initBalance = 500; // 初始化balance数值

        // 1.部署逻辑实现合约V1
        LogicEXV1 logicV1 = new LogicEXV1();

        // 2.拼装初始化calldata：入参(balance, owner地址)
        bytes memory initCall = abi.encodeWithSelector(
            logicV1.initialize.selector,
            initBalance,
            deployer
        );

        // 3.部署ERC1967代理合约，代理内部delegatecall执行initialize
        TokenFauceProxy proxy = new TokenFauceProxy(address(logicV1), initCall);

        console.log("LogicEXV1 address:", address(logicV1));
        console.log("Proxy address:", address(proxy));
        console.log("Owner address:", deployer);

        vm.stopBroadcast();
    }
}