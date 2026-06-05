// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TokenFaucetProxyAdmin} from "../src/transparent/TokenFaucetProxyAdmin.sol";
import {LogicV2} from "../src/transparent/LogicV2.sol";

contract UpgradeV2 is Script {
    // 填你上一轮部署出来的地址
    address constant ADMIN_ADDR = 0xeC18aD6289F95084C355547560D4044F2610F245;
    address constant PROXY_ADDR = 0x3b4adA4074846107743F92326E426ab6403D461D;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        //1.部署新版本逻辑合约V2
        LogicV2 implV2 = new LogicV2();
        console.log("New ImplV2:", address(implV2));

        //2.调用ProxyAdmin.upgrade 升级代理指向V2
        TokenFaucetProxyAdmin admin = TokenFaucetProxyAdmin(ADMIN_ADDR);
        admin.upgrade(
            payable(PROXY_ADDR),
            address(implV2)
        );

        vm.stopBroadcast();
    }
}