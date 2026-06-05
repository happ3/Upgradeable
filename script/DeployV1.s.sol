// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TokenFaucetProxyAdmin} from "../src/transparent/TokenFaucetProxyAdmin.sol";
import {Proxy} from "../src/transparent/Proxy.sol";
import {LogicV1} from "../src/transparent/LogicV1.sol";

contract DeployV1 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        //1.部署逻辑V1
        LogicV1 implV1 = new LogicV1();
        //2.部署ProxyAdmin
        TokenFaucetProxyAdmin admin = new TokenFaucetProxyAdmin();
        //3.构造初始化数据 initialize(500)
        bytes memory initData = abi.encodeWithSelector(LogicV1.initialize.selector,500);
        //4.部署透明代理
        Proxy proxy = new Proxy(address(implV1), address(admin), initData);

        console.log("ImplV1:", address(implV1));
        console.log("ProxyAdmin:", address(admin));
        console.log("Proxy:", address(proxy));

        vm.stopBroadcast();
    }
}